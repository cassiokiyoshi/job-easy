class JobOpeningsController < ApplicationController
  def index
    scope = policy_scope(JobOpening).ordered
    scope = scope.where(source: params[:source]) if params[:source].present?

    @job_openings = scope.open
    @job_openings_closed = scope.close
    @sources = policy_scope(JobOpening).distinct.pluck(:source).compact.sort
    @current_source = params[:source]
  end

  def show
    @job_opening = JobOpening.find(params[:id])
    @company = @job_opening.company
    @job_application = current_user.job_applications.find_by(job_opening: @job_opening)
    authorize @job_opening
  end
end
