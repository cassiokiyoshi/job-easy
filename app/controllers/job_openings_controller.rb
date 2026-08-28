class JobOpeningsController < ApplicationController
  def index
    @job_openings = policy_scope(JobOpening).ordered.open
    @job_openings_closed = policy_scope(JobOpening).ordered.close
  end

  def show
    @job_opening = JobOpening.find(params[:id])
    @company = @job_opening.company
    @job_application = current_user.job_applications.find_by(job_opening: @job_opening)
    authorize @job_opening
  end
end
