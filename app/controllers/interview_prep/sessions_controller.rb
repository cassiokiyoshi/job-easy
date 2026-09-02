module InterviewPrep
  class SessionsController < ApplicationController
    # Picker: the user's applications to prep for.
    def index
      @job_applications = policy_scope(JobApplication)
                          .includes(job_opening: :company)
                          .order(created_at: :desc)
    end

    # A prep session for one application: the coached chat.
    def show
      @job_application = current_user.job_applications
                                     .includes(job_opening: :company)
                                     .find(params[:job_application_id])
      authorize @job_application, :show?

      @chat = interview_chat
      @message = Message.new
    end

    private

    # Returns the application's interview prep chat, creating it with its opening
    # message on first visit. The message is created in the same transaction as
    # the chat and only for the request that wins the race, so concurrent loads
    # (Turbo prefetch + click) cannot seed it twice.
    def interview_chat
      @job_application.chats.interview_prep.first || create_interview_chat
    end

    def create_interview_chat
      @job_application.chats.interview_prep.create!.tap do |chat|
        chat.messages.create!(
          role: "assistant",
          content: Ai::InterviewCoach::PromptBuilder.new(chat).opening_message
        )
      end
    rescue ActiveRecord::RecordNotUnique
      @job_application.chats.interview_prep.first!
    end
  end
end
