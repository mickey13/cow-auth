require 'cow_auth/version'
require 'cow_auth/user'
require 'cow_auth/authentication'

module CowAuth
  def self.hi
    user = CowAuth::User.new
    puts user
    return user
  end
end
