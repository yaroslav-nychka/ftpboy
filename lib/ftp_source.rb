require 'net/sftp'
require 'byebug'
require_relative '../lib/file_path_builder'
require_relative '../lib/file_logger'
require_relative '../lib/settings'
require_relative '../lib/errors/errors'

module Validic
  class FileTransferError < StandardError
    def initialize(msg='My custom error')
      super
    end
  end

  class FTPSource
    include Configurable
    attr_reader :sftp, :logger, :options, :name

    def initialize(name, options = {})
      @name = name
      @logger = FileLogger.new(progname: name)
      @sftp = Net::SFTP.start(options[:host], options[:username], password: options[:password], port: options[:port])
      @options = settings['ftp_sources'][name.to_s]
    end

    def mkdir_p!(file, path)
      file.dirs.map do |dir|
        path += "/#{dir}"
        handle path do
          sftp.mkdir!(path) rescue nil
        end
      end
    end

    def dir(key)
      options['dirs'][key.to_s]
    end

    def archive!(file)
      mkdir_p! file, options['dirs']['archiving']
      handle(file.full) do
        sftp.rename! from(file), file.archive
      end
    end

    def upload!(file)
      mkdir_p! file, options['dirs']['receiving']
      handle("upload!") do
        raise Validic::FileNotFoundError, 'File not found' unless File.exists? file.tmp

        sftp.upload! file.tmp, to(file)
      end
    end

    def download!(file)
      handle('download') do
        sftp.download! from(file), file.tmp!
      end
    end

    def from(file)
      options['dirs']['sending'] + '/' + file.full
    end

    def to(file)
      options['dirs']['receiving'] + '/' + file.full
    end

    def list_files_for(operation, pattern = nil)
      pattern ||= '**/*.*'
      path = '/' + dir(operation)
      sftp.dir.glob(path, pattern).map{ |sftp_file| FilePathBuilder.new(sftp_file)}
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
        yield
      rescue Net::SFTP::StatusException => e
        logger.error(e.message)
        errors = settings['errors']
        #byebug
        raise FileTransferError, "#{e.code} - #{e.message}" unless errors.key?(caller)
        raise FileTransferError, "#{e.code} - #{e.message}" unless errors[caller].key?(e.code)
        raise Kernel.const_get(errors[caller][e.code]['error']), errors[caller][e.code]['message']
    end
  end
end
