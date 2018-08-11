require 'cow_auth/exceptions'

module CowAuth
  module TokenAuth
    module SessionEndpoints
      extend ActiveSupport::Concern

      def create
        @user = authentication_class.find_by(email: params[:email])
        if @user.try(:authenticate_with_password, params[:password])
          @user.create_auth_token
          render json: self.sign_in_success_response_payload, status: :ok
        else
          raise CowAuth::NotAuthenticatedError.new('Invalid user credentials.')
        end
      end

      def destroy
        if @current_user.try(:destroy_auth_token)
          head :no_content
        else
          raise CowAuth::NotAuthenticatedError.new('Could not sign user out.')
        end
      end

    protected

      def sign_in_success_response_payload
        return { sid: @user.sid, auth_token: @user.auth_token }
      end
    end
  end
end
