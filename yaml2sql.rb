#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
require 'optparse'
require 'yaml'
require 'securerandom'
require 'faker'
require 'gimei'

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

def fake(str, objects)
  if str.start_with?("Faker") || str.start_with?("Gimei")
    begin
      eval str
    rescue => e
      p e
      str
    end
  elsif str =~ /\{\{UUID\}\}/
    str.gsub "{{UUID}}", SecureRandom.uuid
  elsif str =~ /\{\{([\w\.]+)\}\}/
    c = $1.split('.')
    begin
      objects[c[0]][c[1]]
    rescue => e
      p e
      str
    end
  else
    str
  end
end

def yaml_to_sql(yaml, objects)
  yaml['data'].each do |table, records|
    records.each do |name, fields|
      attributes = {}

      columns = []
      values = []

      fields.each do |c, val|
        columns << c

        if val.is_a? String
          v = fake(val, objects)

          if v.is_a? String
            values << "'" + v + "'"
            attributes[c] = v
          else
            values << v
            attributes[c] = v
          end
        else
          values << val
          attributes[c] = val
        end
      end

      objects[name] = attributes

      yield "INSERT INTO #{table} (#{columns.join(', ')}) VALUES (#{values.join(', ')});"
    end
  end

end

objects = {}

Dir.glob("#{options[:input]}/*.yaml") do |yaml_file|
  sql_file = yaml_file.sub(options[:input], options[:output])
  sql_file = sql_file.sub('.yaml', '.sql')

  yaml = YAML.load_file(yaml_file)

  File.open(sql_file, 'w') do |f|
    yaml_to_sql(yaml, objects) do |sql|
      f.puts sql
    end
  end
end
