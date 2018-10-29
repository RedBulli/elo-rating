require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe DummyWorker, type: :worker do
  it 'does not throw' do
    DummyWorker.new.perform
  end
end
