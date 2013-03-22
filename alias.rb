class AliasTable
  
  def initialize(values, p_values)
    if values.length != p_values.length
      raise "Args to AliasTable must be vectors of the same length."
    end  
    if p_values.reduce(:+).not_close_enough(1.0)
      raise "p_valuess must sum to 1.0"
    end
    p_values.each {|p| raise "p_valuess must be positive" if p <= 0.0}
    @values = values
    @p_values = p_values.clone
    @alias = Array.new(values.length)
    @p_primary = Array.new(values.length, 1.0)
    @equiprob = 1.0 / values.length
    @deficit_set = []
    @surplus_set = []
    @values.each_index {|i| classify(i) }
    while @deficit_set.length > 0 do
      @deficit_set.sort! {|i, j| @p_values[i] < @p_values[j] ? -1 : 1 }
      deficit_column = @deficit_set.shift
      surplus_column = @surplus_set.shift
      @p_primary[deficit_column] = @p_values[deficit_column] / @equiprob
      @alias[deficit_column] = @values[surplus_column]
      @p_values[surplus_column] -= @equiprob - @p_values[deficit_column]
      classify(surplus_column)
    end
  end
  
  def generate
    column = rand(@values.length)
    rand < @p_primary[column] ? @values[column] : @alias[column]
  end
  
  private 
  def classify(i)
    if @p_values[i].not_close_enough(@equiprob)
      if @p_values[i] < @equiprob
        @deficit_set << i
      else
        @surplus_set << i
      end
    end
  end

end

class Numeric
  def not_close_enough(n)
    ((self - n) / self).abs > 1E-12
  end
end
