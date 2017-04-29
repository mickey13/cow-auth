require 'cow_auth/exceptions'

module CowAuth
  module TokenAuth
    module AuthenticateRequest
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

      def current_user
        return @current_user
      end
    end
  end
end
