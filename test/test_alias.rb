#!/usr/bin/env ruby -w

require './lib/alias.rb'

nvars = 10
begin
  at = AliasTable.new(["yes", "no"], [0.3, 0.3, 0.4])
  nvars.times {print at.generate, "\n"}
rescue Exception => e
  puts e.message
end
Dir["test/infile.*"].each do |f_name|
  x = []
  probs = []
  f = File.open(f_name, "r")
  while line = f.gets do
    inputs = line.strip.split(/[\s,;:]+/).map{|x| x.to_f}
    x << inputs[0]
    probs << inputs[1]
  end
  f.close
  begin
    at = AliasTable.new(x, probs)
    nvars.times {print at.generate, "\n"}
  rescue Exception => e
    puts e.message
  end
end
