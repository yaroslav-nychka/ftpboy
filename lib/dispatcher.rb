require_relative 'source'
require_relative 'file_decorator'
require_relative 'settings'

module InterventFTP
  class Dispatcher
    include Settings
    attr_reader :sources

    def initialize
      @sources = {}

      settings['ftp_sources'].each do |name, options|
        register_source(name, options)
      end
    end

    def handle(from, to)
      sender = sources[from]
      receiver = sources[to]

      sender.list_files_for(:sending).map do |file|
        sender.download! file # 1. Download file to temp folder
        receiver.upload! file # 2. Upload tempfile
        sender.archive! file  # 3. Move file to History folder
        file.destroy!         # 4. Remove tempfile
      end
    end

    def register_source(name, options)
      sources[name.to_sym] = Source.new(name, host: options['host'], username: options['username'], password: options['password'], port: options['port'])
    end
  end
end
