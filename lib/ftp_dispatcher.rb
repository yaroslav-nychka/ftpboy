require_relative 'ftp_source'
require_relative 'file_path_builder'
require_relative 'settings'

module Validic
  class FTPDispatcher
    include Configurable
    attr_reader :sources

    def initialize
      @sources = {}

      settings['ftp_sources'].each do |name, options|
        register_source(name, options)
      end
    end

    def handle(from, to)
      source_from = sources[from]
      source_to = sources[to]

      source_from.dir.glob('/data/from', '**/*.*').map do |sftp_file|
        file = FilePathBuilder.new(sftp_file)
        #byebug
        source_from.download! file                   # 1. Download file to temp folder
        source_to.upload! file                       # 2. Upload tempfile
        source_from.archive! file                    # 3. Move file to History folder
        #FileUtils.rm file.tmp                       # 4. Remove tempfile
      end
    end

    def register_source(name, options)
      sources[name.to_sym] = FTPSource.new(name, host: options['host'], username: options['username'], password: options['password'], port: options['port'])
    end
  end
end
