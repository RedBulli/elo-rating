class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :verify_logged_in

  private

  def verify_logged_in
    authenticate_or_request_with_http_basic do |nick, pass|
      nick == (ENV['USERNAME'] || 'user') and pass == (ENV['PASSWORD'] || 'password')
    end
  end
end
