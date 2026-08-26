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
    authorize @job_application
  end

  def update
    authorize @job_application
  end

  def destroy
    authorize @job_application
  end
end
