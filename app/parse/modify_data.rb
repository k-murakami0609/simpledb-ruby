# frozen_string_literal: true

class ModifyData < Data.define(:table_name, :field_name, :new_value, :predicate)
end
