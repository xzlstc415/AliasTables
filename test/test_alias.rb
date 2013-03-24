#!/usr/bin/env ruby -w

require 'alias'

nvars = 1000000
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
  counts = {}
  expected_counts = {}
  while line = f.gets do
    inputs = line.strip.split(/[\s,;:]+/)
    x << inputs[0]
    counts[inputs[0]] = 0
    probs << inputs[1].to_f
    n_hat = probs[-1] * nvars
    half_width = 2.5 * Math::sqrt(n_hat * (1.0 - probs[-1])) if n_hat > 0
    expected_counts[inputs[0]] = "%d +/- %d" % [n_hat, half_width]
  end
  f.close
  begin
    at = AliasTable.new(x, probs)
    nvars.times {counts[at.generate] += 1}
    puts "\nAll four values should be in range 95\% of the time:"
    counts.each_key do |k|
      printf "%s: Expected %s, got %d\n", k, expected_counts[k], counts[k]
    end
  rescue Exception => e
    puts e.message
  end
end
