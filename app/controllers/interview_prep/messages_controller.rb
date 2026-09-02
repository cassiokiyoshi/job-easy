module InterviewPrep
  class MessagesController < ApplicationController
    def create
      @job_application = current_user.job_applications
                                     .find(params[:job_application_id])
      authorize @job_application, :show?

      @chat = @job_application.chats.interview_prep.first ||
              @job_application.chats.interview_prep.new
      @message = @chat.messages.new(message_params.merge(role: "user"))

      if @message.valid?
        Chat.transaction do
          @chat.save!
          @message.save!
        end

        generate_reply

        redirect_to job_application_interview_session_path(@job_application),
                    status: :see_other
      else
        redirect_to job_application_interview_session_path(@job_application),
                    alert: @message.errors.full_messages.to_sentence,
                    status: :see_other
      end
    end

    private

    def generate_reply
      Ai::InterviewCoach::ReplyService.new(@chat).call
    rescue StandardError => e
      Rails.logger.error(
        "Interview coach reply failed for chat #{@chat.id}: #{e.class} - #{e.message}"
      )

      @chat.messages.create!(
        role: "assistant",
        content: "Sorry, I couldn't respond just then. Please send that again."
      )
    end

    def message_params
      params.require(:message).permit(:content)
    end
  end
end
