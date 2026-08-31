require "test_helper"

class ChatsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create_user("chat-owner")
    @application = create_application_for(@user)
  end

  test "owner can view application chat" do
    sign_in @user

    get job_application_chat_path(@application)

    assert_response :success
  end

  test "another user cannot view application chat" do
    sign_in create_user("other-chat-user")

    get job_application_chat_path(@application)

    assert_response :not_found
  end

  private

  def create_user(prefix)
    User.create!(
      email: "#{prefix}-#{SecureRandom.hex(4)}@example.com",
      password: "password"
    )
  end

  def create_application_for(user)
    company = Company.create!(name: "Example Company")
    opening = JobOpening.create!(company:, title: "Developer")

    JobApplication.create!(user:, job_opening: opening)
  end
end
