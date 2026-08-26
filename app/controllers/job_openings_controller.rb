class JobOpeningsController < ApplicationController
  def index
    @job_openings = JobOpening.all
    @job_openings = policy_scope(JobOpening)
  end

  def show
    @job_opening = JobOpening.find(params[:id])
    @company = @job_opening.company
    authorize @job_opening
  end
end
