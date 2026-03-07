# Copilot Instructions

## Commands

```sh
bundle exec rake test          # run all tests
bundle exec ruby -Ilib -Itest test/duckdb/csv/table_adapter_test.rb  # run single test file
bundle exec ruby -Ilib -Itest test/duckdb/csv/table_adapter_test.rb -n test_s_register!  # run single test by name
bundle exec rubocop            # lint
```

## Architecture

This gem (`duckdb-csv`) implements a single-class CSV table adapter for [ruby-duckdb](https://github.com/suketa/ruby-duckdb). The sole public API is `DuckDB::CSV::TableAdapter`.

**Flow:**
1. `TableAdapter.register!` — registers the adapter once globally via `DuckDB::TableFunction.add_table_adapter(::CSV, instance)`
2. `con.expose_as_table(csv, 'name', columns: {...})` — exposes a `CSV` object as a named DuckDB table function
3. DuckDB calls the adapter's `call` method to obtain a `DuckDB::TableFunction`, passing a block that yields one row at a time via `write_row`
4. On exhaustion, `csv.rewind` is called so the table can be re-queried

**Column inference:**
- With headers → columns named after CSV headers, all typed `:varchar`
- Without headers → columns named `col1`, `col2`, … all typed `:varchar`
- Explicit `columns:` hash overrides inference with typed columns (`:integer`, `:float`, `:date`, `:timestamp`, `:varchar`)

## Key Conventions

- **Thread safety**: DuckDB's `TableFunction` is not thread-safe; tests and README examples always call `con.execute('SET threads=1')` before querying a CSV table.
- **Type casting**: Field values are cast via `DuckDB.cast(field, logical_type)` from the output vector's logical type — no manual type conversion in adapter code.
- **`frozen_string_literal: true`** is set in every file.
- Tests use Minitest and live under `test/duckdb/csv/`. Test class names match file names (`TableAdapterTest` in `table_adapter_test.rb`).
- RuboCop is configured with `rubocop-minitest` and `rubocop-rake` plugins; line length max is 120.
