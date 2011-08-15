require 'rubygems'
require 'test/unit'
require 'shoulda'
require File.dirname(__FILE__) + "/../lib/yaml_record"

class Test::Unit::TestCase
  def clean_yaml_record(class_record)
    File.open(class_record.source, 'w') {|f| f.write(nil) }
  end

  # Asserts that the condition is not true
  # assert_false @title == "hey"
  def assert_false(condition, message='')
    assert !condition, message
  end
end
