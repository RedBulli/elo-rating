require 'rails_helper'

RSpec.describe RecalculateElosJob, type: :job do
  it 'should perform' do
    RecalculateElosJob.perform_now
  end
end
