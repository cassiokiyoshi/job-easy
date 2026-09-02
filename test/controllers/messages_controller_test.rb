require "test_helper"

class MessagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create_user("message-owner")
    @application = create_application_for(@user)
  end

  test "owner can create a user message" do
    sign_in @user

    assert_enqueued_jobs 1, only: ApplicationChatReplyJob do
      assert_difference ["Chat.count", "Message.count"], 1 do
        post job_application_chat_messages_path(@application),
            params: { message: { content: "Help me prepare" } }
      end
    end

    assert_redirected_to job_application_chat_path(@application)

    message = @application.reload.chats.general.first.messages.last
    assert_equal "user", message.role
    assert_equal "Help me prepare", message.content
end
  test "blank content does not create a chat or message" do
    sign_in @user

    assert_no_difference ["Chat.count", "Message.count"] do
      post job_application_chat_messages_path(@application),
           params: { message: { content: "" } }
    end

    assert_response :unprocessable_entity
  end

  test "another user cannot post to the application chat" do
    sign_in create_user("other-message-user")

    assert_no_difference ["Chat.count", "Message.count"] do
      post job_application_chat_messages_path(@application),
           params: { message: { content: "Unauthorized message" } }
    end

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
