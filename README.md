# Tracia

Construct call stack in tree-style

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tracia'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install tracia

## Usage

Put `Tracia.add` in method call

```ruby
def do_something
  do_somthing_deep
end

def do_something_deep
  Tracia.add("I am working on something deep")
end
```

Wrap the call with `Tracia.start`

```ruby
Tracia.start do
  do_something()
end
```

### Custom Logger

By default, Tracia writes result to STDOUT, you can set it somewhere else

```ruby
file = File.new('/path/to/log.html', 'w+')

Tracia.start(logger: Tracia::DefaultLogger.new(out: file, html: true)) do
  # ...
end
```

Or you can make a logger class which responds to `call`

```ruby
class MyLogger
  def initialize(database)
    @database = database
  end

  # callback method for Tracia
  def call(root)
    # ...
    @database.insert(root)
  end
end
```

Then pass that logger to Tracia

```ruby
Tracia.start(logger: MyLogger.new(db_connection)) do
  # ..
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/tracia. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/tracia/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Tracia project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/tracia/blob/master/CODE_OF_CONDUCT.md).
