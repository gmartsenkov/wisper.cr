# wisper

TODO: Write a description here

## Usage

```crystal
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

User::Create.new(18).tap do |so|
  so.on(User::Create::Success) do |success|
    puts success.name
  end

  so.on(User::Create::Failure) do |failure|
    puts failure.reason
  end

  so.call
end
```

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     wisper:
       github: your-github-user/wisper
   ```

2. Run `shards install`

## Usage

```crystal
require "wisper"
```

TODO: Write usage instructions here

## Development

TODO: Write development instructions here

## Contributing

1. Fork it (<https://github.com/your-github-user/wisper/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Georgi Martsenkov](https://github.com/your-github-user) - creator and maintainer
