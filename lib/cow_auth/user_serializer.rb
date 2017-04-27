require 'active_model_serializers'

module CowAuth
  class UserSerializer < ActiveModel::Serializer
    attributes :email, :sid, :auth_token, :first_name, :last_name, :sign_in_count
  end
end
