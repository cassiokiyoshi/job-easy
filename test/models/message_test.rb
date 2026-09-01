require "test_helper"

class MessageTest < ActiveSupport::TestCase
  setup do
    user = User.create!(
      email: "message-test-#{SecureRandom.hex(4)}@example.com",
      password: "password"
    )

    company = Company.create!(name: "Example Company")
    opening = JobOpening.create!(company:, title: "Developer")
    application = JobApplication.create!(user:, job_opening: opening)

    @chat = application.create_chat!
  end

  test "accepts supported roles" do
    Message::ROLES.each do |role|
      message = @chat.messages.build(role:, content: "Hello")

      assert message.valid?, "Expected #{role} to be valid"
    end
  end

  test "rejects unsupported roles" do
    message = @chat.messages.build(role: "unknown", content: "Hello")

    assert_not message.valid?
    assert_includes message.errors[:role], "is not included in the list"
  end

  test "requires content" do
    message = @chat.messages.build(role: "user", content: "")

    assert_not message.valid?
    assert_includes message.errors[:content], "can't be blank"
  end
end
