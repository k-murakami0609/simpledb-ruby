# frozen_string_literal: true

class BufferNeeds
  def self.best_root(available_buffers, output_size)
    available = available_buffers - 2
    return 1 if available <= 1

    k = Float::INFINITY
    i = 1.0
    while k > available
      i += 1
      k = (output_size**(1 / i)).ceil
    end
    k.to_i
  end

  def self.best_factor(available_buffers, output_size)
    available = available_buffers - 2
    return 1 if available <= 1

    k = output_size
    i = 1.0
    while k > available
      i += 1
      k = (output_size / i).ceil
    end
    k
  end
end
