require "test_helper"

class Ai::ApplicationChatServiceTest < ActiveSupport::TestCase
  class FakeConversation
    attr_reader :instructions, :messages

    def initialize(response_content:)
      @response_content = response_content
      @messages = []
    end

    def with_instructions(instructions)
      @instructions = instructions
      self
    end

    def add_message(attributes)
      @messages << attributes
    end

    def complete
      Struct.new(:content).new(@response_content)
    end
  end

  class FakeLlm
    def initialize(conversation)
      @conversation = conversation
    end

    def chat
      @conversation
    end
  end

  setup do
    user = User.create!(
      email: "chat-service-#{SecureRandom.hex(4)}@example.com",
      password: "password"
    )

    company = Company.create!(
      name: "Example Company",
      description: "A software company"
    )

    opening = JobOpening.create!(
      company:,
      title: "Rails Developer",
      content: "Build and maintain Rails applications"
    )

    application = JobApplication.create!(
      user:,
      job_opening: opening,
      status: "Applied"
    )

    @chat = application.chats.general.create!

    @chat.messages.create!(
      role: "user",
      content: "How should I prepare?"
    )
  end

  test "sends application context and history to the LLM" do
    fake_conversation = FakeConversation.new(
      response_content: "Review Rails fundamentals and prepare project examples."
    )

    fake_llm = FakeLlm.new(fake_conversation)
      assert_difference "Message.count", 1 do
      Ai::ApplicationChatService.new(@chat, llm: fake_llm).call
    end

    assert_includes fake_conversation.instructions, "Rails Developer"
    assert_includes fake_conversation.instructions, "Example Company"
    assert_includes fake_conversation.instructions, "Applied"

    assert_equal(
      [{ role: :user, content: "How should I prepare?" }],
      fake_conversation.messages
    )

    assistant_message = @chat.messages.last

    assert_equal "assistant", assistant_message.role
    assert_equal(
      "Review Rails fundamentals and prepare project examples.",
      assistant_message.content
    )
  end

  test "does not persist an empty assistant response" do
    fake_conversation = FakeConversation.new(response_content: "   ")
    fake_llm = FakeLlm.new(fake_conversation)

    assert_no_difference "Message.count" do
      assert_raises Ai::ApplicationChatService::EmptyResponseError do
        Ai::ApplicationChatService.new(@chat, llm: fake_llm).call
      end
    end
  end


  test "includes temporary task content in the application context" do
    fake_conversation = FakeConversation.new(
      response_content: "Start by tailoring the resume."
    )
    fake_llm = FakeLlm.new(fake_conversation)

    Ai::ApplicationChatService.new(
      @chat,
      llm: fake_llm,
      task_context: "Tailor resume for this role"
    ).call

    assert_includes fake_conversation.instructions, "focused_task"
    assert_includes fake_conversation.instructions, "Tailor resume for this role"
  end
end
