#!/usr/bin/env ruby -w

require 'alias.rb'

x = []
probs = []
STDERR.puts "Enter pairs of x, p(x) (one pair per line)"
while line=STDIN.gets do
  inputs = line.strip.split(/[\s,;:]+/)
  x << inputs[0].to_f
  probs << inputs[1].to_f
end
at = AliasTable.new(x, probs)
10000.times {print at.generate, "\n"}
