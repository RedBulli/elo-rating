class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :verify_logged_in unless Rails.env.development?
  skip_before_filter :verify_authenticity_token if Rails.env.development?

  private

  def verify_logged_in
    authenticate_or_request_with_http_basic do |nick, pass|
      nick == (ENV['USERNAME'] || 'user') && pass == (ENV['PASSWORD'] || 'password')
    end
  end
end
