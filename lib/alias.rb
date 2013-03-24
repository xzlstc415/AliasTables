#!/usr/bin/env ruby -w

require 'skewheap'

# Generate values from a categorical distribution in constant
# time, regardless of the number of categories.  This clever algorithm
# uses conditional probability to construct a table comprised of columns
# which have a primary value and an alias.  Generating a value consists
# of picking any column (with equal probabilities), and then picking
# between the primary and the alias based on appropriate conditional
# probabilities.
#
class AliasTable

  # Construct an alias table from a set of values and their associated
  # probabilities.  Values and their probabilities must be synchronized,
  # i.e., they must be arrays of the same length.  Values can be
  # anything, but the probabilities must be positive numbers that
  # sum to one.
  # 
  def initialize(values, p_values)
    if values.length != p_values.length
      raise "Args to AliasTable must be vectors of the same length."
    end  
    p_values.each {|p| raise "p_values must be positive" if p <= 0.0}
    if p_values.reduce(:+).not_close_enough(1.0)
      raise "p_values must sum to 1.0"
    end
    @values = values.clone
    @p_values = p_values.clone
    @alias = Array.new(values.length)
    @p_primary = Array.new(values.length, 1.0)
    @equiprob = 1.0 / values.length
    @deficit_set = SkewHeap.new
    @surplus_set = []
    @values.each_index {|i| classify(i) }
    until @deficit_set.empty? do
      deficit_column = @deficit_set.pop
      surplus_column = @surplus_set.shift
      @p_primary[deficit_column] = @p_values[deficit_column] / @equiprob
      @alias[deficit_column] = @values[surplus_column]
      @p_values[surplus_column] -= @equiprob - @p_values[deficit_column]
      classify(surplus_column)
    end
  end

  # Generate a random outcome.  This process requires constant time,
  # but is not an inversion since two uniforms are used for each value
  # that gets generated.
  # 
  def generate
    column = rand(@values.length)
    rand < @p_primary[column] ? @values[column] : @alias[column]
  end
  
  private 
  def classify(i)
    if @p_values[i].not_close_enough(@equiprob)
      if @p_values[i] < @equiprob
        @deficit_set.push i
      else
        @surplus_set << i
      end
    end
  end

end

class Numeric
  # Expand class Numeric to detect whether two values are within a
  # tolerance of 10^-15 of each other.
  def not_close_enough(n)
    ((self - n) / self).abs > 1E-15
  end
end
