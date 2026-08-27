class Api::ResumesController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!, raise: false
  skip_after_action :verify_authorized # ← add

  def callback
    resume = Resume.find(params[:id])
    return head :forbidden unless params[:token] == resume.callback_token

    body = JSON.parse(request.body.read)
    verify_jwt!(body)

    ResumeSaveJob.perform_later(resume.id, body["url"]) if [2, 6].include?(body["status"])

    render json: { error: 0 }
  rescue JWT::DecodeError
    render json: { error: 1 }, status: :unauthorized
  end

  private

  def verify_jwt!(body)
    token = request.headers[ONLYOFFICE_CONFIG[:jwt_header]]&.gsub("Bearer ", "") || body["token"]
    JWT.decode(token, ONLYOFFICE_CONFIG[:jwt_secret], true, algorithm: "HS256")
  end
end
