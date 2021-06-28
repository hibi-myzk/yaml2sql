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

def fake(str)
  if str.start_with?("Faker.") || str.start_with?("Gimei.")
    begin
      eval str
    rescue
      str
    end
  elsif str =~ /\{UUID\}/
    str.gsub "{UUID}", SecureRandom.uuid
  else
    str
  end
end

def yaml_to_sql(yaml)
  yaml['data'].each do |t, records|
    table = t

    records.each do |name, fields|
      columns = []
      values = []

      fields.each do |c, v|
        columns << c

        if v.is_a? String
          values << "'" + fake(v) + "'"
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
