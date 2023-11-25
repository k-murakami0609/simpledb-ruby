# frozen_string_literal: true

class Layout
  INTEGER_BYTE_SIZE = 4

  attr_reader :schema, :name_to_offset, :slot_size

  # スキーマからLayoutオブジェクトを作成します。このコンストラクタはテーブルが作成されるときに使用されます。
  def initialize(schema, name_to_offset = nil, slot_size = nil)
    @schema = schema
    @name_to_offset = {}

    unless name_to_offset.nil? || slot_size.nil?
      raise "slot_size is negative" if slot_size < 0

      @name_to_offset = name_to_offset
      @slot_size = slot_size
      return
    end

    position = INTEGER_BYTE_SIZE # 空/使用中フラグのスペースを残す
    @schema.field_names.each do |field_name|
      @name_to_offset[field_name] = position
      position += length_in_bytes(field_name)
    end
    raise "position is negative" if position < 0
    @slot_size = position
  end

  def offset(field_name)
    @name_to_offset[field_name]
  end

  private

  # フィールドのバイト長を計算します。
  def length_in_bytes(field_name)
    field_type = @schema.type(field_name)
    case field_type
    when Schema::FieldInfo::Type::INTEGER
      INTEGER_BYTE_SIZE
    when Schema::FieldInfo::Type::VARCHAR
      @schema.length(field_name)
    else
      raise "unknown field type #{field_type}"
    end
  end
end
