#!/usr/bin/env ruby -w

require './lib/alias.rb'

nvars = 10
# STDERR.puts "Enter pairs of x, p(x) (one pair per line)"
Dir["test/infile.*"].each do |f_name|
  x = []
  probs = []
  f = File.open(f_name, "r")
  while line = f.gets do
    inputs = line.strip.split(/[\s,;:]+/).map{|x| x.to_f}
    x << inputs[0]
    probs << inputs[1]
  end
  begin
    at = AliasTable.new(x, probs)
    nvars.times {print at.generate, "\n"}
    f.close
  rescue Exception => e
    puts e.message
  end
end
