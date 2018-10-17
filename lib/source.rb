require 'net/sftp'
require 'byebug'
require_relative '../lib/file_decorator'
require_relative '../lib/writer'
require_relative '../lib/settings'
require_relative '../lib/errors/errors'

module InterventFTP
  class Source
    include Settings
    attr_reader :sftp, :logger, :options, :name

    def initialize(name, options = {})
      @name = name
      @logger = Writer.new(progname: name)
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
      settings['dirs']['remote'][key.to_s]
    end

    def archive!(file)
      mkdir_p! file, archive
      handle(file.path) do
        sftp.rename! from(file), file.archive_path
      end
    end

    def upload!(file)
      mkdir_p! file, dir(:receiving)
      handle("upload!") do
        raise InterventFTP::NotFoundError, 'File not found' unless File.exists? file.tmp

        uploader = sftp.upload! file.tmp, to(file)
        uploader.wait
      end
    end

    def opendir!(dir, &block)
      handle(__method__) do
        sftp.opendir! dir, &block
      end
    end

    def download!(file)
      handle(__method__) do
          sftp.download! from(file), file.tmp!
        rescue RuntimeError => e
          if e.message =~ /no such file/
            response = Struct.new(:code, :message).new
            response.code = 2
            response.message = e.message
            raise Net::SFTP::StatusException.new(response)
          end
      end
    end

    def from(file)
      dir(:sending) + '/' + file.path
    end

    def to(file)
      dir(:receiving) + '/' + file.path
    end

    def list_files_for(operation, pattern = nil)
      pattern ||= '**/*.*'
      path = '/' + dir(operation)
      handle __method__ do
        sftp.dir.glob(path, pattern).map{ |sftp_file| FileDecorator.new(sftp_file)}
      end
    end

    private

    def handle(caller, *args)
      yield
      rescue Net::SFTP::StatusException => e
      caller = caller.to_s
      errors = settings['errors']
      raise StandardError, "#{e.code} - #{e.message}" unless errors.key?(caller)
      raise StandardError, "#{e.code} - #{e.message}" unless errors[caller].key?(e.code)
      raise Kernel.const_get(errors[caller][e.code]['error']), errors[caller][e.code]['message']
    end
  end
end
