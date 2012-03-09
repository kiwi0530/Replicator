require File.dirname(__FILE__) + '/../test_helper'
require 'replicator_controller'

class ReplicatorController; def rescue_action(e) raise e end; end

class ReplicatorControllerApiTest < Test::Unit::TestCase
  def setup
    @controller = ReplicatorController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
end
