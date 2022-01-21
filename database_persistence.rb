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

  # ------ retrieves user id by provided user email ------------ NO BUGS
  def get_id_by_email(email)
    sql = <<~SQL
      SELECT id
      FROM users
      WHERE email = $1
    SQL

    result = query(sql, email)
    return nil if result.ntuples == 0
    result.first["id"]                      # "e45f23ec-e54f..." | if used as 'result.first' returns {"id"=>"e45f23ec-e54f..."}
  end

  # ------ adds new record to db, using data provided by user ------------ NO BUGS
  def add_new_user(email, password, full_name)       
    sql = <<~SQL
      INSERT INTO users(email, password, full_name)
      VALUES($1, $2, $3)
    SQL

    query(sql, email, password, full_name)
  end

  # ------- retrieves user password by provided email ------------ NO BUGS
  def get_password_by_email(email)
    sql = <<~SQL
      SELECT password
      FROM users
      WHERE email = $1
    SQL

    result = query(sql, email)
    return nil if result.ntuples == 0
    result.first["password"]                # "$2a$12$W6A2..." | if used as 'result.first' returns {"password"=>"$2a$12$W6A2....."}
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
        c.code AS course,
        t.name AS track,
        ti.name AS timezone
      FROM users u
        LEFT JOIN tracks t ON u.track_id = t.id
        LEFT JOIN courses c ON u.course_id = c.id
        LEFT JOIN timezones ti ON u.timezone_id = ti.id
      WHERE u.id = $1
    SQL

    result = query(sql, id)
    tuple = result.first
    tuple_to_user(tuple)
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
        c.code AS course,
        t.name AS track,
        ti.name AS timezone
      FROM users u
        LEFT JOIN courses c ON u.course_id = c.id
        LEFT JOIN tracks t ON u.track_id = t.id
        LEFT JOIN timezones ti ON u.timezone_id = ti.id
      WHERE u.email = $1
    SQL

    result = query(sql, email)
    tuple = result.first
    tuple_to_user(tuple)
  end

  # ------ updates user data based on user id | called in 'profile/edit' route
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

  # ------ updates user preferences table based on user id | called in 'profile/edit' route
  def update_user_preferences(id, *preferences)
    sql = <<~SQL
    INSERT INTO users_preferences(user_id, preference_id)
      VALUES($1, unnest(ARRAY$2))                        -- unnest(ARRAY[1,2]) -> Expands an array into a set of rows. The array's elements are read out in storage order.
    SQL
    query(sql, id, preferences)
  end

  private

  def tuple_to_user(tuple)
    id = tuple["id"]
    email = tuple["email"]
    password = tuple["password"]
    full_name = tuple["full_name"]
    preferred_name = tuple["preferred_name"]
    slack_name = tuple["slack_name"]
    about_me = tuple["about_me"]
    course = tuple["course"]
    track = tuple["track"]
    timezone = tuple["timezone"]

    User.new(id, email, password, full_name)  # Add -> preferred_name, slack_name, about_me, course, track, timezone
  end
end
