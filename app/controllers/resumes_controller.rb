class ResumesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_job_application, only: :create
  before_action :set_resume, only: %i[edit update destroy recommendations]

  def create
    @resume = @job_application.build_resume(resume_params)
    authorize @resume

    if @resume.save
      redirect_to edit_resume_path(@resume)
    else
      render "job_applications/show", status: :unprocessable_entity
    end
  end

  def edit
    authorize @resume
  end

  def update
    authorize @resume

    if @resume.update(resume_params)
      redirect_to edit_resume_path(@resume)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @resume
    @resume.destroy!

    redirect_to job_application_path(@job_application), status: :see_other
  end

  def recommendations
    authorize @resume
  end

  private

  def set_job_application
    @job_application = policy_scope(JobApplication)
                       .find(params[:job_application_id])
  end

  def resume_params
    params.require(:resume).permit(:content, :cv_file)
  end

  def set_resume
    @resume = policy_scope(Resume).find(params[:id])
    @job_application = @resume.job_application
  end
end
