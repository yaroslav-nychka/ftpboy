module Validic
  class DirAccessDeniedError < StandardError
  end

  class DirNotFoundError < StandardError
  end

  class ConnectionError < StandardError
  end
end
