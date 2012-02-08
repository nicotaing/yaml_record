module YamlRecord
  module ClassMethods
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

    # Find YamlRecord instance given attribute name and expected value
    # Supports checking inclusion for array based values
    # Returns instance if found; false otherwise
    #
    # === Example:
    #
    #   Post.find_by_attribute(:foo, "bar")         => @post
    #   Post.find_by_attribute(:some_list, "item")  => @post
    #
    def find_by_attribute(attribute, expected_value)
      self.all.find do |record|
        value = record.send(attribute) if record.respond_to?(attribute)
        value.is_a?(Array) ?
          value.include?(expected_value) :
          value == expected_value
      end
    end # find_by_attribute

    # Returns collection of all YamlRecord instances
    # Caches results during request
    #
    # === Example:
    #
    #   Post.all  => [@post1, @post2, ...]
    #   Post.all(true) => (...force reload...)
    #
    def all
      raw_items = YAML.load_file(source) || []
      raw_items.map { |item| self.new(item.merge(:persisted => true)) }
    end

    # Find first YamlRecord instance given a limit
    # Returns an array of instances if found; empty otherwise
    #
    # === Example:
    #
    #   Post.first  => @post
    #   Post.first(3) => [@p1, @p2, @p3]
    #
    def first(limit=1)
      limit == 1 ? self.all.first : self.all.first(limit)
    end

    # Find last YamlRecord instance given a limit
    # Returns an array of instances if found; empty otherwise
    #
    # === Example:
    #
    #   Post.last  => @post6
    #   Post.last(3) => [@p4, @p5, @p6]
    #
    def last(limit=1)
      limit == 1 ? self.all.last : self.all.last(limit)
    end

    # Initializes YamlRecord instance given an attribute hash and saves afterwards
    # Returns instance if successfully saved; false otherwise
    #
    # === Example:
    #
    #   Post.create(:foo => "bar", :miso => "great")  => @post
    #
    def create(attributes={})
      @fs = self.new(attributes)
      if @fs.save == true
        @fs.is_created = true;
        @fs
      else
        false
      end
    end

    # Establishes multiple attributes of type Object in a single declaration.
    #
    # === Example:
    #
    #   class Post < YamlRecord::Base; properties :foo, :miso; end
    #   Post.create(:foo => "bar", :miso => "great")  => @post
    #
    def properties(*names)
      names.each do |name|
        attribute name, Object
      end
    end

    # Returns the names of the attributes for this type of record.
    #
    # === Example:
    #
    # Post.attribute_names => [:id, :age, :name]
    #
    def attribute_names
      names = []
      self.attributes.each { |a| names << a.name }
      names
    end

    # Declares source file for YamlRecord class
    #
    # === Example:
    #
    #   class Post < YamlRecord::Base
    #     source "path/to/yaml/file"
    #   end
    #
    def source(file=nil)
      file ? @file = (file.to_s + ".yml") : @file
    end

    # Write raw yaml data to file
    # Protected method, not called during usage
    #
    # === Example:
    #
    #   Post.write_content([{ :foo => "bar"}, { :foo => "baz"}, ...]) # writes to source file
    #
    def write_contents(raw_data)
      File.open(self.source, 'w') {|f| f.write(raw_data.to_yaml) }
      @records = nil
    end

    protected

    # Validates each persisted attributes
    # TODO Implement validation
    #
    def validates_each(*args, &block)
      true
    end
  end # ClassMethods
end # YamlRecord