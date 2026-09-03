class JobApplicationsController < ApplicationController
  def index
    @job_applications = policy_scope(JobApplication)
    @applied = @job_applications.applied
  end

  def show
    @job_application = JobApplication.find(params[:id])
    @job_opening = @job_application.job_opening
    @company = @job_application.job_opening.company
    authorize @job_application

    # completed variable is checking # of interviews that are in the past (integer)
    completed = @job_application.interview_schedule.count(&:past?)
    # if a round has finished that I haven't handled yet
    if completed > @job_application.interviews_processed
      # move status to "Interviewed" if my current status is "Applied"
      @job_application.update(status: "Interviewed") if @job_application.status == "Applied"
      # updating interviews_processed to completed variable
      @job_application.update(interviews_processed: completed)
    end

    @resume = @job_application.resume || @job_application.build_resume
    @chat = @job_application.chats.general.first || @job_application.chats.general.new
    @message = Message.new

    @default_resume = current_user.default_resume
    if @job_application.verdict.blank? && @default_resume.present?
      GenerateVerdictJob.perform_later(@job_application.id)
    end
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
    @job_application = current_user.job_applications.find(params[:id])
    authorize @job_application

    @job_application.destroy!

    redirect_to job_applications_path,
                notice: "Application deleted.",
                status: :see_other
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

  def generate_task
    @job_application = current_user.job_applications
                                   .includes(:tasks, job_opening: :company)
                                   .find(params[:id])
    authorize @job_application, :show?

    suggestion = Ai::TaskSuggestionService.new(@job_application).one_suggestion

    if suggestion
      @job_application.tasks.create!(user: current_user, name: suggestion)
      redirect_to tasks_path, notice: "Task generated."
    else
      redirect_to tasks_path, alert: "No new task could be generated."
    end
  rescue StandardError => e
    Rails.logger.error(
      "Task generation failed for application #{params[:id]}: " \
      "#{e.class} - #{e.message}"
    )
    redirect_to tasks_path, alert: "Task could not be generated. Please try again."
  end

  def clear_completed_tasks
    @job_application = current_user.job_applications.find(params[:id])
    authorize @job_application, :show?

    removed_count = @job_application.tasks.where(completed: true).destroy_all.size

    redirect_to job_application_path(@job_application),
                notice: "#{removed_count} completed task(s) cleared.",
                status: :see_other
  end

  def schedule_interview
    @job_application = current_user.job_applications.find(params[:id])
    authorize @job_application, :update?

    interview_at = parse_interview_time(params[:interview_at])
    if interview_at.nil?
      redirect_to job_application_path(@job_application), status: :see_other
    else
      @job_application.add_interview(interview_at)
      Ai::TaskRefreshService.new(@job_application).call
      redirect_to job_application_path(@job_application), status: :see_other
    end
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

  def parse_interview_time(value)
    return nil if value.blank?

    Time.zone.parse(value.to_s)
  end
end
