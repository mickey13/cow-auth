require_relative 'cow_auth/version'
require_relative 'cow_auth/user'
require_relative 'cow_auth/exceptions'
require_relative 'cow_auth/session_auth/session_endpoints'
require_relative 'cow_auth/session_auth/authenticate_request'
require_relative 'cow_auth/token_auth/session_endpoints'
require_relative 'cow_auth/token_auth/authenticate_request'

module CowAuth
  class Error < StandardError; end

  def self.moo
    puts 'Moo Cow: ' + CowAuth::VERSION
    return CowAuth::User.new
  end
end
