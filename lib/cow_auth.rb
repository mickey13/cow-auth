require 'cow_auth/version'
require 'cow_auth/user'
require 'cow_auth/not_authenticated_error'
require 'cow_auth/session_auth/session_endpoints'
require 'cow_auth/session_auth/authenticate_request'
require 'cow_auth/token_auth/session_endpoints'
require 'cow_auth/token_auth/authenticate_request'

module CowAuth
  def self.moo
    puts 'Moo Cow: ' + CowAuth::VERSION
    return CowAuth::User.new
  end
end
