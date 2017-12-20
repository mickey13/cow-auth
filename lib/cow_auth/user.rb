require 'scrypt'
require 'cow_auth/exceptions'

module CowAuth
  module User
    extend ActiveSupport::Concern

    included do
      after_initialize :generate_sid_if_necessary

      validates :email, presence: true
      validates :email, uniqueness: true
      validates :encrypted_password, presence: true
      validates :sid, presence: true
      validates :sid, uniqueness: true
      validates :sid, format: { with: /\AC[a-z0-9]{32}\z/ }
    end

    def authenticate_with_password(password)
      return false if self.encrypted_password.blank?
      if SCrypt::Password.new(self.encrypted_password) == password
        self.update(sign_in_count: self.sign_in_count + 1)
        return true
      end
      return false
    end

    def authenticate_with_token(auth_token)
      api_key = self.fetch_api_key_from_redis(sid)
      if api_key.present? &&
          api_key.key?(:auth_token) &&
          api_key.key?(:expires_at) &&
          api_key[:auth_token] == auth_token &&
          api_key[:expires_at] > Time.zone.now
        return true
      end
      return false
    end

    def api_sign_in
      self.redis_handle.set(self.redis_key, {
        auth_token: self.token_valid? ? self.auth_token : self.generate_auth_token,
        expires_at: self.generate_token_expires_at
      }.to_json)
    end

    def api_sign_out
      self.redis_handle.del(self.redis_key)
    end

    def auth_token
      return self.fetch_api_key_from_redis(self.sid).try(:[], :auth_token)
    end

    def password=(new_password)
      return false if new_password.blank?
      salt = SCrypt::Engine.generate_salt
      self.encrypted_password = SCrypt::Engine.hash_secret(new_password, salt)
      return true
    end

  protected

    def fetch_api_key_from_redis(sid)
      api_key = self.redis_handle.get(self.redis_key)
      return api_key.present? ? JSON.parse(api_key).try(:symbolize_keys) : nil
    end

    def generate_auth_token
      return SecureRandom.hex(64)
    end

    def generate_token_expires_at
      return 1.month.from_now
    end

    def redis_handle
      raise CowAuth::RedisHandleMissingError.new('"$redis" handle not found.') unless $redis.present?
      return $redis
    end

    def redis_key
      return "user_#{self.sid.downcase}"
    end

    def token_valid?
      api_key = self.fetch_api_key_from_redis(self.sid)
      return api_key.present? &&
          api_key.key?(:auth_token) &&
          api_key.key?(:expires_at) &&
          api_key[:expires_at] > Time.zone.now
    end

  private

    def generate_sid_if_necessary
      self.sid ||= "C#{SecureRandom.hex(16)}"
      return true
    end
  end
end
