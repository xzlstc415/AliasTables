#!/usr/bin/env ruby -w

require 'alias.rb'

x = [1, 3, 7, 42]
probs = [0.1, 0.2, 0.3, 0.4]
at = AliasTable.new(x, probs)
10000.times {puts at.generate.to_s}
