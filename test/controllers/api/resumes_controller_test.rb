require "test_helper"

class Api::ResumesControllerTest < ActionDispatch::IntegrationTest
  test "should get callback" do
    get api_resumes_callback_url
    assert_response :success
  end
end
