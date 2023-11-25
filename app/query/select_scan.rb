# frozen_string_literal: true

class SelectScan
  attr_accessor :scan, :predicate

  # 初期化メソッド
  # @param scan [Scan] 下層のスキャン
  # @param predicate [Predicate] 選択条件
  def initialize(scan, predicate)
    @scan = scan
    @predicate = predicate
  end

  # スキャンを最初のレコードの前に位置づける
  def before_first
    @scan.before_first
  end

  # スキャンを次のレコードに進める
  # @return [Boolean] 次のレコードが存在する場合は true、そうでない場合は false
  def next?
    while @scan.next?
      return true if @predicate.satisfied?(@scan)
    end
    false
  end

  # 指定されたフィールドの整数値を返す
  # @param field_name [String] フィールド名
  # @return [Integer] フィールドの整数値
  def get_int(field_name)
    @scan.get_int(field_name)
  end

  # 指定されたフィールドの文字列値を返す
  # @param field_name [String] フィールド名
  # @return [String] フィールドの文字列値
  def get_string(field_name)
    @scan.get_string(field_name)
  end

  # 指定されたフィールドの値を返す
  # @param field_name [String] フィールド名
  # @return [Constant] フィールドの値
  def get_value(field_name)
    @scan.get_value(field_name)
  end

  # 指定されたフィールドが存在するかどうかを確認する
  # @param field_name [String] フィールド名
  # @return [Boolean] フィールドが存在する場合は true、そうでない場合は false
  def has_field?(field_name)
    @scan.has_field?(field_name)
  end

  # スキャンを閉じる
  def close
    @scan.close
  end

  # UpdateScan メソッド

  def set_int(field_name, value)
    update_scan = @scan
    if update_scan.respond_to?(:set_integer)
      update_scan.set_int(field_name, value)
    end
  end

  def set_string(field_name, value)
    update_scan = @scan
    update_scan.set_string(field_name, value)
  end

  def set_value(field_name, value)
    update_scan = @scan
    update_scan.set_value(field_name, value)
  end

  def delete
    update_scan = @scan
    update_scan.delete
  end

  def insert
    update_scan = @scan
    update_scan.insert
  end

  def get_record_id
    update_scan = @scan
    update_scan.get_record_id
  end

  def move_to_record_id(record_id)
    update_scan = @scan
    update_scan.move_to_record_id(record_id)
  end
end
