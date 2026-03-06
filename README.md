# ruby-duckdb-csv

## Description

This gem `duckdb-csv` provides a CSV table adapter for [ruby-duckdb](https://github.com/suketa/ruby-duckdb).
You can query Ruby's `CSV` objects using SQL through DuckDB by using this gem.
This gem is a sample implementation of a `DuckDB::TableFunction`.

## Requirement

- Ruby
- [duckdb](https://github.com/suketa/ruby-duckdb)
- [csv](https://github.com/ruby/csv)

## How to install

```sh
gem install duckdb-csv
```

Or add the following line to your `Gemfile`:

```ruby
gem 'duckdb-csv'
```

## Usage

### Basic usage

```ruby
require 'duckdb'
require 'duckdb/csv/table_adapter'

db = DuckDB::Database.open
con = db.connect

csv_io = StringIO.new("id,name,age\n1,Alice,30\n2,Bob,25\n3,Charlie,35")
csv = CSV.new(csv_io, headers: true)

DuckDB::CSV::TableAdapter.register!

con.execute('SET threads=1') # currently the CSV table adapter is not thread-safe, so we set threads to 1
con.expose_as_table(csv, 'csv_table')
result = con.query('SELECT * FROM csv_table()')
result.each do |row|
  puts row.inspect
end
# => ["1", "Alice", "30"]
# => ["2", "Bob", "25"]
# => ["3", "Charlie", "35"]
```

### Specifying column types

By default, all columns are treated as `VARCHAR`. You can specify column types using the `columns` option.

```ruby
require 'duckdb'
require 'duckdb/csv/table_adapter'

db = DuckDB::Database.open
con = db.connect

csv_io = StringIO.new(<<~CSV.strip)
  id,name,age,height,birthday,created_at
  1,Alice,30,1.65,1990-01-02,2023-01-01T10:11:12
  2,Bob,25,1.80,1995-05-15,2024-02-03T11:12:13
  3,Charlie,35,1.75,1985-10-30,2025-04-05T12:13:14
CSV
csv = CSV.new(csv_io, headers: true)

DuckDB::CSV::TableAdapter.register!

con.execute('SET threads=1') # currently the CSV table adapter is not thread-safe, so we set threads to 1
con.expose_as_table(
  csv, 'csv_table',
  columns: {
    'id' => :integer,
    'name' => :varchar,
    'age' => :integer,
    'height' => :float,
    'birthday' => :date,
    'created_at' => :timestamp
  }
)

result = con.query('SELECT * FROM csv_table()')
result.each do |row|
  puts row.inspect
end
# => [1, "Alice", 30, 1.65, #<Date: 1990-01-02>, 2023-01-01 10:11:12 +0900]
# => [2, "Bob", 25, 1.80, #<Date: 1995-05-15>, 2024-02-03 11:12:13 +0900]
# => [3, "Charlie", 35, 1.75, #<Date: 1985-10-30>, 2025-04-05 12:13:14 +0900]
```

### Headerless CSV

When CSV has no headers, columns are automatically named `col1`, `col2`, `col3`, etc.

```ruby
csv_io = StringIO.new("1,Alice,30\n2,Bob,25\n3,Charlie,35")
csv = CSV.new(csv_io, headers: false)

DuckDB::CSV::TableAdapter.register!

con.execute('SET threads=1') # currently the CSV table adapter is not thread-safe, so we set threads to 1
con.expose_as_table(csv, 'csv_table')
result = con.query('SELECT col1, col2, col3 FROM csv_table()')
result.each do |row|
  puts row.inspect
end
# => ["1", "Alice", "30"]
# => ["2", "Bob", "25"]
# => ["3", "Charlie", "35"]
```

## License

[MIT License](LICENSE).
