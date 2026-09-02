module Ai
  module InterviewCoach
    # Produces the coach's next reply for an interview prep chat. Mirrors
    # Ai::ApplicationChatService: build instructions, replay recent history,
    # complete, persist the assistant message. Stage progression is left to the
    # model in the prompt - nothing is tracked in the database.
    class ReplyService
      # A full mock interview (opening + ~15 Q&A pairs + feedback) fits well
      # under this. The model needs the whole interview in view to know which of
      # the five areas it has covered and when to stop.
      MAX_HISTORY_MESSAGES = 80

      class EmptyResponseError < StandardError; end

      def initialize(chat, llm: RubyLLM)
        @chat = chat
        @llm = llm
      end

      def call
        response = llm_chat.complete
        content = response.content.to_s.strip

        raise EmptyResponseError, "The AI returned an empty response" if content.blank?

        chat.messages.create!(role: "assistant", content:)
      end

      private

      attr_reader :chat, :llm

      def llm_chat
        conversation = llm.chat.with_instructions(PromptBuilder.new(chat).system_prompt)

        recent_messages.each do |message|
          conversation.add_message(
            role: message.role.to_sym,
            content: message.content
          )
        end

        conversation
      end

      def recent_messages
        chat.messages.last(MAX_HISTORY_MESSAGES)
      end
    end
  end
end
