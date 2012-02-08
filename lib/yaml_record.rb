require 'active_support/core_ext/kernel'
require 'active_support/core_ext/class'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/enumerable'
require 'active_support/secure_random'
require 'active_support/callbacks'
require 'yaml'

module YamlRecord
  require File.dirname(__FILE__) + "/yaml_record/base"
  require File.dirname(__FILE__) + "/yaml_record/adapters/redis_store"
  require File.dirname(__FILE__) + "/yaml_record/adapters/local_store"
end
