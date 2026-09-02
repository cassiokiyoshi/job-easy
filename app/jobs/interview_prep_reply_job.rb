class InterviewPrepReplyJob < ApplicationJob
  queue_as :default

  discard_on ActiveRecord::RecordNotFound

  retry_on StandardError,
           wait: :polynomially_longer,
           attempts: 3 do |job, error|
    chat = job.arguments.first

    Rails.logger.error(
      "Interview prep reply failed for chat #{chat.id}: " \
      "#{error.class} - #{error.message}"
    )

    chat.messages.create!(
      role: "assistant",
      content: "Sorry, I couldn't respond just then. Please send that again."
    )

    broadcast_messages(chat)
  end

  def perform(chat)
    Ai::InterviewCoach::ReplyService.new(chat).call
    broadcast_messages(chat)
  end

  private

  def broadcast_messages(chat)
    chat.reload

    Turbo::StreamsChannel.broadcast_replace_to(
      [chat, :messages],
      target: ActionView::RecordIdentifier.dom_id(chat, :messages),
      partial: "interview_prep/sessions/messages",
      locals: { chat: }
    )
  rescue StandardError => e
    Rails.logger.error(
      "Interview prep broadcast failed for chat #{chat.id}: " \
      "#{e.class} - #{e.message}"
    )
  end
end
