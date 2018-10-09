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

      source_from.dir.glob('/data/from', '*').map do |file|
        path = FilePathBuilder.new(file)
        # 1. Download file to temp folder
        source_from.download! path.from, path.tmp
        # 2. Upload tempfile
        source_to.upload! path.tmp, path.to
        # 3. Move file to History folder
        source_from.rename! path.from, path.archive
        # 4. Remove tempfile
        FileUtils.rm path.tmp
      end
    end

    def register_source(name, options)
      sources[name.to_sym] = FTPSource.new(name, host: options['host'], username: options['username'], password: options['password'], port: options['port'])
    end
  end
end
