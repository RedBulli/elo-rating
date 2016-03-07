module AuthHelper
  def http_login
    ENV['USERNAME'] = 'u'
    ENV['PASSWORD'] = 'p'
    request.env['HTTP_AUTHORIZATION'] =
      ActionController::HttpAuthentication::Basic.encode_credentials(
        ENV['USERNAME'],
        ENV['PASSWORD']
      )
  end  
end
