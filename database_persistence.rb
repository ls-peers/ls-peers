require "pg"
require "pry"

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

  # ------ adds new record to db, using data provided by user
  def add_new_user(email, password, full_name)
    sql = <<~SQL
      INSERT INTO users(email, password, full_name)
      VALUES($1, $2, $3)
    SQL

    query(sql, email, password, full_name)
  end

  # ------ retrieves all user data by provided user id
  def get_user_by_id(id)
    sql = <<~SQL
      SELECT
        u.id,
        u.email,
        u.password,
        u.full_name,
        u.preferred_name,
        u.slack_name,
        u.about_me,
        t.name AS track,
        c.code AS course,
        ti.name AS timezone
      FROM users u
        LEFT JOIN tracks t ON u.track_id = t.id
        LEFT JOIN courses c ON u.course_id = c.id
        LEFT JOIN timezones ti ON u.timezone_id = ti.id
      WHERE u.id = $1
    SQL

    result = query(sql, id)
    tuple = result.first
    tuple_to_user(tuple) if tuple
  end

  # -------- retrieves all user data by provided user email
  def get_user_by_email(email)
    sql = <<~SQL
      SELECT
        u.id,
        u.email,
        u.password,
        u.full_name,
        u.preferred_name,
        u.slack_name,
        u.about_me,
        t.name AS track,
        c.code AS course,
        ti.name AS timezone
      FROM users u
        LEFT JOIN tracks t ON u.track_id = t.id
        LEFT JOIN courses c ON u.course_id = c.id
        LEFT JOIN timezones ti ON u.timezone_id = ti.id
      WHERE u.email = $1
    SQL

    result = query(sql, email)
    tuple = result.first
    tuple_to_user(tuple) if tuple
  end

  def get_tracks
    sql = <<~SQL
      SELECT id, name FROM tracks;
    SQL
    result = query(sql)
    result.to_a # yields array of hashes
  end

  def get_courses
    sql = <<~SQL
      SELECT id, code FROM courses;
    SQL
    result = query(sql)
    result.to_a # yields array of hashes
  end

  def get_timezones
    sql = <<~SQL
      SELECT id, code FROM timezones;
    SQL
    result = query(sql)
    result.to_a # yields array of hashes
  end

  def get_preferences
    sql = <<~SQL
      SELECT id, preference FROM preferences;
    SQL
    result = query(sql)
    result.to_a # yields array of hashes
  end

  # ------ updates user data based on user id
  def update_user_data(id, preferred_name, slack_name, track, course, timezone, about_me)
    sql = <<~SQL
      UPDATE users
        SET preferred_name = $2, slack_name = $3,
            track_id = $4, course_id = $5,
            timezone_id = $6, about_me = $7
        WHERE id = $1
    SQL

    query(sql, id, preferred_name, slack_name, track, course, timezone, about_me)
  end

  # ------ updates user preferences table based on user id
  # --> trying to handle several preferences simultaneously...
  # def update_user_preferences(id, *preferences)
  #   sql = <<~SQL
  #   INSERT INTO users_preferences(user_id, preference_id)
  #     VALUES($1, unnest(ARRAY$2))                        -- unnest(ARRAY[1,2]) -> Expands an array into a set of rows. The array's elements are read out in storage order.
  #   SQL
  #   query(sql, id, preferences)
  # end

  # ------ updates user preferences table based on user id
  # --> this version can only handle one preference
  def update_user_preferences(id, preference)
    sql = <<~SQL
    INSERT INTO users_preferences(user_id, preference_id)
      VALUES($1, $2)
    SQL
    query(sql, id, preference)
  end

  private

  def tuple_to_user(tuple)
    id = tuple["id"]
    email = tuple["email"]
    password = tuple["password"]
    full_name = tuple["full_name"]
    preferred_name = tuple["preferred_name"]
    slack_name = tuple["slack_name"]
    track = tuple["track"]
    course = tuple["course"]
    timezone = tuple["timezone"]
    about_me = tuple["about_me"]

    User.new(id, email, password, full_name, preferred_name, slack_name, track, course, timezone, about_me)
  end
end
