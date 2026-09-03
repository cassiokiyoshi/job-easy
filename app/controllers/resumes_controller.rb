require 'docx'

class ResumesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_resume, only: %i[edit update destroy recommendations dismiss_advice set_as_default]
  def create
    @job_application = JobApplication.find(params[:job_application_id])
    @resume = @job_application.resume || @job_application.build_resume
    @resume.assign_attributes(resume_params)
    authorize @resume

    # extract the uploaded .docx text into content before saving
    if @resume.save
      extract_content(@resume)
      redirect_to edit_resume_path(@resume)
    else
      render "job_applications/show", status: :unprocessable_entity
    end
  end

  def edit
    authorize @resume
    @editor_config = build_editor_config(@resume)
    @advices = visible_advices(@resume)
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

  def set_as_default
    authorize @resume

    @resume.make_default!
    current_user.job_applications.update_all(verdict: nil, verdict_generated_at: nil)
    GenerateVerdictJob.perform_later(@resume.job_application_id)

    redirect_to edit_resume_path(@resume)
  end

  def recommendations
    authorize @resume
    content = Resumes::TextExtractor.new(@resume).call
    @resume.update(content: content)
    job_opening = @resume.job_application.job_opening
    jd = job_opening.content

    chat = RubyLLM.chat.with_schema(AiResponseSchema)
    response = chat.ask(
      "You are a professional tech recruiter with over 10 years of experience. You mainly recruit for new grads and mid-level engineers. I am a newbie who has #{@resume.content} in my resume content. Currently applying for #{job_opening.title} job with the following JD: #{job_opening.content}. Give me precise and brief recommendations. If something is already fulfilled, no need to give recommendation (For example, if their top part of resume is already tech projects, no need to give position recommendations)."
    )
    result = response.content

    @resume.update!(
      ai_response: {
        order_advice: result["order_advice"],
        summary_advice: result["summary_advice"],
        addutional_advice: result["addutional_advice"]
      }
    )

    redirect_to edit_resume_path(@resume)
  end

  def dismiss_advice
    authorize @resume

    ai = @resume.ai_response.to_h
    ai["dismissed"] = (Array(ai["dismissed"]) + [params[:advice_id]]).uniq
    @resume.update!(ai_response: ai)

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove("advice_#{params[:advice_id]}") }
      format.html { redirect_to edit_resume_path(@resume) }
    end
  end

  private

  def set_resume
    @resume = Resume.find(params[:id])
  end

  # Downloads the attached .docx and stores its plain text in content.
  def extract_content(resume)
    # return unless resume.cv_file.attached?

    Tempfile.create(["resume", ".docx"]) do |file|
      file.binmode
      file.write(resume.cv_file.download)
      file.rewind
      resume.update!(content: Docx::Document.open(file.path).text)
    end
  end

  def all_advices(ai_response)
    return [] if ai_response.blank?

    advices = [
      { id: "order", label: "Ordering", body: ai_response["order_advice"] },
      { id: "summary", label: "Summary", body: ai_response["summary_advice"] }
    ]
    Array(ai_response["addutional_advice"]).each_with_index do |body, index|
      advices << { id: "tip_#{index}", label: "Tip", body: body }
    end
    advices.select { |advice| advice[:body].present? }
  end

  def visible_advices(resume)
    dismissed = Array(resume.ai_response.to_h["dismissed"])
    all_advices(resume.ai_response).reject { |advice| dismissed.include?(advice[:id]) }
  end

  def resume_params
    params.require(:resume).permit(:cv_file)
  end

  def build_editor_config(resume)
    config = {
      height: "1000px",
      width: "100%",
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
