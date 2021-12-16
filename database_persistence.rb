require "pg"

class DatabasePersistence
  def initialize()
    @db = if Sinatra::Base.production?
      PG.connect(ENV['DATABASE_URL'])
    else
      PG.connect(dbname: "lspeers")
    end
  end

  def disconnect
    @db.close
  end

  def query(statement, *params)
    @db.exec_params(statement, params)
  end

  def first_user()
    sql = <<~SQL
      SELECT * FROM users
    SQL

    result = query(sql)

    return nil if result.ntuples == 0
    tuple = result.first
  end
end