unless Array.method_defined?(:each_with_object)
  module Enumerable
    def each_with_object(memo, &block)
      each do |element|
        block.call(element, memo)
      end
      memo
    end
  end
end