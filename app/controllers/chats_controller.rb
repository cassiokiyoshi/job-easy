class ChatsController < ApplicationController
  def show
    @job_application = current_user.job_applications
                                   .includes(chat: :messages)
                                   .find(params[:job_application_id])

    authorize @job_application, :show?

    @chat = @job_application.chat || @job_application.build_chat
    @message = Message.new
  end
end
