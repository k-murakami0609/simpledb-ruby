# frozen_string_literal: true

class SqlLexer
  KEY_WORDS = %w[
    select from where and
    insert into values delete
    update set
    create table int varchar view as index on
  ].freeze

  def initialize(query)
    @tokens = query.split(/(\s|,|\(|\))/).reject { |s| s.empty? || /\A[[:space:]]*\z/.match?(s) }
  end

  def match_delim?(word)
    @tokens.first == word
  end

  def match_int_constant?
    token = @tokens.first
    token.to_f.to_s == token.to_s || token.to_i.to_s == token.to_s
  end

  def match_string_constant?
    token = @tokens.first || ""
    token[0] == "'"
  end

  def match_keyword?(word)
    @tokens.first&.downcase == word.downcase
  end

  def match_identifier?
    !KEY_WORDS.include?(@tokens.first&.downcase || "")
  end

  def eat_delim(word)
    if match_delim?(word)
      @tokens.shift
    else
      raise "Expected #{word} but found #{@tokens[0]}"
    end
  end

  def eat_int_constant
    if match_int_constant?
      @tokens.shift.to_i
    else
      raise "Expected int but found #{@tokens[0]}"
    end
  end

  def eat_string_constant
    if match_string_constant?
      @tokens.shift || ""
    else
      raise "Expected string but found #{@tokens[0]}"
    end
  end

  def eat_keyword(word)
    if match_keyword?(word)
      @tokens.shift || ""
    else
      raise "Expected #{word} but found #{@tokens[0]}"
    end
  end

  def eat_identifier
    if match_identifier?
      @tokens.shift || ""
    else
      raise "Expected identifier but found #{@tokens[0]}"
    end
  end
end
