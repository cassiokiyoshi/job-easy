class ChatsController < ApplicationController
  def show
    @job_application = current_user.job_applications
                                   .find(params[:job_application_id])

    authorize @job_application, :show?

    @chat = @job_application.chats.general.first || @job_application.chats.general.new
    @message = Message.new
  end
end
