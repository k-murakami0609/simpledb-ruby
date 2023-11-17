# frozen_string_literal: true

class TableManager
  MAX_NAME = 16
  attr_accessor :table_catalog_layout, :field_catalog_layout

  def initialize(is_new, transaction)
    table_catalog_schema = Schema.new
    table_catalog_schema.add_string_field("tableName", MAX_NAME)
    table_catalog_schema.add_int_field("slotSize")
    @table_catalog_layout = Layout.new(table_catalog_schema)

    field_catalog_schema = Schema.new
    field_catalog_schema.add_string_field("tableName", MAX_NAME)
    field_catalog_schema.add_string_field("fieldName", MAX_NAME)
    field_catalog_schema.add_int_field("type")
    field_catalog_schema.add_int_field("length")
    field_catalog_schema.add_int_field("offset")
    @field_catalog_layout = Layout.new(field_catalog_schema)

    if is_new
      create_table("tableCatalog", table_catalog_schema, transaction)
      create_table("fieldCatalog", field_catalog_schema, transaction)
    end
  end

  def create_table(table_name, schema, transaction)
    layout = Layout.new(schema)
    table_catalog = TableScan.new(transaction, "tableCatalog", @table_catalog_layout)
    table_catalog.insert
    table_catalog.set_string("tableName", table_name)
    table_catalog.set_int("slotSize", layout.slot_size)
    table_catalog.close

    # insert a record into fldcat for each field
    field_catalog = TableScan.new(transaction, "fieldCatalog", @field_catalog_layout)
    schema.field_names.each do |field_name|
      field_catalog.insert
      field_catalog.set_string("tableName", table_name)
      field_catalog.set_string("fieldName", field_name)
      field_catalog.set_int("type", schema.type(field_name))
      field_catalog.set_int("length", schema.length(field_name))
      offset = layout.offset(field_name)
      throw "offset is null" unless offset
      field_catalog.set_int("offset", offset)
    end
    field_catalog.close
  end

  def get_layout(table_name, transaction)
    size = -1
    table_catalog = TableScan.new(transaction, "tableCatalog", @table_catalog_layout)
    while table_catalog.next?
      if table_catalog.get_string("tableName") == table_name
        size = table_catalog.get_int("slotSize")
        break
      end
    end
    table_catalog.close

    schema = Schema.new
    offsets = {}
    field_catalog = TableScan.new(transaction, "fieldCatalog", @field_catalog_layout)
    while field_catalog.next?
      if field_catalog.get_string("tableName") == table_name
        field_name = field_catalog.get_string("fieldName")
        field_type = field_catalog.get_int("type")
        field_length = field_catalog.get_int("length")
        offset = field_catalog.get_int("offset")
        offsets[field_name] = offset
        schema.add_field(field_name, field_type, field_length)
      end
    end
    field_catalog.close
    Layout.new(schema, offsets, size)
  end
end
