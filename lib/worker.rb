require 'sidekiq'

require_relative 'dispatcher'

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
