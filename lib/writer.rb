require 'logger'
require 'date'

module InterventFTP
  class Writer
    attr_reader :logger

    def initialize(options = {})
      formatter = proc do |severity, datetime, progname, msg|
        "[#{progname}|#{datetime}] #{severity}: #{msg}\n"
      end
      name = DateTime.now.strftime('%d-%m-%Y')
      filename = "#{Dir.pwd}/log/#{name}.log"
      file = File.exist?(filename) ? File.open(filename, 'a+') : File.new(filename, 'w')

      @logger = Logger.new(file, 'daily')
      @logger.datetime_format = '%d-%M-%Y %H:%M%:%S'
      @logger.formatter = formatter
      @logger.progname = options[:progname] || 'UNKNOWN_FTP'
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
end
