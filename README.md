# Wisper

Minimalistic library to help decouple business concernes using a Pub-Sub approach.  
Inspired by Ruby's excelent library [Wisper](https://github.com/krisleech/wisper).
- Subscriptions are just callbacks executed when the particular event is emitted
- Local and global subscriptions
- Synchronous and asynchronous subscriptions
- Logging

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     wisper:
       github: gmartsenkov/wisper
   ```

2. Run `shards install`

## Usage

To use Wisper simply include it in your class. Since crystal is strictly typed language we'll have to define the possible events that can be broadcasted using the `event` macro which just creates a simple class with the defined properties. 
```crystal
class User::Create
  include Wisper::Publisher

  event Success, name : String, age : Int32
  event Failure, reason : String
end
```
Once events are defined we can broadcast them using `#broadcast` -
```crystal
broadcast(Success.new("Jon", 20))
```
To subscribe to these events the `#on` can be used -
``` crystal
service = User::Create.new
service.on(User::Create::Success) do |success|
  puts success.name
end
```
Async subscriptions, which runs the block in a fiber - 
``` crystal
service = User::Create.new
service.on(User::Create::Success, async: true) do |success|
  puts success.name
end
```
Chaining `#on` is also possible -
``` crystal
User::Create.new
  .on(User::Create::Success) {|success| puts success.name }
  .on(User::Create::Failure) {|failure| puts failure.reason }
```
Sometimes it's usefull to define global subscriptions, for example every time when a new user is successfuly created we want to send out an email -
``` crystal
class Emails
  User::Create::GlobalListeners.listen(User::Create::Success, ->welcome_email(User::Create::Success))

  def self.welcome_email(success : User::Create::Success)
    # Send email logic
  end
```
Also can be run in asynchronously -
``` crystal
User::Create::GlobalListeners.listen(User::Create::Success, ->welcome_email(User::Create::Success, async: true))
```
NOTE: The local subscription callbacks are executed before the global ones.

Full example -
``` crystal
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

User::Create.new(age: 18)
  .on(User::Create::Success) { |success| puts success.name }
  .on(User::Create::Failure) { |failure| puts failure.reason }
  .call
```
## Global subscriptions
A global subscription is just a `Proc` that is executed when any event is broadcasted from any class or instance. This is usefull for logging, building usage statistics, etc...

Example of how the default wisper logger is implement using a global subscription
``` crystal
logger = ->(event : Wisper::EventTypes) do
  attributes = event.attributes
  message = "Published - #{event.class.name}"
  message += " - #{attributes}" unless attributes.empty?
  Log.for("Wisper").info { message }
end

Wisper.listen(logger)
```

## Temporary subscriptions
This is like a global subscription but is only active until the block executes.
The test helper `capture_events` uses a temporary subscription to capture and return broadcasted events
``` crystal
def capture_events(&block)
  events = Array(Wisper::EventTypes).new

  handler = ->(event : Wisper::EventTypes) do
    events << event
  end

  Wisper.listen(handler) do
    yield
  end

  events
end

puts capture_events { User::Create.new(age: 10).call }
# [#<User::Create::Failure:0x1022d9b20 @reason="Underaged">]
```

## Logging
We can use a global listener to log every broadcasted event. There is a default logger that can be used like this ->
``` crystal
require "wisper"
Wisper.listen(->Wisper.default_logger(Wisper::EventTypes))
```

## Testing
There is a helper method in `wisper/test` called `#capture_events` that takes a block and returns the broadcasted events in that block.
Example on testing with `Specter`
``` crystal
require "wisper/test"

it "calls the correct subscription" do
  service = User::Create.new(17)

  service.on(User::Create::Failure) do |failure|
    expect(failure.reason).to eq "teast"
  end

  events = capture_events { service.call }
  expect(events).to have User::Create::Failure
end
```
### Spectator
Handy spectator matchers to easily test an event has been broadcasted - https://github.com/gmartsenkov/wisper-spectator
``` crystal
require "wisper-spectator"

Spectator.describe "User::Create" do
  subject { User::Create.new(15) }

  describe "#broadcast" do
    it "works with a passed event class" do
      subject.on(User::Create::Failure) do |failure|
        expect(failure.reason).to eq "Some reason"
      end
      expect { subject.call }.to broadcast(User::Create::Failure)
    end
  end
end
```

## Contributing

1. Fork it (<https://github.com/gmartsenkov/wisper/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Georgi Martsenkov](https://github.com/gmartsenkov) - creator and maintainer
