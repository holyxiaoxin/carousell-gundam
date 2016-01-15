require 'test_helper'

class GundamsControllerTest < ActionController::TestCase
  test "should get recent" do
    get :recent
    assert_response :success
  end

end
