class User
  attr_reader :slackname, :firstname, :lastname, :about_me, :track, :course, :timezone

  def initialize(slackname, firstname, lastname, about_me, track, course, timezone)
    @slackname = slackname
    @firstname = firstname
    @lastname = lastname
    @about_me = about_me
    @track = track
    @course = course
    @timezone = timezone
  end
end
