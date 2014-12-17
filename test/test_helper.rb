require 'minitest/autorun'
require 'shoulda'
require 'yaml_record'

class Minitest::Test
  def clean_yaml_record(class_record)
    File.open(class_record.source, 'w') {|f| f.write(nil) }
  end

  # Asserts that the condition is not true
  # assert_false @title == "hey"
  def assert_false(condition, message=nil)
    assert !condition, message
  end
end
