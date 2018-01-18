require 'cow_auth/exceptions'

module CowAuth
  module TokenAuth
    module AuthenticateRequest
      extend ActiveSupport::Concern

    private

      SID_KEY = 'sid='
      TOKEN_KEY = 'token='
      AUTHORIZATION_REGEX = /^(Token|Bearer)\s*/
      AUTHORIZATION_DELIMITERS = /(?:,|;|\t+)/

      def authenticate_user
        sid, auth_token = extract_credentials(request.authorization)
        if sid.present? && auth_token.present?
          user = authentication_class.find_by(sid: sid)
          @current_user = user.try(:authenticate_with_token, auth_token) ? user : nil
          return true if @current_user.present?
        end
        raise CowAuth::NotAuthenticatedError.new('User not authenticated.')
      end

      def extract_credentials(authorization_header)
        return nil if authorization_header.blank? || !(authorization_header =~ /\A#{AUTHORIZATION_REGEX}/)
        params = authorization_header.sub(AUTHORIZATION_REGEX, '').split(/\s*#{AUTHORIZATION_DELIMITERS}\s*/)
        sid = params[1].sub(SID_KEY, '') if params[1] =~ /\A#{SID_KEY}/
        auth_token = params[0].sub(TOKEN_KEY, '') if params[0] =~ /\A#{TOKEN_KEY}/
        return sid, auth_token
      end

      def current_user
        return @current_user
      end
    end
  end
end
