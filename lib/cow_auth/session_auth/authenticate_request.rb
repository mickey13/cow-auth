require 'cow_auth/exceptions'

module CowAuth
  module SessionAuth
    module AuthenticateRequest
      extend ActiveSupport::Concern

    private

      def authenticate_user
        @current_user = User.find_by(uuid: session[:current_user])
        raise CowAuth::NotAuthenticatedError.new('User not authenticated.') if @current_user.blank?
        return true
      end

      def current_user
        return @current_user
      end
    end
  end
end
