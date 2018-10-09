require 'erb'
require 'yaml'

module Validic
  module Configurable
    def settings
      env = 'test'
      @settings ||= YAML.load(ERB.new(File.read("#{Dir.pwd}/config/settings.yml")).result binding)[env]
    end
  end
end
