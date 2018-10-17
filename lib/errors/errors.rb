module Validic
  class AccessDeniedError < StandardError
  end

  class DirNotFoundError < StandardError
  end

  class FileNotFoundError < StandardError
  end

  class InvalidPathError < StandardError
  end

  class ConnectionError < StandardError
  end
end
