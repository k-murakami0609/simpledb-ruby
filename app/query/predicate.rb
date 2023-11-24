# frozen_string_literal: true

class Predicate
  attr_accessor :terms

  # Creates an empty predicate, corresponding to "true".
  def initialize(term = nil)
    @terms = []
    @terms << term unless term.nil?
  end

  # Modifies the predicate to be the conjunction of itself and the specified predicate.
  def conjoin_with(predicate)
    @terms += predicate.terms
  end

  # Returns true if the predicate evaluates to true with respect to the specified scan.
  def satisfied?(scan)
    @terms.all? { |term| term.satisfied?(scan) }
  end

  # Calculates the extent to which selecting on the predicate reduces the number of records output by a query.
  def reduction_factor(plan)
    @terms.reduce(1.0) { |factor, term| factor * term.reduction_factor(plan) }
  end

  # Return the subpredicate that applies to the specified schema.
  def select_sub_predicate(schema)
    result = Predicate.new
    @terms.each { |term| result.terms << term if term.applies_to?(schema) }
    result.terms.empty? ? nil : result
  end

  # Return the subpredicate consisting of terms that apply to the union of the two specified schemas.
  def join_sub_predicate(schema1, schema2)
    result = Predicate.new
    new_schema = Schema.new
    new_schema.add_all(schema1)
    new_schema.add_all(schema2)
    @terms.each do |term|
      if !term.applies_to?(schema1) && !term.applies_to?(schema2) && term.applies_to?(new_schema)
        result.terms << term
      end
    end
    result.terms.empty? ? nil : result
  end

  # Determine if there is a term of the form "Field = constant"
  def equates_with_constant(field_name)
    term = @terms.find { |term| term.equates_with_constant(field_name) }
    term&.equates_with_constant(field_name)
  end

  # Determine if there is a term of the form "Field1 = Field2"
  def equates_with_field(field_name)
    term = @terms.find { |term| term.equates_with_field(field_name) }
    term&.equates_with_field(field_name)
  end

  def to_s
    @terms.map(&:to_s).join(" and ")
  end
end
