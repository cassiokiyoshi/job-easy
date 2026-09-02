class MessagesController < ApplicationController
  def create
    @job_application = current_user.job_applications
                                   .find(params[:job_application_id])

    authorize @job_application, :show?

    @chat = @job_application.chats.general.first || @job_application.chats.general.new
    @message = @chat.messages.build(message_params.merge(role: "user"))

    if @message.valid?
      Chat.transaction do
        @chat.save!
        @message.save!
      end

      ApplicationChatReplyJob.perform_later(@chat)

      redirect_to message_redirect_path,
                  notice: "Message sent. JobEasy is preparing a reply.",
                  status: :see_other
    else
      render "chats/show", status: :unprocessable_entity
    end
  end

  private

  def message_redirect_path
    if params[:return_to] == "application"
      job_application_path(@job_application, chat: "open")
    else
      job_application_chat_path(@job_application)
    end
  end

  def message_params
    params.require(:message).permit(:content)
  end
end
