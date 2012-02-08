require File.expand_path('../instance_methods', __FILE__)
require File.expand_path('../class_methods', __FILE__)

module YamlRecord
  class Base
    include YamlRecord::InstanceMethods
    extend YamlRecord::ClassMethods

    # Adds attribute support with validations
    include Virtus
    # Allow attribute and property to be used interchangeably
    instance_eval { alias :property :attribute }
    # Add :id property to every YamlRecord
    property :id, Integer

    # Tracks major state changes to a record
    attr_accessor :is_created, :is_destroyed

    # Setup possible callbacks to be invoked at different times within a record
    include ActiveSupport::Callbacks
    define_callbacks :before_save, :after_save, :before_destroy, :after_destroy, :before_validation, :before_create, :after_create

    # Assign an id when a record is created
    before_create :set_id!

    protected

    # Assign YamlRecord a unique id if not set
    # Invoked before creaion of an instance
    # Protected method, never called directly
    #
    def set_id!
      self.id = ActiveSupport::SecureRandom.hex(15)
    end
  end # Base
end # YamlRecord