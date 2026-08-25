class JobApplicationsController < ApplicationController
  def index
    @job_applications = policy_scope(JobApplication)
    @applied = @job_applications.applied
  end

  def show
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
