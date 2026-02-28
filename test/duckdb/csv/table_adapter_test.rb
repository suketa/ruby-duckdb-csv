# frozen_string_literal: true

require 'test_helper'
require 'stringio'

module DuckDB
  module CSV
    class TableAdapterTest < Minitest::Test
      def setup
        @db = DuckDB::Database.open
        @con = @db.connect
      end

      def teardown
        @con.close
        @db.close
      end

      def test_s_register!
        csv_io = StringIO.new("id,name,age\n1,Alice,30\n2,Bob,25\n3,Charlie,35")
        csv = ::CSV.new(csv_io, headers: true)

        DuckDB::CSV::TableAdapter.register!

        @con.execute('SET threads=1') # Required for TableFunction to work correctly in single-threaded mode
        @con.expose_as_table(csv, 'csv_table')
        result = @con.query('SELECT * FROM csv_table()').to_a

        assert_equal %w[1 Alice 30], result[0]
        assert_equal %w[2 Bob 25], result[1]
        assert_equal %w[3 Charlie 35], result[2]
      end
    end
  end
end
