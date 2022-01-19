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

  # ------ defined by scott to display test profile "/test/profile/:id" -> delete when not needed; but right now is in use in peers.rb
  def user_by_id(id)                        # BUG -> Tested with pry. See results below
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

    result = query(sql, id)               # #<PG::Result:0x00007fba0e8e3d28 status=PGRES_TUPLES_OK ntuples=0 nfields=7 cmd_tuples=0>
    tuple = result.first                  # nil  
    tuple_to_user(tuple)
  end

  # ------ takes an email provided by user and returns the id in user table that corresponds with that email
  def get_user_id_by_email(email)              # No bugs -> Tested with binding.pry. See results in comments below
    sql = <<~SQL
      SELECT id 
      FROM users 
      WHERE email = $1
    SQL

    result = query(sql, email)                 # #<PG::Result:0x00007fba0d8d69d0 status=PGRES_TUPLES_OK ntuples=2 nfields=1 cmd_tuples=2>
    return nil if result.ntuples == 0
    result.first["id"]                         # "e45f23ec-e54f-4867-826a-01d2aa08fbb6" ---- if using 'result.first' it returns {"id"=>"e45f23ec-e54f-4867-826a-01d2aa08fbb6"}
  end

  # ------ adds new record to db, using data provided by user
  def add_new_user(email, password, full_name)        # No bugs -> Tested with binding pry. See results in commend below
    sql = <<~SQL
      INSERT INTO users(email, password, full_name)
      VALUES($1, $2, $3)
    SQL

    query(sql, email, password, full_name)            # #<PG::Result:0x00007fba0d46aae0 status=PGRES_COMMAND_OK ntuples=0 nfields=0 cmd_tuples=1>
  end

  # ------- retrieves user password that correspond with given email address
  def get_password_by_email(email)                    # No bugs -> Tested with binding pry. See results in commend below
    sql = <<~SQL
      SELECT password
      FROM users
      WHERE email = $1
    SQL
        
    result = query(sql, email)                        # #<PG::Result:0x00007fba0cc91918 status=PGRES_TUPLES_OK ntuples=2 nfields=1 cmd_tuples=2>
    return nil if result.ntuples == 0     
    result.first["password"]                          # "$2a$12$W6A25Rf6jES5UNNvTKlEheDQ71.uYV4TLK.eDIaW.8MiNKxBnRHVi" || if only result.first returns {"password"=>"$2a$12$W6A25Rf6jES5UNNvTKlEheDQ71.uYV4TLK.eDIaW.8MiNKxBnRHVi"}
  end

  # -------- retrieves all fields in db users that correspond with an email --> at the moment not in use in peers.rb (using user_by_id instead)
  def get_user_data_by_email(email)                   # HAS A BUG - tuple returns nil; right now isn't in use, I'm using 'user_by_id' instead
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
        JOIN courses c ON u.course_id = c.id
        JOIN tracks t ON u.track_id = t.id
        JOIN timezones ti ON u.timezone_id = ti.id
      WHERE u.email = $1
    SQL

    result = query(sql, email)
    tuple = result.first                              # for some reason tuple is nil here
    # binding.pry                    
    tuple_to_user(tuple)
  end

  # ------ retrieves email and password based on given email (provided by user in form) --> not in use at the moment
  # def get_user_data(email)              
  #   sql = <<~SQL
  #     SELECT email, password
  #     FROM users
  #     WHERE email = $1
  #   SQL
        
  #   result = query(sql, email)

  #   return nil if result.ntuples == 0
  #   tuple = result.first 
  #   tuple_to_user(tuple)                # User entity with the info we have (the info we don't provide will be assigned to default values *see user.rb)
  # end


  # ------ updates user data; not in use for now but will be call in 'profile/edit' route
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

  # ------ updates user data; not in use for now but will be call in 'profile/edit' route
  def update_user_preferences(id, *preferences)
    sql = <<~SQL
    INSERT INTO users_preferences(user_id, preference_id)
      VALUES($1, unnest(ARRAY$2))                        -- unnest(ARRAY[1,2]) -> Expands an array into a set of rows. The array's elements are read out in storage order.
    SQL
    query(sql, id, preferences)
  end

  private

  # ----- converts the query return into a user entity --> original version created by Scott
  def tuple_to_user(tuple)
    slack_name = tuple["slack_name"]         # This line returns an error (following lines would too) -> undefined method `[]' for nil:NilClass
    full_name = tuple["full_name"]           # The error is because the PG::Result returns no tuples (tuple is nil), so there is no way to do tuple["something"]
    preferred_name = tuple["preferred_name"]
    about_me = tuple["about_me"]
    track = tuple["track"]
    course = tuple["course"]
    timezone = tuple["timezone"]

    User.new(
      slack_name,
      full_name,
      preferred_name,
      about_me,
      track,
      course,
      timezone
    )
  end

  # def tuple_to_user(tuple)          # backup copy, with all data from db user --> Created by Alonso based on Scott's version
  #   id = tuple["id"]
  #   email = tuple["email"]
  #   password = tuple["password"]
  #   full_name = tuple["full_name"]
  #   preferred_name = tuple["preferred_name"]
  #   slack_name = tuple["slack_name"]
  #   about_me = tuple["about_me"]
  #   course = tuple["course"]
  #   track = tuple["track"]
  #   timezone = tuple["timezone"]
    
  #   User.new(
  #     id,
  #     email,
  #     password,
  #     full_name,
  #     preferred_name,
  #     slack_name,
  #     about_me,
  #     course,
  #     track,
  #     timezone
  #   )
  # end
end
