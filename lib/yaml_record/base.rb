module YamlRecord
  class Base  
    attr_accessor :attributes, :is_created, :is_destroyed 
    
    include ActiveSupport::Callbacks
    define_callbacks :before_save, :after_save, :before_destroy, :after_destroy, :before_validation, :before_create, :after_create
    
    before_create :set_id!

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

    # @featured['media']
    def [](attribute)
      self.attributes[attribute]
    end

    def []=(attribute, value)
      self.attributes[attribute] = value
    end

    # @featured_section.save #=> should return FeaturedSection obj if it's saved
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

    def update_attributes(updated_attrs={})
      updated_attrs.each { |k,v| self.send("#{k}=", v) }
      self.save
    end

    def valid?
      true
    end

    def errors
      []
    end

    def column_names
      array = []
      self.attributes.each_key { |k| array << k.to_s }
      array
    end

    def persisted_attributes
      self.attributes.slice(*self.class.properties).reject { |k, v| v.nil? }
    end

    def new_record?
      !self.is_created
    end

    def destroyed?
      self.is_destroyed
    end

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

    def to_model
      self
    end

    def reload
      record = self.class.find(self.id)
      self.attributes = record.attributes
      record
    end

    # find_by_attribute(:media, 5)
    # find_by_attribute(:media_ids, 5)
    def self.find_by_attribute(attribute, expected_value)
      self.all.find do |record|
        value = record.send(attribute) if record.respond_to?(attribute)
        value.is_a?(Array) ? 
          value.include?(expected_value) :
          value == expected_value
      end
    end
    
    class << self;
      def find_by_id(value)
        self.find_by_attribute(:id, value)
      end
      alias :find :find_by_id
    end

    def self.all
      @records ||= begin
        raw_items = YAML.load_file(source)
        raw_items ? raw_items.map { |item| self.new(item.merge(:persisted => true)) } : []
      end
    end

    # FeaturedSection.last #=> @fs
    # FeaturedSection.last(2) #=> [@fs, @fs2]
    def self.last(limit=1)
      limit == 1 ? self.all.last : self.all.last(limit)
    end

    # FeaturedSection.first #=> @fs
    # FeaturedSection.first(2) #=> [@fs, @fs2]
    def self.first(limit=1)
      limit == 1 ? self.all.first : self.all.first(limit)
    end

    def self.write_contents(raw_data)
      File.open(self.source, 'w') {|f| f.write(raw_data.to_yaml) }
      @records = nil
    end

    def self.create(attributes={})
      @fs = self.new(attributes)
      if @fs.save == true 
        @fs.is_created = true;
        @fs
      else
        false
      end
    end
    
    # properties :foo, :bar
    # Defines a set of expected columns that are populated for each record
    def self.properties(*names)
      names = names | [:id] if names.size > 0
      names.size == 0 ? @_properties : @_properties = names
    end
    
    # source 'foo' => <root>/foo.yml 
    # source => <root>/foo.yml 
    def self.source(file=nil)
      file ? @file = (file.to_s + ".yml") : @file
    end
    
    def self.validates_each(*args, &block)
      true
    end
    
    def setup_properties!
     self.class.properties.each do |name|
        self.class_eval do
          define_method(name) { self[name.to_sym] }  # def media; self.attributes[:media]; end
          define_method("#{name}=") { |val| self[name.to_sym] = val  }  # def media; self.attributes[:media]; end
        end
      end
    end
    
    protected
    def set_id!
      self.id = ActiveSupport::SecureRandom.hex(15) 
    end
  end
end