# YAML Adapter for using a local file store

module YamlRecord
  module Adapters
    class LocalStore

      # Returns YAML File as ruby collection
      #
      # === Example:
      #
      #   @adapter.read("foo") => [{...}, {...}]
      #
      def read(source)
        YAML.load_file(source)
      end

      # Writes ruby collection as YAML File
      #
      # === Example:
      #
      #   @adapter.write("foo", [{...}, {...}]) => "<yaml data>"
      #
      def write(source, collection)
        File.open(source, 'w') {|f| f.write(collection.to_yaml) }
      end
    end
  end
end