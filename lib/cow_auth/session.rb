module CowAuth
  module Session
    extend ActiveSupport::Concern

    def create
      user = User.find_by(email: params[:email])
      if user.try(:authenticate, params[:password])
        user.api_sign_in
        render json: user
      else
        render json: { error: 'Invalid user credentials.' }, status: :unauthorized
      end
    end

    def destroy
      if @current_user.try(:api_sign_out)
        head :ok
      else
        render json: { error: 'Could not sign user out.' }, status: :unauthorized
      end
    end
  end
end
