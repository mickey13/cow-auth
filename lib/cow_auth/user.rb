require 'scrypt'

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
      if self.auth_token.present? &&
          self.expires_at.present? &&
          self.auth_token == auth_token &&
          self.expires_at > Time.zone.now
        return true
      end
      return false
    end

    def api_sign_in
      self.update(
        auth_token: self.token_valid? ? self.auth_token : self.generate_auth_token,
        expires_at: self.generate_token_expires_at
      )
      return true
    end

    def api_sign_out
      self.update(
        auth_token: nil,
        expires_at: nil
      )
      return true
    end

    def password=(new_password)
      return false if new_password.blank?
      salt = SCrypt::Engine.generate_salt
      self.encrypted_password = SCrypt::Engine.hash_secret(new_password, salt)
      return true
    end

  protected

    def generate_auth_token
      return SecureRandom.hex(64)
    end

    def generate_token_expires_at
      return 1.month.from_now
    end

    def token_valid?
      return self.auth_token.present? &&
          self.expires_at.present? &&
          self.expires_at > Time.zone.now
    end

  private

    def generate_sid_if_necessary
      self.sid ||= "C#{SecureRandom.hex(16)}"
      return true
    end
  end
end
