# frozen_string_literal: true

class BasicUpdatePlanner
  def initialize(metadata_manager)
    @metadata_manager = metadata_manager
  end

  def execute_delete(delete_data, transaction)
    plan = TablePlan.new(transaction, delete_data.table_name, @metadata_manager)
    plan = SelectPlan.new(plan, delete_data.predicate)
    update_scan = plan.open
    count = 0
    while update_scan.next?
      update_scan.delete
      count += 1
    end
    update_scan.close
    count
  end

  def execute_modify(modify_data, transaction)
    plan = TablePlan.new(transaction, modify_data.table_name, @metadata_manager)
    plan = SelectPlan.new(plan, modify_data.predicate)
    update_scan = plan.open
    count = 0
    while update_scan.next?
      value = modify_data.new_value.evaluate(update_scan)
      update_scan.set_value(modify_data.field_name, value)
      count += 1
    end
    update_scan.close
    count
  end

  def execute_insert(insert_data, transaction)
    plan = TablePlan.new(transaction, insert_data.table_name, @metadata_manager)
    update_scan = plan.open
    update_scan.insert
    insert_data.field_names.zip(insert_data.values).each do |field_name, value|
      update_scan.set_value(field_name, value)
    end
    update_scan.close
    1
  end

  def execute_create_table(create_table_data, transaction)
    @metadata_manager.create_table(create_table_data.table_name, create_table_data.schema, transaction)
    0
  end

  def execute_create_view(create_view_data, transaction)
    # TODO: query_data.to_s は動くか怪しそう
    @metadata_manager.create_view(create_view_data.view_name, create_view_data.query_data.to_s, transaction)
    0
  end

  def execute_create_index(create_index_data, transaction)
    @metadata_manager.create_index(create_index_data.index_name, create_index_data.table_name, create_index_data.field_name, transaction)
    0
  end
end
