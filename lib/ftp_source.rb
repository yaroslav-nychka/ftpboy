require 'net/sftp'
require 'byebug'
require 'logger'
require 'date'

class FileTransferError < StandardError
  def initialize(msg='My custom error')
    super
  end
end

class FileLogger
  attr_reader :logger

  def initialize(options = {})
    formatter = proc do |severity, datetime, progname, msg|
      "[#{progname}|#{datetime}] #{severity}: #{msg}\n"
    end
    name = DateTime.now.strftime('%d-%m-%Y')
    filename = "#{Dir.pwd}/log/#{name}.log"
    file = File.exists?(filename) ? File.open(filename, 'a+') : File.new(filename, 'w')

    @logger = Logger.new(file, 'daily')
    @logger.datetime_format = '%d-%M-%Y %H:%M%:%S'
    @logger.formatter = formatter
    @logger.progname = 'INTERVENT_FTP'
  end

  def <<(msg)
    logger << msg
  end

  def log(msg)
    logger.info(msg)
  end

  def error(msg)
    logger.error(msg)
  end
end

class FTPSource
  attr_reader :sftp, :logger

  def initialize(name, options = {})
    @name = name
    @logger = FileLogger.new
    @host = options[:host] || 'localhost'
    @username = options[:username] || ENV['USERNAME']
    @password = options[:password] || ENV['PASSWORD']
    @port = options[:port] || ENV['PORT']
    @sftp = Net::SFTP.start(@host, @username, password: @password, port: @port)
  end

  private

  def method_missing(name, *args, &block)
    operation = "#{name.to_s}"

    handle(operation, args) do
      logger.log("Started operation #{operation}")
      sftp.send(operation, *args) do |response|
        logger.log "operation #{operation} finished with response: #{response.to_s} "
      end
    end
  end

  def handle(caller, *args)
    begin
      yield
    rescue Net::SFTP::StatusException => e
      logger.error(e.message)
      if e.code == 4
        raise FileTransferError, "Operation #{caller} failed on #{@host}"
      elsif e.code == 2 && caller == 'opendir!'
        raise FileTransferError, "Folder not found on #{@host}"
      elsif e.code == 3
        raise FileTransferError, "Permission denied to dir"
      else
        raise FileTransferError, "Unknown error #{e.code} - #{e.message}"
      end
    end
  end
end