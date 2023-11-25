# frozen_string_literal: true

class Parser
  def initialize(statement)
    @lexer = SqlLexer.new(statement)
  end

  # Methods for parsing predicates, terms, expressions, constants, and fields

  def field
    @lexer.eat_identifier
  end

  def constant
    if @lexer.match_string_constant?
      Constant.new(@lexer.eat_string_constant)
    else
      Constant.new(@lexer.eat_int_constant)
    end
  end

  def expression
    if @lexer.match_identifier?
      Expression.new(field)
    else
      Expression.new(constant)
    end
  end

  def term
    lhs = expression
    @lexer.eat_delim("=")
    rhs = expression
    Term.new(lhs, rhs)
  end

  def predicate
    pred = Predicate.new(term)
    if @lexer.match_keyword?("and")
      @lexer.eat_keyword("and")
      pred.conjoin_with(predicate)
    end
    pred
  end

  # Methods for parsing queries

  def query
    @lexer.eat_keyword("select")
    fields = select_list
    @lexer.eat_keyword("from")
    tables = table_list
    pred = Predicate.new
    if @lexer.match_keyword?("where")
      @lexer.eat_keyword("where")
      pred = predicate
    end
    QueryData.new(fields, tables, pred)
  end

  def select_list
    fields = [field]
    while @lexer.match_delim?(",")
      @lexer.eat_delim(",")
      fields << field
    end
    fields
  end

  def table_list
    tables = [@lexer.eat_identifier]
    while @lexer.match_delim?(",")
      @lexer.eat_delim(",")
      tables << @lexer.eat_identifier
    end
    tables
  end

  # Methods for parsing update commands

  def update_cmd
    if @lexer.match_keyword?("insert")
      insert
    elsif @lexer.match_keyword?("delete")
      delete
    elsif @lexer.match_keyword?("update")
      modify
    else
      create
    end
  end

  def insert
    @lexer.eat_keyword("insert")
    @lexer.eat_keyword("into")
    table_name = @lexer.eat_identifier
    @lexer.eat_delim("(")
    fields = field_list
    @lexer.eat_delim(")")
    @lexer.eat_keyword("values")
    @lexer.eat_delim("(")
    values = const_list
    @lexer.eat_delim(")")
    InsertData.new(table_name, fields, values)
  end

  def delete
    @lexer.eat_keyword("delete")
    @lexer.eat_keyword("from")
    table_name = @lexer.eat_identifier
    pred = Predicate.new
    if @lexer.match_keyword?("where")
      @lexer.eat_keyword("where")
      pred = predicate
    end
    DeleteData.new(table_name, pred)
  end

  def modify
    @lexer.eat_keyword("update")
    table_name = @lexer.eat_identifier
    @lexer.eat_keyword("set")
    field_name = field
    @lexer.eat_delim("=")
    new_value = expression
    pred = Predicate.new
    if @lexer.match_keyword?("where")
      @lexer.eat_keyword("where")
      pred = predicate
    end
    ModifyData.new(table_name, field_name, new_value, pred)
  end

  def create
    @lexer.eat_keyword("create")
    if @lexer.match_keyword?("table")
      create_table
    elsif @lexer.match_keyword?("view")
      create_view
    else
      create_index
    end
  end

  def create_table
    @lexer.eat_keyword("table")
    table_name = @lexer.eat_identifier
    @lexer.eat_delim("(")
    schema = field_defs
    @lexer.eat_delim(")")
    CreateTableData.new(table_name, schema)
  end

  def create_view
    @lexer.eat_keyword("view")
    view_name = @lexer.eat_identifier
    @lexer.eat_keyword("as")
    query_data = query
    CreateViewData.new(view_name, query_data)
  end

  def create_index
    @lexer.eat_keyword("index")
    index_name = @lexer.eat_identifier
    @lexer.eat_keyword("on")
    table_name = @lexer.eat_identifier
    @lexer.eat_delim("(")
    field_name = field
    @lexer.eat_delim(")")
    CreateIndexData.new(index_name, table_name, field_name)
  end

  private

  def field_list
    fields = [field]
    while @lexer.match_delim?(",")
      @lexer.eat_delim(",")
      fields << field
    end
    fields
  end

  def const_list
    constants = [constant]
    while @lexer.match_delim?(",")
      @lexer.eat_delim(",")
      constants << constant
    end
    constants
  end

  def field_defs
    schema = field_def
    while @lexer.match_delim?(",")
      @lexer.eat_delim(",")
      schema.add_all(field_def)
    end
    schema
  end

  def field_def
    field_name = field
    field_type(field_name)
  end

  def field_type(field_name)
    schema = Schema.new
    if @lexer.match_keyword?("int")
      @lexer.eat_keyword("int")
      schema.add_int_field(field_name)
    else
      @lexer.eat_keyword("varchar")
      @lexer.eat_delim("(")
      str_len = @lexer.eat_int_constant
      @lexer.eat_delim(")")
      schema.add_string_field(field_name, str_len)
    end
    schema
  end
end
