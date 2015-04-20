#!/usr/bin/env ruby -w

# Generate values from a categorical distribution in constant
# time, regardless of the number of categories.  This clever algorithm
# uses conditional probability to construct a table comprised of columns
# which have a primary value and an alias.  Generating a value consists
# of picking any column (with equal probabilities), and then picking
# between the primary and the alias based on appropriate conditional
# probabilities.
#
class AliasTable
  TOLERANCE = Rational(1,1E15)
  # Construct an alias table from a set of values and their associated
  # probabilities.  Values and their probabilities must be synchronized,
  # i.e., they must be arrays of the same length.  Values can be
  # anything, but the probabilities must be positive numbers that
  # sum to one.
  #
  # *Arguments*::
  #   - +x_set+ -> the set of values to generate from.
  #   - +p_value+ -> the synchronized set of probabilities associated
  #     with the value set.
  # *Raises*::
  #   - RuntimeError if +x_set+ and +p_value+s are different lengths.
  #   - RuntimeError if any +p_value+ are negative.
  #   - RuntimeError if +p_value+ don't sum to one.
  #
  def initialize(x_values, p_values)
    if x_values.length != p_values.length
      raise "Args to AliasTable must be vectors of the same length."
    end
    p = p_values.map do |current_p|
      raise "p_values must be positive" if current_p <= 0.0
      Rational(current_p)
    end
    unless (p.reduce(:+) - Rational(1)).abs < TOLERANCE
      raise "p_values must sum to 1.0"
    end
    @x = x_values.clone.freeze
    @alias = Array.new(@x.length)
    @p_primary = Array.new(@x.length, 1.0)
    equiprob = Rational(1, @x.length)
    deficit_set = []
    surplus_set = []
    @x.each_index do |i|
      unless (p[i] - equiprob).abs < TOLERANCE
        (p[i] < equiprob ? deficit_set : surplus_set) << i
      end
    end
    until deficit_set.empty? do
      deficit = deficit_set.pop
      surplus = surplus_set.pop
      @p_primary[deficit] = p[deficit] / equiprob
      @alias[deficit] = @x[surplus]
      p[surplus] -= equiprob - p[deficit]
      unless (p[surplus] - equiprob).abs < TOLERANCE
        (p[surplus] < equiprob ? deficit_set : surplus_set) << surplus
      end
    end
  end

  # Returns a random outcome from this object's distribution.
  # The generate method is O(1) time, but is not an inversion
  # since two uniforms are used for each value that gets generated.
  #
  def generate
    column = rand(@x.length)
    rand <= @p_primary[column] ? @x[column] : @alias[column]
  end

end
