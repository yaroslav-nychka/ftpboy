require 'erb'
require 'yaml'

module InterventFTP
  module Settings
    def settings
      @settings ||= YAML.load(ERB.new(File.read("#{Dir.pwd}/config/settings.yml")).result binding)[env]
    end

    def tmpdir
      @tmpdir ||= "#{Dir.pwd}/#{settings.fetch('dirs').fetch('local').fetch('tmp')}"
    end

    def archive
      @archive ||= settings.fetch('dirs').fetch('remote').fetch('archiving')
    end

    def env
      @env ||= ENV.fetch('RACK_ENV', 'development')
    end
  end
end
