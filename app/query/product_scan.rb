# frozen_string_literal: true

class ProductScan
  attr_accessor :scan1, :scan2

  def initialize(scan1, scan2)
    @scan1 = scan1
    @scan2 = scan2
    before_first
  end

  def before_first
    @scan1.before_first
    @scan1.next?
    @scan2.before_first
  end

  def next?
    return true if @scan2.next?

    @scan2.before_first
    @scan2.next? && scan1.next?
  end

  def get_int(field_name)
    @scan1.has_field?(field_name) ? @scan1.get_int(field_name) : @scan2.get_int(field_name)
  end

  def get_string(field_name)
    @scan1.has_field?(field_name) ? @scan1.get_string(field_name) : @scan2.get_string(field_name)
  end

  def get_value(field_name)
    @scan1.has_field?(field_name) ? @scan1.get_value(field_name) : @scan2.get_value(field_name)
  end

  def has_field?(field_name)
    @scan1.has_field?(field_name) || @scan2.has_field?(field_name)
  end

  # 両方のスキャンを閉じる
  def close
    @scan1.close
    @scan2.close
  end
end
