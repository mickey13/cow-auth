module CowAuth
  module Authentication
    extend ActiveSupport::Concern
    include ActionController::HttpAuthentication::Token::ControllerMethods

  private

    def authenticate_user
      authenticate_or_request_with_http_token do |api_key, options|
        sid, auth_token = api_key.match(/sid=([[:alnum:]]*)&auth_token=([[:alnum:]]*)/).try(:captures)
        @current_user = User.authenticate_from_token(sid, auth_token)
      end
    end

    def request_http_token_authentication(realm = 'Application', message = nil)
      message ||= 'HTTP Token: Access denied.'
      self.headers['WWW-Authenticate'] = %(Token realm="#{realm.tr('"'.freeze, ''.freeze)}")
      self.__send__ :render, json: { error: message }, status: :unauthorized
    end
  end
end
