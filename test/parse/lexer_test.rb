# frozen_string_literal: true

require "minitest/autorun"

require_relative "../../app/server/simple_db"

class LexerTest < Minitest::Test
  def setup
    # Do nothing
  end

  def teardown
    # Do nothing
  end

  def test_lexer
    lexer = SqlLexer.new("select test, test2 from test_table where A = 1 and B = 'test'")
    assert_equal lexer.eat_keyword("Select"), "select"
    assert_equal lexer.eat_identifier, "test"
    assert_equal lexer.eat_delim(","), ","
    assert_equal lexer.eat_identifier, "test2"
    assert_equal lexer.eat_keyword("from"), "from"
    assert_equal lexer.eat_identifier, "test_table"
    assert_equal lexer.eat_keyword("where"), "where"
    assert_equal lexer.eat_identifier, "A"
    assert_equal lexer.eat_delim("="), "="
    assert_equal lexer.eat_int_constant, 1
    assert_equal lexer.eat_keyword("and"), "and"
    assert_equal lexer.eat_identifier, "B"
    assert_equal lexer.eat_delim("="), "="
    assert_equal lexer.eat_string_constant, "'test'"
  end
end
