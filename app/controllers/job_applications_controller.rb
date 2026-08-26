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

  private

  def job_application_params
    params.require(:job_application).permit(:status)
  end
end
