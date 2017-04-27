require 'cow_auth/user_serializer'
require 'cow_auth/not_authenticated_error'

module CowAuth
  module TokenAuth
    module SessionEndpoints
      extend ActiveSupport::Concern

      def create
        @user = User.find_by(email: params[:email])
        if @user.try(:authenticate, params[:password])
          @user.api_sign_in
          render json: UserSerializer.new(@user), status: :ok
        else
          raise CowAuth::NotAuthenticatedError.new('Invalid user credentials.')
        end
      end

      def destroy
        if @current_user.try(:api_sign_out)
          head :ok
        else
          raise CowAuth::NotAuthenticatedError.new('Could not sign user out.')
        end
      end
    end
  end
end
