class JobApplicationsController < ApplicationController
  def index
    @job_applications = policy_scope(JobApplication)
    @applied = @job_applications.applied
  end

  def show
    @job_application = JobApplication.find(params[:id])
    @company = @job_opening.company
    @resume = @job_application.resume || @job_application.build_resume
    authorize @job_application
    @chat = @job_application.chat || @job_application.build_chat
    @message = Message.new
  end

  def create
    @job_opening = JobOpening.find(params[:job_opening_id])
    @company = @job_opening.company
    @job_application = current_user.job_applications.build(
      job_opening: @job_opening
    )

    authorize @job_application

    unless @job_application.save
      redirect_to job_opening_path(@job_opening),
                  alert: @job_application.errors.full_messages.to_sentence
      return
    end

    begin
      Ai::TaskRefreshService.new(@job_application).call

      redirect_to job_application_path(@job_application),
                  notice: "Application saved and tasks generated."
    rescue StandardError => e
      log_task_refresh_error(e)

      redirect_to job_application_path(@job_application),
                  alert: @job_application.errors.full_messages.to_sentence,
                  status: :see_other
    end
  end

  def update
    @job_application = JobApplication.find(params[:id])
    authorize @job_application

    unless @job_application.update(job_application_params)
      redirect_to job_application_path(@job_application),
                  alert: @job_application.errors.full_messages.to_sentence
      return
    end

    unless @job_application.saved_change_to_status?
      redirect_to job_application_path(@job_application),
                  notice: "Application updated.",
                  status: :see_other
      return
    end

    begin
      Ai::TaskRefreshService.new(@job_application).call

      redirect_to job_application_path(@job_application),
                  notice: "Status updated and tasks refreshed.",
                  status: :see_other
    rescue StandardError => e
      log_task_refresh_error(e)

      redirect_to job_application_path(@job_application),
                  alert: "Status updated, but tasks could not be refreshed.",
                  status: :see_other
    end
  end

  def destroy
    authorize @job_application
  end

  def suggest_tasks
    @job_application = current_user.job_applications
                                   .includes(:tasks, job_opening: :company)
                                   .find(params[:id])

    authorize @job_application, :show?

    plan = Ai::TaskRefreshService.new(@job_application).call

    redirect_to tasks_path,
                notice: "#{plan[:suggestions].size} new task(s) created. Tasks refreshed."
  rescue StandardError => e
    Rails.logger.error(
      "Task refresh failed for application #{params[:id]}: " \
      "#{e.class} - #{e.message}"
    )

    redirect_to job_application_path(params[:id]),
                alert: "Tasks could not be refreshed. Please try again."
  end

  private

  def job_application_params
    params.require(:job_application).permit(:status)
  end

  def log_task_refresh_error(error)
    Rails.logger.error(
      "Task refresh failed for application #{@job_application.id}: " \
      "#{error.class} - #{error.message}"
    )
  end
end
