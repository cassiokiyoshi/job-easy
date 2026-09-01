require "test_helper"

class ChatTest < ActiveSupport::TestCase
  setup do
    user = User.create!(
      email: "chat-test-#{SecureRandom.hex(4)}@example.com",
      password: "password"
    )

    company = Company.create!(name: "Example Company")
    opening = JobOpening.create!(company:, title: "Developer")

    @application = JobApplication.create!(
      user:,
      job_opening: opening
    )

    @chat = @application.create_chat!
  end

  test "an application can have only one chat" do
    duplicate = Chat.new(job_application: @application)

    assert_not duplicate.valid?
    assert_includes(
      duplicate.errors[:job_application_id],
      "has already been taken"
    )
  end

  test "returns messages in chronological order" do
    later = @chat.messages.create!(
      role: "assistant",
      content: "Second message",
      created_at: Time.current
    )

    earlier = @chat.messages.create!(
      role: "user",
      content: "First message",
      created_at: 1.minute.ago
    )

    assert_equal [earlier, later], @chat.messages.reload.to_a
  end

  test "destroying a chat destroys its messages" do
    message = @chat.messages.create!(
      role: "user",
      content: "Temporary message"
    )

    @chat.destroy!

    assert_not Message.exists?(message.id)
  end
end
