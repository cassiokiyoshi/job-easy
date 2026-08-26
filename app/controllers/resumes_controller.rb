class ResumesController < ApplicationController
  before_action :set_resume, only: %i[edit update destroy recommendations]
  def create
    @job_application = JobApplication.find(params[:job_application_id])
    @resume = Resume.new(resume_params)
    @resume.job_application = @job_application
    authorize @resume

    if @resume.save
      redirect_to edit_resume_path(@resume)
    else
      flash.now[:alert] = @resume.errors.full_messages.to_sentence
      render "job_applications/show", status: :unprocessable_entity
    end
  end

  def edit
    authorize @resume
    @editor_config = build_editor_config(@resume)
  end

  def update
  end

  def destroy
  end

  def recommendations
  end

  private

  def set_resume
    @resume = Resume.find(params[:id])
  end

  def resume_params
    params.require(:resume).permit(:cv_file)
  end

  def build_editor_config(resume)
    config = {
      document: {
        fileType: "docx",
        key: resume.onlyoffice_key,
        title: resume.cv_file.filename.to_s,
        url: url_for(resume.cv_file),
        permissions: { edit: true, download: true }
      },
      documentType: "word",
      editorConfig: {
        callbackUrl: api_resume_callback_url(resume, token: resume.callback_token),
        user: { id: current_user.id.to_s, name: current_user.email }
      }
    }
    config[:token] = JWT.encode(config, ONLYOFFICE_CONFIG[:jwt_secret], "HS256")
    config
  end
end
