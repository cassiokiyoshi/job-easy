class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  include Pundit::Authorization

  # Pundit: allow-list approach
  after_action :verify_authorized,
               if: -> { action_name != "index" },
               unless: :skip_pundit?

  after_action :verify_policy_scoped,
               if: -> { action_name == "index" },
               unless: :skip_pundit?

  private

  def skip_pundit?
    devise_controller? || params[:controller] =~ /(^(rails_)?admin)|(^pages$)/
  end
end
