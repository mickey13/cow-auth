module CowAuth
  class NotAuthenticatedError < StandardError
  end

  class RedisHandleMissingError < StandardError
  end
end
