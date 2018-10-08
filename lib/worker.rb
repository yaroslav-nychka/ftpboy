require 'sidekiq'

require_relative 'ftp_dispatcher'

class Worker
  include Sidekiq::Worker

  def perform
    dispatcher = ::FTPDispatcher.new
    dispatcher.handle(:intervent, :intuity)
    dispatcher.handle(:intuity, :intervent)
  end
end
