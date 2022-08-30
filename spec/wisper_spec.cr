require "./spec_helper"

class Test
  include Wisper

  event CreateUser
  event DeleteUser

  def call
    broadcast(CreateUser.new(1, 2))
  end
end

class Emails
  Test::GlobalListeners.listen(Test::CreateUser, ->welcome_email(Test::CreateUser))

  def self.welcome_email(e : Test::CreateUser)
    puts "Welcome email"
  end
end

x = Test.new
x.on(Test::CreateUser) do |user|
  puts user
end
x.call

describe Wisper do
  # TODO: Write tests

  it "works" do
    true.should eq(true)
  end
end
