class JobApplicationsController < ApplicationController
  def index
    @job_applications = policy_scope(JobApplication)
    @applied = @job_applications.applied
  end

  def show
    @job_application = JobApplication.find(params[:id])
    @resume = @job_application.resume || @job_application.build_resume
    authorize @job_application
  end

  def create
    # triggered by job_opening show page
    # created Job Application instance
    # redirect to Job Application show page
    @job_application = JobApplication.new
    @job_opening = JobOpening.find(params[:job_opening_id])
    @job_application.job_opening = @job_opening
    @job_application.user = current_user
    authorize @job_application
    @job_application.save
    redirect_to job_application_path(@job_application)
  end

  def update
    @job_application = JobApplication.find(params[:id])
    authorize @job_application
    if @job_application.update(job_application_params)
      redirect_to job_application_path(@job_application), notice: "Status updated."
    else
      redirect_to job_application_path(@job_application), alert: @job_application.errors.full_messages.to_sentence
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

    suggestions = Ai::TaskSuggestionService.new(@job_application).call

    existing_names = @job_application.tasks.pluck(:name).map do |name|
      name.to_s.squish.downcase
    end

    new_suggestions = suggestions
                      .map { |suggestion| suggestion.to_s.squish }
                      .reject(&:blank?)
                      .uniq { |suggestion| suggestion.downcase }
                      .reject do |suggestion|
                        existing_names.include?(suggestion.downcase)
                      end

    Task.transaction do
      new_suggestions.each do |suggestion|
        task = current_user.tasks.build(
          name: suggestion.to_s.squish.truncate(140),
          job_application: @job_application
        )

        authorize task, :create?
        task.save!
      end
    end

    message =
      if new_suggestions.any?
        "#{new_suggestions.size} AI-generated task(s) saved."
      else
        "No new tasks were generated."
      end

    redirect_to tasks_path, notice: message
  rescue StandardError => e
    Rails.logger.error(
      "Task generation failed for application #{params[:id]}: " \
      "#{e.class} - #{e.message}"
    )

    redirect_to job_application_path(params[:id]),
                alert: "Tasks could not be generated. Please try again."
  end

  private

  def job_application_params
    params.require(:job_application).permit(:status)
  end
end
