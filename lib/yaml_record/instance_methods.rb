module YamlRecord
  module InstanceMethods
    # Constructs a new YamlRecord instance based on specified attribute hash
    #
    # === Example:
    #
    #   class Post < YamlRecord::Base; properties :foo; end
    #
    #   Post.new(:foo  => "bar")
    #
    def initialize(attr_hash={})
      self.is_created = attr_hash.delete(:persisted) || false
      super
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
      self.attributes = updated_attrs
      self.save
    end

    # Returns array of instance attributes names; An attribute is a value stored for this record (persisted or not)
    #
    # === Example:
    #
    #   @post.column_names => ["foo", "miso"]
    #
    def column_names
      cols = []
      self.attributes.each_key { |k| cols << k.to_s unless cols.include?(k.to_s) }
      cols
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
      self.attributes.slice(*self.column_names.map(&:to_sym)).reject { |k, v| v.nil? }
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

    # Returns the instance of a record as a parameter
    # By default return an id
    #
    # === Example:
    #
    #   @post.to_param => <id>
    #
    def to_param
      self.id
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

    # Overrides equality to match if records have matching ids
    #
    def ==(comparison_record)
      self.id == comparison_record.id
    end
  end # InstanceMethods
end # YamlRecord