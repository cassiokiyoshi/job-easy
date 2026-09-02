require "test_helper"

module InterviewPrep
  class MessagesControllerTest < ActionDispatch::IntegrationTest
    setup do
      @user = User.create!(
        email: "interview-message-#{SecureRandom.hex(4)}@example.com",
        password: "password"
      )
      company = Company.create!(name: "Example Company")
      opening = JobOpening.create!(company:, title: "Developer")
      @application = JobApplication.create!(user: @user, job_opening: opening)
      @chat = @application.chats.interview_prep.create!
    end

    test "creates the user message and immediately renders the pending conversation" do
      sign_in @user

      assert_enqueued_jobs 1, only: InterviewPrepReplyJob do
        assert_difference "Message.count", 1 do
          post job_application_interview_session_messages_path(@application),
               params: { message: { content: "I am ready" } },
               as: :turbo_stream
        end
      end

      assert_response :success
      assert_includes response.body, "I am ready"
      assert_includes response.body, "Thinking…"
      assert_includes response.media_type, "turbo-stream"
    end
  end
end
