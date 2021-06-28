# yaml2sql

## Installation

```ruby
$ git clone https://github.com/hibi-myzk/yaml2sql.git
$ cd yaml2sql
$ chmod +x ./yaml2sql.rb
$ bundle install [--path vendor/bundle]
```

## Usage

### YAML format

```yaml
data:
  table_name2:
    data_name1:
        column_name1: "Value"
        column_name2: "Facker.Name.name"
        column_name3: "Gimei.address.kanji"
    data_name2:
        column_name1: "Value"
        column_name2: "Facker.Name.name"
        column_name3: "Gimei.address.kanji"
```

reference:
- [faker\-ruby/faker: A library for generating fake data such as names, addresses, and phone numbers\.](https://github.com/faker-ruby/faker)
- [willnet/gimei: random Japanese name and address generator](https://github.com/willnet/gimei)

### Generate SQL

```ruby
$ ./yaml2sql -i /path/to/dir -o /path/to/dir
```
