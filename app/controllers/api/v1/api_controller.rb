class Api::V1::ApiController < ActionController::API
  # todo: uncomment if everything integrates well
  before_action :set_default_response
  helper_method :current_user
  prepend_view_path Rails.root.join('app', 'views', 'api', 'v1')

  private
  
  def set_default_response
    request.format = :json unless params[:format]
  end

  def current_user
    @current_user ||= User.find_by(id: doorkeeper_token[:resource_owner_id]) if doorkeeper_token
  end
end