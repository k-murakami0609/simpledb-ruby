# frozen_string_literal: true

# トランザクションがピンしているバッファーを管理する
class BufferList
  def initialize(buffer_manager)
    @buffers = {}
    @pins = []
    @buffer_manager = buffer_manager
  end

  def get_buffer(block_id)
    @buffers[block_id]
  end

  def pin(block_id)
    buffer = @buffer_manager.pin(block_id)
    @buffers[block_id] = buffer
    @pins.push(block_id)
  end

  def unpin(block_id)
    buffer = @buffers[block_id]
    @buffer_manager.unpin(buffer)
    @pins.delete(block_id)
    @buffers.delete(block_id) unless @pins.include?(block_id)
  end

  def unpin_all
    @pins.each do |block_id|
      buffer = @buffers[block_id]
      @buffer_manager.unpin(buffer)
    end
    @buffers.clear
    @pins.clear
  end
end
