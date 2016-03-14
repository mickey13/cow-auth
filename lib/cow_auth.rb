require 'cow_auth/version'
require 'cow_auth/user'
require 'cow_auth/session'
require 'cow_auth/authentication'
require 'cow_auth/not_authenticated_error'

module CowAuth
  def self.moo
    user = CowAuth::User.new
    puts user
    return user
  end
end
