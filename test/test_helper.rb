require 'test/unit'

require 'rubygems'
require 'shoulda'

require 'active_support'
require 'action_pack'
require 'action_controller'
require 'action_view'
require 'action_view/test_case'
require 'action_controller/test_process'

require "#{ File.dirname(__FILE__) }/../lib/table_builder"

class Drummer < Struct.new(:id, :name); end
class Event < Struct.new(:id, :name, :date); end

# Stub!!
module ActiveRecord
  module NamedScope
    class Scope < Array; end
  end
end
