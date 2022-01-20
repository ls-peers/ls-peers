# class User   # Original version, created by Scott
#   attr_reader :id, :full_name, :slack_name, :preferred_name, :about_me, :track, :course, :timezone

#   def initialize(id, full_name, slack_name, preferred_name, about_me, track, course, timezone, **args)
#     @id = id
#     @slack_name = slack_name
#     @full_name = full_name
#     @preferred_name = preferred_name
#     @about_me = about_me
#     @track = track
#     @course = course
#     @timezone = timezone
#   end
# end

class User           # backup copy, update by Alonso from Scott's original
  attr_reader :id, :email, :password, :full_name, :preferred_name, :slack_name, :track, :course, :timezone, :about_me

  def initialize(id, email, password='', full_name='')
    @id = id
    @email = email
    @password = password
    @full_name = full_name
  end
end
