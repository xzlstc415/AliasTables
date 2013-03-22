class Numeric
  def not_close_enough(n)
    (self - n).abs > 1E-12
  end
end

class AliasTable
  
  def initialize(value, p_value)
    if value.length != p_value.length
      raise "Args to AliasTable must be vectors of the same length."
    end  
    if p_value.reduce(:+).not_close_enough(1.0)
      raise "p_values must sum to 1.0"
    end
    p_value.each {|p| raise "p_values must be positive" if p <= 0.0}
    @value = value
    @p_value = p_value.clone
    @alias = Array.new(value.length)
    @p_primary = Array.new(value.length, 1.0)
    @equiprob = 1.0 / value.length
    @deficit_set = []
    @surplus_set = []
    @value.each_index {|i| classify(i) }
    while @deficit_set.length > 0 do
      @deficit_set.sort! {|i, j| @p_value[i] < @p_value[j] ? -1 : 1 }
      deficit_column = @deficit_set.shift
      surplus_column = @surplus_set.shift
      @p_primary[deficit_column] = @p_value[deficit_column] / @equiprob
      @alias[deficit_column] = @value[surplus_column]
      @p_value[surplus_column] -= @equiprob - @p_value[deficit_column]
      classify(surplus_column)
    end
  end
  
  private 
  def classify(i)
    if @p_value[i].not_close_enough(@equiprob)
      if @p_value[i] < @equiprob
        @deficit_set << i
      else
        @surplus_set << i
      end
    end
  end
  
  public
  def generate
    column = rand(@value.length)
    rand < @p_primary[column] ? @value[column] : @alias[column]
  end
  
end
