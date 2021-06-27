require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: yaml2sql.rb [options]"

  opts.on("-i", "--input", "Input directory path") do |val|
    options[:input] = val
  end

  opts.on("-o", "--output", "Output directory path") do |val|
    options[:output] = val
  end
end.parse!

p options
p ARGV
