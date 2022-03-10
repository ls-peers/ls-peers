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
        EXTRACT(EPOCH FROM u.last_active) AS last_active_epoch,
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

    # ------ retrieves all user data by provided user id
    def get_user_by_partial_id(partial_id)
      sql = <<~SQL
        SELECT
          u.id,
          u.email,
          u.password,
          u.full_name,
          u.preferred_name,
          u.slack_name,
          u.about_me,
          EXTRACT(EPOCH FROM u.last_active) AS last_active_epoch,
          t.name AS track,
          c.code AS course,
          ti.name AS timezone
        FROM users u
          LEFT JOIN tracks t ON u.track_id = t.id
          LEFT JOIN courses c ON u.course_id = c.id
          LEFT JOIN timezones ti ON u.timezone_id = ti.id
        WHERE u.id::TEXT LIKE $1
      SQL
  
      result = query(sql, "%#{partial_id}")
      tuple = result.first
      tuple_to_user(tuple) if tuple
    end

  def get_user_with_preferences_by_id(user_id)
    user = self.get_user_by_id(user_id)
    preferences = self.get_user_preferences(user_id)
    user.preferences=(preferences)
    user
  end

  def get_user_with_preferences_by_partial_id(partial_user_id)
    user = self.get_user_by_partial_id(partial_user_id)
    preferences = self.get_user_preferences(user.id)
    user.preferences=(preferences)
    user
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
        EXTRACT(EPOCH FROM u.last_active) AS last_active_epoch,
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

  def get_user_preferences(user_id)
    sql = <<~SQL
      SELECT p.id, p.preference, p.category
      FROM users_preferences up
        JOIN preferences p ON up.preference_id = p.id
      WHERE up.user_id = $1
      GROUP BY 1,2,3
    SQL
    result = query(sql, user_id)
    result.to_a # yields array of hashes
  end

  def get_users(tracks = [], courses = [], timezones = [], preferences = [])
    sql = <<~SQL
      SELECT u.id, u.preferred_name, c.code AS course, t.name AS track, tz.code AS timezone
      FROM users u
        LEFT JOIN tracks t ON u.track_id = t.id
        LEFT JOIN courses c ON u.course_id = c.id
        LEFT JOIN timezones tz ON u.timezone_id = tz.id
        LEFT JOIN users_preferences up ON u.id = up.user_id
        LEFT JOIN preferences p ON up.preference_id = p.id
    SQL

    sql += ' WHERE 1 = 1'

    first = true
    tracks.each do |track|
      stmt = ' AND t.id = ' + track if first
      stmt = ' OR t.id = ' + track if !first
      sql += stmt
      first = false
    end if tracks

    first = true
    courses.each do |course|
      stmt = ' AND c.id = ' + course if first
      stmt = ' OR c.id = ' + course if !first
      sql += stmt
      first = false
    end if courses

    first = true
    timezones.each do |timezone|
      stmt = ' AND tz.id = ' + timezone if first
      stmt = ' OR tz.id = ' + timezone if !first
      sql += stmt
      first = false
    end if timezones

    first = true
    preferences.each do |preference|
      stmt = ' AND p.id = ' + preference if first
      stmt = ' OR p.id = ' + preference if !first
      sql += stmt
      first = false
    end if preferences

    sql += 'GROUP BY 1,2,3,4,5;'

    result = query(sql)

    result.to_a # yields array of hashes
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
      SELECT id, code, name FROM timezones;
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
            timezone_id = $6, about_me = $7,
            updated_at = NOW()
        WHERE id = $1
    SQL

    query(sql, id, preferred_name, slack_name, track, course, timezone, about_me)
  end

  # ------ updates user last active timestamp
  def update_user_last_active(id)
    sql = <<~SQL
      UPDATE users
        SET last_active = NOW(), updated_at = NOW()
      WHERE id = $1
    SQL

    query(sql, id)
  end

  # ------ updates user preferences table based on user id
  def update_user_preferences(id, preferences)
    sql = "INSERT INTO users_preferences(user_id, preference_id) VALUES "
    values = preferences.map do |preference|
      "('#{id}', #{preference})"
    end.join(',')
    sql = sql + values + ";"
    query(sql)
  end

  def delete_user_preferences(user_id)
    sql = <<~SQL
      DELETE FROM users_preferences WHERE user_id = $1
    SQL
    query(sql, user_id)
  end

  private

  def tuple_to_user(tuple)
    id = tuple["id"]
    email = tuple["email"]
    password = tuple["password"]
    full_name = tuple["full_name"]
    preferred_name = tuple["preferred_name"]
    slack_name = tuple["slack_name"]
    last_active_epoch = tuple["last_active_epoch"]
    track = tuple["track"]
    course = tuple["course"]
    timezone = tuple["timezone"]
    about_me = tuple["about_me"]

    User.new(id, email, password, full_name, preferred_name, last_active_epoch, slack_name, track, course, timezone, about_me)
  end
end
