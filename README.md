# wisper

Minimalistic library to help decouple business concernes using Pub-Sub style. 
- Subscriptions are just callbacks executed when the particular event is emitted
- Local and global subscriptions
- Synchronous and asynchronous subscriptions

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
  include Wisper

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
service.on(User::Create::Success) do
  puts success.name
end
```
Async subscriptions, which runs the block in a fiber - 
``` crystal
service = User::Create.new
service.on(User::Create::Success, async: true) do
  puts success.name
end
```
Chaining `#on` is also possible -
``` crystal
User::Create.new
  .on(User::Create::Success) {|success| puts success.name }
  .on(User::Create::Failure) {|failure| puts failure.reason }
```
Sometimes it's usefull to define global subscriptions, for example every time when a new user is successfuly created we want to send out an email
``` crystal
class Emails
  User::Create::GlobalListeners.listen(User::Create::Success, ->welcome_email(User::Create::Success))

  def self.welcome_email(success : User::Create::Success)
    # Send email logic
  end
```
Also can be run in asynchronously

``` crystal
User::Create::GlobalListeners.listen(User::Create::Success, ->welcome_email(User::Create::Success, async: true))
```

NOTE: The local listener callbacks are executed before the global ones.

Full example -
``` crystal
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

User::Create.new(age: 18)
  .on(User::Create::Success) { |success| puts success.name }
  .on(User::Create::Failure) { |failure| puts failure.reason }
  .call
```

## Contributing

1. Fork it (<https://github.com/your-github-user/wisper/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Georgi Martsenkov](https://github.com/gmartsenkov) - creator and maintainer
