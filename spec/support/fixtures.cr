require "../../src/wisper"

class User::Create
  include Wisper::Publisher

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
