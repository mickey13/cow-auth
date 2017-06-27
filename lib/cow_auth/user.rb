require 'scrypt'

module CowAuth
  class User < ActiveRecord::Base
    after_initialize :generate_sid_if_necessary

    validates :email, presence: true
    validates :email, uniqueness: true
    validates :encrypted_password, presence: true
    validates :sid, presence: true
    validates :sid, uniqueness: true
    validates :sid, format: { with: /\AC[a-z0-9]{32}\z/ }

    def password=(new_password)
      return false if new_password.blank?
      salt = SCrypt::Engine.generate_salt
      self.encrypted_password = SCrypt::Engine.hash_secret(new_password, salt)
      return true
    end

    def authenticate(password)
      return false if self.encrypted_password.blank?
      if SCrypt::Password.new(self.encrypted_password) == password
        self.update(sign_in_count: self.sign_in_count + 1)
        return true
      end
      return false
    end

    def api_sign_in
      User.assert_redis_handle_present
      $redis.set(self.redis_key, {
        auth_token: self.token_valid? ? self.auth_token : User.generate_auth_token,
        expires_at: User.generate_token_expires_at
      }.to_json)
    end

    def api_sign_out
      User.assert_redis_handle_present
      $redis.del(self.redis_key)
    end

    def auth_token
      return User.fetch_api_key_from_redis(self.sid).try(:[], :auth_token)
    end

    def self.authenticate_from_token(sid, auth_token)
      api_key = User.fetch_api_key_from_redis(sid)
      if api_key.present? &&
          api_key.key?(:auth_token) &&
          api_key.key?(:expires_at) &&
          api_key[:auth_token] == auth_token &&
          api_key[:expires_at] > Time.zone.now
        return User.find_by(sid: sid)
      end
      return nil
    end

  protected

    def redis_key
      return "user_#{self.sid}"
    end

    def token_valid?
      api_key = User.fetch_api_key_from_redis(self.sid)
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

    def self.generate_auth_token
      return SecureRandom.hex(32)
    end

    def self.generate_token_expires_at
      return 1.month.from_now
    end

    def self.fetch_api_key_from_redis(sid)
      User.assert_redis_handle_present
      api_key = $redis.get("user_#{sid}")
      return api_key.present? ? JSON.parse(api_key).try(:symbolize_keys) : nil
    end

    def self.assert_redis_handle_present
      raise CowAuth::RedisHandleMissingError.new('"$redis" handle not found.') unless $redis.present?
    end
  end
end
