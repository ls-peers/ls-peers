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
        u.slack_name,
        u.full_name,
        u.preferred_name,
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

  def check_email(email) 
    sql = <<~SQL
      SELECT id FROM users 
      WHERE email = $1
    SQL

    result = query(sql, email)

    return nil if result.ntuples == 0
    result.first
  end

  def add_new_user(email, password, full_name)
    sql = <<~SQL
      INSERT INTO users(email, password, full_name)
        VALUES($1, $2, $3)
    SQL

    query(sql, email, password, full_name)
  end

  def retrieve_user_credentials(id) 
    sql = <<~SQL
      SELECT email, password
      FROM users
      WHERE id = $1
    SQL
    result = query(sql, id)

    return nil if result.ntuples == 0
    result.first 
  end

  def update_user_data(id, preferred_name, slack_name, course, track, timezone, about_me)
    sql = <<~SQL
      UPDATE users
        SET preferred_name = $2, slack_name = $3, 
            course_id = $4, track_id = $5, 
            timezone_id = $6, about_me = $7
        WHERE id = $1
    SQL

    query(sql, id, preferred_name, slack_name, course, track, timezone, about_me)
  end

  def update_user_preferences(id, *preferences)
    sql = <<~SQL
    INSERT INTO users_preferences(user_id, preference_id)
      VALUES($1, unnest(ARRAY$2))                        -- unnest(ARRAY[1,2]) -> Expands an array into a set of rows. The array's elements are read out in storage order.
    SQL
    query(sql, id, preferences)
  end

  private

  def tuple_to_user(tuple)
    slack_name = tuple["slack_name"]
    preferred_name = tuple["preferred_name"]
    about_me = tuple["about_me"]
    track = tuple["track"]
    course = tuple["course"]
    timezone = tuple["timezone"]

    User.new(
      slack_name,
      preferred_name,
      about_me,
      track,
      course,
      timezone
    )
  end
end
