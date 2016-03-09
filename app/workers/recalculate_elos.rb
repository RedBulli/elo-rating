class RecalculateElos
  include Sidekiq::Worker

  def perform
    process_next_frame
  end

  def process_next_frame(frame = nil)
    if frame_to_process = next_frame(frame)
      frame_to_process.recalculate_elos
      process_next_frame(frame_to_process)
    end
  end

  private

  def next_frame(frame = nil)
    if frame
      Frame.where('id > ?', frame.id)
    else
      Frame
    end.order('id ASC').first
  end
end
