require 'net/sftp'
require 'byebug'

class FileTransferError < StandardError
  def initialize(msg='My custom error')
    super
  end
end

class FileTransfer
  attr_reader :sftp

  def initialize(host, username, password)
    @host = host
    @username = username
    @password = password
    @sftp = Net::SFTP.start(host, username, password: password)
  end

  def mkdir(dir)
    begin
      sftp.mkdir! dir
    rescue Net::SFTP::StatusException => e
      if e.code == 4
        raise FileTransferError, 'Could not create dir maybe it already exists!'
      end
    end
  end
end
