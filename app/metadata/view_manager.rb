# frozen_string_literal: true

class ViewManager
  MAX_VIEW_DEF = 100

  attr_accessor :table_manager

  def initialize(is_new, table_manager, transaction)
    @table_manager = table_manager
    if is_new
      schema = Schema.new
      schema.add_string_field("viewName", TableManager::MAX_NAME)
      schema.add_string_field("viewDef", MAX_VIEW_DEF)
      @table_manager.create_table("viewCatalog", schema, transaction)
    end
  end

  def create_view(view_name, view_def, transaction)
    layout = @table_manager.get_layout("viewCatalog", transaction)
    table_scan = TableScan.new(transaction, "viewCatalog", layout)
    table_scan.insert
    table_scan.set_string("viewName", view_name)
    table_scan.set_string("viewDef", view_def)
    table_scan.close
  end

  def get_view_definition(view_name, transaction)
    result = nil
    layout = @table_manager.get_layout("viewCatalog", transaction)
    table_scan = TableScan.new(transaction, "viewCatalog", layout)
    while table_scan.next?
      if table_scan.get_string("viewName") == view_name
        result = table_scan.get_string("viewDef")
        break
      end
    end
    table_scan.close
    result
  end
end
