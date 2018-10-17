module Validic
  class DirAccessDeniedError < StandardError
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
