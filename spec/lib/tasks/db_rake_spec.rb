require 'spec_helper'

describe 'db:deprecated:remove_tables_and_columns', skip_in_build: true do
  include_context 'rake'

    it 'removes tables and columns that are postfixed with "_old"' do
      tables_with_old_postfix.should_not be_empty
      columns_with_old_postfix.should_not be_empty

      subject.invoke

      tables_with_old_postfix.should be_empty
      columns_with_old_postfix.should be_empty
    end

    it 'does not raise exceptions for constraints' do
      expect {
        subject.invoke
      }.to_not raise_error
    end

    def tables_with_old_postfix
      statement = <<-stmnt
        SELECT T.[name] AS [table_name], AC.[name] AS [column_name]
        FROM sys.[tables] AS T
          INNER JOIN sys.[all_columns] AC ON T.[object_id] = AC.[object_id]
        WHERE T.[is_ms_shipped] = 0 AND T.[name] LIKE '%_old'
      stmnt

      ActiveRecord::Base.connection.select_all(statement)
    end

    def columns_with_old_postfix
      statement = <<-stmnt
        SELECT T.[name] AS [table_name], AC.[name] AS [column_name]
        FROM sys.[tables] AS T
          INNER JOIN sys.[all_columns] AC ON T.[object_id] = AC.[object_id]
        WHERE T.[is_ms_shipped] = 0 AND AC.[name] LIKE '%_old'
      stmnt

      ActiveRecord::Base.connection.select_all(statement)
    end

end

describe 'db:deprecated:remove_temporary_tables', skip_in_build: true do
  include_context 'rake'

  it 'removes all tables prefixed with "tmp_"' do
    tables_with_tmp.should_not be_empty

    subject.invoke

    tables_with_tmp.should be_empty
  end

  def tables_with_tmp
    statement = <<-stmnt
      SELECT T.[name] AS [table_name], AC.[name] AS [column_name]
      FROM sys.[tables] AS T
        INNER JOIN sys.[all_columns] AC ON T.[object_id] = AC.[object_id]
      WHERE T.[is_ms_shipped] = 0 AND T.[name] LIKE 'tmp%'
    stmnt

    ActiveRecord::Base.connection.select_all(statement)
  end
end
