require 'cow_auth/exceptions'

module CowAuth
  module SessionAuth
    module SessionEndpoints
      extend ActiveSupport::Concern

      def new
      end

      def create
        user = authentication_class.find_by(email: params[:email])
        if user.try(:authenticate_with_password, params[:password])
          session[:current_user] = user.sid
          redirect_to sign_in_success_path
        else
          session[:current_user] = nil
          raise CowAuth::NotAuthenticatedError.new('Invalid user credentials.')
        end
      end

      def destroy
        if @current_user.present?
          session[:current_user] = nil
          redirect_to sign_out_success_path
        else
          raise CowAuth::StandardError.new('Could not sign user out.')
        end
      end
    end
  end
end
