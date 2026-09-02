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

        InterviewPrepReplyJob.perform_later(@chat)

        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: turbo_stream.replace(
              ActionView::RecordIdentifier.dom_id(@chat, :messages),
              partial: "interview_prep/sessions/messages",
              locals: { chat: @chat }
            )
          end
          format.html do
            redirect_to job_application_interview_session_path(@job_application),
                        status: :see_other
          end
        end
      else
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: turbo_stream.replace(
              ActionView::RecordIdentifier.dom_id(@chat, :interview_chat),
              partial: "interview_prep/sessions/chat",
              locals: {
                job_application: @job_application,
                chat: @chat,
                message: @message
              }
            ), status: :unprocessable_entity
          end
          format.html do
            redirect_to job_application_interview_session_path(@job_application),
                        alert: @message.errors.full_messages.to_sentence,
                        status: :see_other
          end
        end
      end
    end

    private

    def message_params
      params.require(:message).permit(:content)
    end
  end
end
