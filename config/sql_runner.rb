require_relative 'environment'

class SQLRunner
  def initialize(db)
    @db = db
  end

  def execute_sql(sql, args=[])
    @db.exec(sql, args=[])
  end

  def create_table
    sql = <<-SQL
      CREATE TABLE songs(
        id SERIAL,
        track_name TEXT,
        artist TEXT,
        album TEXT,
        url TEXT,
        num_streams INT
      );
    SQL
    execute_sql(sql)
  end

end
