require "../../src/wisper"

class User::Create
  include Wisper

  event Success, name : String, age : Int32
  event Failure, reason : String

  def initialize(@age : Int32)
  end

  def call
    return failure if @age < 18

    broadcast(Success.new("Jon", @age))
  end

  private def failure
    broadcast(Failure.new(reason: "Underaged"))
  end
end

class Emails
  User::Create::GlobalListeners.listen(User::Create::Success, ->welcome_email(User::Create::Success))

  def self.welcome_email(e : User::Create::Success)
  end
end
