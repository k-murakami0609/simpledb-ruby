# frozen_string_literal: true

class ProjectScan
  attr_accessor :scan, :field_list

  # 初期化メソッド
  # @param scan [Scan] 下層のスキャン
  # @param field_list [Array<String>] フィールド名のリスト
  def initialize(scan, field_list)
    @scan = scan
    @field_list = field_list
  end

  # スキャンを最初のレコードの前に位置づける
  def before_first
    @scan.before_first
  end

  # スキャンを次のレコードに進める
  # @return [Boolean] 次のレコードが存在する場合は true、そうでない場合は false
  def next
    @scan.next
  end

  # 指定されたフィールドの整数値を返す
  # @param field_name [String] フィールド名
  # @return [Integer] フィールドの整数値
  def get_int(field_name)
    raise "Field #{field_name} not found." unless has_field?(field_name)

    @scan.get_int(field_name)
  end

  # 指定されたフィールドの文字列値を返す
  # @param field_name [String] フィールド名
  # @return [String] フィールドの文字列値
  def get_string(field_name)
    raise "Field #{field_name} not found." unless has_field?(field_name)

    @scan.get_string(field_name)
  end

  # 指定されたフィールドの値を返す
  # @param field_name [String] フィールド名
  # @return [Constant] フィールドの値
  def get_value(field_name)
    raise "Field #{field_name} not found." unless has_field?(field_name)

    @scan.get_value(field_name)
  end

  # 指定されたフィールドが存在するかどうかを確認する
  # @param field_name [String] フィールド名
  # @return [Boolean] フィールドが存在する場合は true、そうでない場合は false
  def has_field?(field_name)
    @field_list.include?(field_name)
  end

  # スキャンを閉じる
  def close
    @scan.close
  end
end
