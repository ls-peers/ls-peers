class User
  attr_reader :id, :email, :password, :full_name, :preferred_name, :slack_name, :track, :course, :timezone, :about_me

  def initialize(id, email, password='', full_name='', preferred_name = '', slack_name = '', track = '', course = '', timezone = '', about_me = '')
    @id = id
    @email = email
    @password = password
    @full_name = full_name
    @preferred_name = preferred_name
    @slack_name = slack_name
    @track = track
    @course = course
    @timezone = timezone
    @about_me = about_me
  end
end
