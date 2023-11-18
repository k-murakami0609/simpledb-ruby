# frozen_string_literal: true

class MetadataManager
  def initialize(is_new, transaction)
    @table_manager = TableManager.new(is_new, transaction)
    @view_manager = ViewManager.new(is_new, @table_manager, transaction)
    @stat_manager = StatManager.new(@table_manager, transaction)
    @index_manager = IndexManager.new(is_new, @table_manager, @stat_manager, transaction)
  end

  def create_table(table_name, schema, transaction)
    @table_manager.create_table(table_name, schema, transaction)
  end

  def get_layout(table_name, transaction)
    @table_manager.get_layout(table_name, transaction)
  end

  def create_view(view_name, view_def, transaction)
    @view_manager.create_view(view_name, view_def, transaction)
  end

  def get_view_def(view_name, transaction)
    @view_manager.get_view_def(view_name, transaction)
  end

  def create_index(index_name, table_name, field_name, transaction)
    @index_manager.create_index(index_name, table_name, field_name, transaction)
  end

  def get_index_info(table_name, transaction)
    @index_manager.get_index_info(table_name, transaction)
  end

  def get_stat_info(table_name, layout, transaction)
    @stat_manager.get_stat_info(table_name, layout, transaction)
  end
end
