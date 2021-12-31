require "pg"

require_relative "user"

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

  def user_by_id(id)
    sql = <<~SQL
      SELECT
        u.slackname,
        u.firstname,
        u.lastname,
        u.about_me,
        t.name AS track,
        c.code AS course,
        ti.name AS timezone
      FROM users u
        JOIN tracks t ON u.track_id = t.id
        JOIN courses c ON u.course_id = c.id
        JOIN timezones ti ON u.timezone_id = ti.id
      WHERE u.id = $1
    SQL

    result = query(sql, id)
    tuple = result.first
    tuple_to_user(tuple)
  end

  def first_user()
    sql = <<~SQL
      SELECT * FROM users
    SQL

    result = query(sql)

    return nil if result.ntuples == 0
    tuple = result.first
  end

  private

  def tuple_to_user(tuple)
    slackname = tuple["slackname"]
    firstname = tuple["firstname"]
    lastname = tuple["lastname"]
    about_me = tuple["about_me"]
    track = tuple["track"]
    course = tuple["course"]
    timezone = tuple["timezone"]

    User.new(
      slackname,
      firstname,
      lastname,
      about_me,
      track,
      course,
      timezone
    )
  end
end
