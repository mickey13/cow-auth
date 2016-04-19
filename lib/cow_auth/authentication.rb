require 'cow_auth/not_authenticated_error'

module CowAuth
  module Authentication
    extend ActiveSupport::Concern
    include ActionController::HttpAuthentication::Token::ControllerMethods

  private

    def authenticate_user
      authenticate_or_request_with_http_token do |token, options|
        @current_user = User.authenticate_from_token(options[:sid], token)
        raise CowAuth::NotAuthenticatedError.new('User not authenticated.') if @current_user.blank?
        return true
      end
    end
  end
end
