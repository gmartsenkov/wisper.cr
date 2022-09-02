require "./spec_helper"

Spectator.describe Wisper do
  describe "#on" do
    it "calls the correct subscription" do
      service = User::Create.new(17)

      service.on(User::Create::Failure) do |failure|
        expect(failure.reason).to eq "Underaged"
      end

      service.call
      expect(service.broadcasted).to have User::Create::Failure
    end

    it "works for another event" do
      service = User::Create.new(18)

      service.on(User::Create::Success) do |success|
        expect(success.age).to eq 18
        expect(success.name).to eq "Jon"
      end

      service.call
      expect(service.broadcasted).to have User::Create::Success
    end
  end

  describe "global listeners" do
    it "calls the global listener" do
      service = User::Create.new(18)
      called = 0

      User::Create::GlobalListeners.listen(
        User::Create::Success, ->(_user : User::Create::Success) {
        called = 1
      }
      )

      service.broadcast(User::Create::Failure.new(reason: "Some reason"))
      expect(service.broadcasted).to have User::Create::Failure
      expect(called).to eq 0

      service.broadcast(User::Create::Success.new("Jon", 18))
      expect(service.broadcasted).to have User::Create::Success
      expect(called).to eq 1
    end
  end
end
