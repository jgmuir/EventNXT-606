class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #before_action :authenticate_user!, :except => []
  protect_from_forgery prepend: true, with: :exception

  protected

  def render_not_found
    render file: Rails.root.join('public', '404.html'), status: 404;
  end
end
