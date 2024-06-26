# frozen_string_literal: true

class Schema
  attr_reader :field_names

  def initialize
    @field_names = []
    @name_to_field_info = {}
  end

  def add_field(field_name, type, length)
    @field_names << field_name
    @name_to_field_info[field_name] = FieldInfo.new(type, length)
  end

  def add_int_field(field_name)
    add_field(field_name, FieldInfo::Type::INTEGER, 0)
  end

  def add_string_field(field_name, length)
    add_field(field_name, FieldInfo::Type::VARCHAR, length)
  end

  def add(field_name, schema)
    type = schema.type(field_name)
    length = schema.length(field_name)
    add_field(field_name, type, length)
  end

  def add_all(schema)
    schema.field_names.each { |field_name| add(field_name, schema) }
  end

  def has_field?(field_name)
    @field_names.include?(field_name)
  end

  def type(field_name)
    info = @name_to_field_info[field_name]
    raise "field_name=#{field_name} is not found" unless info
    info.type
  end

  def length(field_name)
    info = @name_to_field_info[field_name]
    raise "field_name=#{field_name} is not found" unless info
    info.length
  end

  class FieldInfo
    attr_accessor :type, :length

    module Type
      INTEGER = 0
      VARCHAR = 1
    end

    def initialize(type, length)
      @type = type
      # TODO: 値を入れるときに、Page.max_length(@schema.length(field_name))をしたほうが良いかも
      @length = length
    end
  end
end
