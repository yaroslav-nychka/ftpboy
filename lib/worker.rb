require 'sidekiq'
require 'sidekiq-scheduler'
require_relative 'dispatcher'

Sidekiq.configure_server do |config|
  config.redis = { url: "redis://#{ENV.fetch('REDIS_HOST', 'redis')}:#{ENV.fetch('REDIS_PORT', 6379)}/#{ENV.fetch('REDIS_DB', 0)}" }
end

Sidekiq.configure_client do |config|
  config.redis = { url: "redis://#{ENV.fetch('REDIS_HOST', 'redis')}:#{ENV.fetch('REDIS_PORT', 6379)}/#{ENV.fetch('REDIS_DB', 0)}" }
end

module InterventFTP
  class Worker
    include Sidekiq::Worker

    def perform
      dispatcher = Dispatcher.new
      dispatcher.handle(:intervent, :intuity)
      dispatcher.handle(:intuity, :intervent)
    end
  end
end
