module YamlRecord
  class Base  
    attr_accessor :attributes, :is_created, :is_destroyed 
    
    include ActiveSupport::Callbacks
    define_callbacks :before_save, :after_save, :before_destroy, :after_destroy, :before_validation, :before_create, :after_create
    
    before_create :set_id!

    # Constructs a new YamlRecord instance based on specified attribute hash
    #
    # === Example:
    #
    #   class Post < YamlRecord::Base; properties :foo; end 
    #
    #   Post.new(:foo  => "bar")
    #
    def initialize(attr_hash={})
      attr_hash.symbolize_keys!
      attr_hash.reverse_merge!(self.class.properties.inject({}) { |result, key| result[key] = nil; result })

      self.attributes ||= {}
      self.is_created = attr_hash.delete(:persisted) || false
      self.setup_properties!
      attr_hash.each do |k,v|
        self.send("#{k}=", v) # self.attributes[:media] = "foo"
      end
    end

    # Accesses given attribute from YamlRecord instance
    # 
    # === Example:
    #
    #   @post[:foo] => "bar"
    #
    def [](attribute)
      self.attributes[attribute]
    end

    # Assign given attribute from YamlRecord instance with specified value
    # 
    # === Example:
    #
    #   @post[:foo] = "baz"
    #
    def []=(attribute, value)
      self.attributes[attribute] = value
    end

    # Saved YamlRecord instance to file
    # Executes save and create callbacks
    # Returns true if record saved; false otherwise
    # 
    # === Example:
    #
    #   @post.save => true
    #
    def save
      run_callbacks(:before_save)
      run_callbacks(:before_create) unless self.is_created

      existing_items = self.class.all
      if self.new_record?
        existing_items << self 
      else # update existing record
        updated_item = existing_items.find { |item| item.id == self.id }
        return false unless updated_item
        updated_item.attributes = self.attributes
      end

      raw_data = existing_items ? existing_items.map { |item| item.persisted_attributes } : []
      self.class.write_contents(raw_data) if self.valid? 

      run_callbacks(:after_create) unless self.is_created
      run_callbacks(:after_save)
      true
    rescue IOError
      false
    end
    
    # Update YamlRecord instance with specified attributes
    # Returns true if record updated; false otherwise
    # 
    # === Example:
    #
    #   @post.update_attributes(:foo  => "baz", :miso => "awesome") => true
    #
    def update_attributes(updated_attrs={})
      updated_attrs.each { |k,v| self.send("#{k}=", v) }
      self.save
    end
    
    # Returns array of instance attributes names; An attribute is a value stored for this record (persisted or not)
    # 
    # === Example:
    #
    #   @post.column_names => ["foo", "miso"]
    #
    def column_names
      array = []
      self.attributes.each_key { |k| array << k.to_s }
      array
    end
    
    # Returns hash of attributes to be persisted to file.
    # A persisted attribute is a value stored in the file (specified with the properties declaration)
    # 
    # === Example:
    #
    #   class Post < YamlRecord::Base; properties :foo, :miso; end 
    #   @post = Post.create(:foo => "bar", :miso => "great")
    #   @post.persisted_attributes => { :id => "a1b2c3", :foo => "bar", :miso => "great" }
    #
    def persisted_attributes
      self.attributes.slice(*self.class.properties).reject { |k, v| v.nil? }
    end
    
    # Returns true if YamlRecord instance hasn't persisted; false otherwise
    # 
    # === Example:
    #
    #   @post = Post.new(:foo => "bar", :miso => "great")
    #   @post.new_record?  =>  true
    #   @post.save  => true
    #   @post.new_record?  =>  false
    #
    def new_record?
      !self.is_created
    end

    # Returns true if YamlRecord instance has been destroyed; false otherwise
    # 
    # === Example:
    #
    #   @post = Post.new(:foo => "bar", :miso => "great")
    #   @post.destroyed?  =>  false
    #   @post.save
    #   @post.destroy  => true
    #   @post.destroyed?  =>  true
    #
    def destroyed?
      self.is_destroyed
    end

    # Remove a persisted YamlRecord object
    # Returns true if destroyed; false otherwise
    # 
    # === Example:
    #
    #   @post = Post.create(:foo => "bar", :miso => "great")
    #   Post.all.size => 1
    #   @post.destroy  => true
    #   Post.all.size => 0
    #
    def destroy
      run_callbacks(:before_destroy)
      new_data = self.class.all.reject { |item| item.persisted_attributes == self.persisted_attributes }.map { |item| item.persisted_attributes }
      self.class.write_contents(new_data)
      self.is_destroyed = true
      run_callbacks(:after_destroy)
      true
    rescue IOError
      false
    end
    
    # Execute validations for instance
    # Returns true if record is valid; false otherwise
    # TODO Implement validation
    # 
    # === Example:
    #
    #   @post.valid? => true
    #
    def valid?
      true
    end
    
    # Returns errors messages if record isn't valid; empty array otherwise
    # TODO Implement validation
    # 
    # === Example:
    #
    #   @post.errors => ["Foo can't be blank"]
    #
    def errors
      []
    end
    
    # Returns YamlRecord Instance
    # Complies with ActiveModel api
    # 
    # === Example:
    #
    #   @post.to_model => @post
    #
    def to_model
      self
    end
    
    # Reload YamlRecord instance attributes from file
    # 
    # === Example:
    #
    #   @post = Post.create(:foo => "bar", :miso => "great")
    #   @post.foo = "bazz"
    #   @post.reload
    #   @post.foo => "bar"
    #
    def reload
      record = self.class.find(self.id)
      self.attributes = record.attributes
      record
    end

    # Find YamlRecord instance given attribute name and expected value
    # Returns instance if found; false otherwise
    # 
    # === Example:
    #
    #   Post.find_by_attribute(:foo, "bar")  => @post
    #
    def self.find_by_attribute(attribute, expected_value)
      self.all.find do |record|
        value = record.send(attribute) if record.respond_to?(attribute)
        value.is_a?(Array) ? 
          value.include?(expected_value) :
          value == expected_value
      end
    end
    
    class << self;
      
      # Find YamlRecord instance given id
      # Returns instance if found; false otherwise
      # 
      # === Example:
      #
      #   Post.find_by_id("a1b2c3")  => @post
      #
      def find_by_id(value)
        self.find_by_attribute(:id, value)
      end
      alias :find :find_by_id
    end
    
    # Returns collection of all YamlRecord instances
    # Caches results during request
    # 
    # === Example:
    #
    #   Post.all  => [@post1, @post2, ...]
    #
    def self.all
      @records ||= begin
        raw_items = YAML.load_file(source)
        raw_items ? raw_items.map { |item| self.new(item.merge(:persisted => true)) } : []
      end
    end

    # Find last YamlRecord instance given a limit
    # Returns an array of instances if found; empty otherwise
    # 
    # === Example:
    #
    #   Post.last  => @post6
    #   Post.last(3) => [@p4, @p5, @p6]
    #
    def self.last(limit=1)
      limit == 1 ? self.all.last : self.all.last(limit)
    end

    # Find first YamlRecord instance given a limit
    # Returns an array of instances if found; empty otherwise
    # 
    # === Example:
    #
    #   Post.first  => @post
    #   Post.first(3) => [@p1, @p2, @p3]
    #
    def self.first(limit=1)
      limit == 1 ? self.all.first : self.all.first(limit)
    end
    
    # Initializes YamlRecord instance given an attribute hash and saves afterwards
    # Returns instance if successfully saved; false otherwise
    # 
    # === Example:
    #
    #   Post.create(:foo => "bar", :miso => "great")  => @post
    #
    def self.create(attributes={})
      @fs = self.new(attributes)
      if @fs.save == true 
        @fs.is_created = true;
        @fs
      else
        false
      end
    end
    
    # Declares persisted attributes for YamlRecord class
    # 
    # === Example:
    #
    #   class Post < YamlRecord::Base; properties :foo, :miso; end
    #   Post.create(:foo => "bar", :miso => "great")  => @post
    #
    def self.properties(*names)
      names = names | [:id] if names.size > 0
      names.size == 0 ? @_properties : @_properties = names
    end
    
    # Declares source file for YamlRecord class
    # 
    # === Example:
    #
    #   class Post < YamlRecord::Base 
    #     source "path/to/yaml/file"
    #   end
    #
    def self.source(file=nil)
      file ? @file = (file.to_s + ".yml") : @file
    end
    
    protected
    
    # Validates each persisted attributes
    # TODO Implement validation
    #
    def self.validates_each(*args, &block)
      true
    end
    
    # Write raw yaml data to file
    # Protected method, not called during usage
    # 
    # === Example:
    #
    #   Post.write_content([{ :foo => "bar"}, { :foo => "baz"}, ...]) # writes to source file
    #
    def self.write_contents(raw_data)
      File.open(self.source, 'w') {|f| f.write(raw_data.to_yaml) }
      @records = nil
    end
    
    # Creates reader and writer methods for each persisted attribute
    # Protected method, not called during usage
    # 
    # === Example:
    #
    #   Post.setup_properties!
    #   @post.foo = "baz"
    #   @post.foo => "baz"
    #
    def setup_properties!
     self.class.properties.each do |name|
        self.class_eval do
          define_method(name) { self[name.to_sym] }  # def media; self.attributes[:media]; end
          define_method("#{name}=") { |val| self[name.to_sym] = val  }  # def media; self.attributes[:media]; end
        end
      end
    end
    
    # Assign YamlRecord a unique id if not set
    # Invoke before create of an instance
    #
    def set_id!
      self.id = ActiveSupport::SecureRandom.hex(15)
    end
  end
end