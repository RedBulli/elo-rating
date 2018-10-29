class DummyWorker
  include Sidekiq::Worker

  def perform
    puts "jsjsjs"
  end

  private

  def untested
    # TODO
    puts 'this wont be called'
  end
end
