class User
  attr_reader :id, :email, :password, :full_name, :preferred_name, :slack_name, :track, :course, :timezone, :about_me
  attr_accessor :preferences

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
    @preferences = []
  end

  def has_preference?(preference_id)
    @preferences.any? do |preference|
      preference["id"] == preference_id
    end
  end

  def is_complete?
    # (@email != nil && @preferred_name != nil && @slack_name != nil && @track != nil && @course != nil && @timezone != nil)
    !!(@email && @preferred_name && @slack_name && @track && @course && @timezone)
  end
end
