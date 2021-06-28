#!/usr/bin/env ruby
require 'optparse'
require 'yaml'

options = {}

OptionParser.new do |opts|
  opts.banner = "Usage: yaml2sql.rb [options]"

  opts.on("-i", "--input [DIR]", "Input directory path") do |v|
    options[:input] = v
  end

  opts.on("-o", "--output [DIR]", "Output directory path") do |v|
    options[:output] = v
  end
end.parse!


def yaml_to_sql(yaml)
  table = ''
  columns = []
  values = []

  yaml['data'].each do |t, r|
    table = t

    r.each do |n, fs|
      fs.each do |c, v|
        columns << c

        if v.is_a? String
          values << "'" + v + "'"
        else
          values << v
        end
      end

      yield "INSERT INTO #{table} (#{columns.join(', ')}) VALUES (#{values.join(', ')});"
    end
  end

end

Dir.glob("#{options[:input]}/*.yaml") do |yaml_file|
  sql_file = yaml_file.sub(options[:input], options[:output])
  sql_file = sql_file.sub('.yaml', '.sql')

  yaml = YAML.load_file(yaml_file)

  File.open(sql_file, 'w') do |f|
    yaml_to_sql(yaml) do |sql|
      f.puts sql
    end
  end
end
