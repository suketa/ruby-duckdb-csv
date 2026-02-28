# frozen_string_literal: true

require 'duckdb'
require 'csv'
require_relative 'version'

module DuckDB
  module CSV
    class TableAdapter
      class << self
        def register!
          DuckDB::TableFunction.add_table_adapter(::CSV, new)
        end
      end

      def call(csv, name, columns: nil)
        columns ||= infer_columns(csv)
        DuckDB::TableFunction.create(name:, columns:) do |_func_info, output|
          write_row(csv, output)
        end
      end

      private

      def write_row(csv, output)
        line = csv.readline
        if line
          line.each_with_index { |cell, index| output.set_value(index, 0, cell[1]) }
          1
        else
          csv.rewind
          0
        end
      end

      def infer_columns(csv)
        headers = csv.first.headers
        csv.rewind
        headers.to_h { |header| [header, DuckDB::LogicalType::VARCHAR] }
      end
    end
  end
end
