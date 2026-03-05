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
        row = csv.readline

        if row.nil?
          csv.rewind
          return 0
        end

        write_fields(extract_fields(row), output)
        1
      end

      def extract_fields(row)
        row.is_a?(::CSV::Row) ? row.fields : row
      end

      def write_fields(fields, output)
        fields.each_with_index do |field, index|
          type = output.get_vector(index).logical_type
          field = DuckDB.cast(field, type)
          output.set_value(index, 0, field)
        end
      end

      def infer_columns(csv)
        columns = csv.headers ? headers_to_columns(csv) : create_columns_from_first_row(csv)
        csv.rewind
        columns
      end

      def headers_to_columns(csv)
        csv.first.headers.to_h { |header| [header, :varchar] }
      end

      def create_columns_from_first_row(csv)
        first_row = csv.first
        first_row.size.times.with_object({}) do |i, columns|
          columns["col#{i + 1}"] = :varchar
        end
      end
    end
  end
end
