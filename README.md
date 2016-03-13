# CowAuth

WARNING: This gem is in early development, which means you probably shouldn't use it yet for critical applications.

The main goal of this gem is to provide API authentication for Rails (or Rails-like) web applications.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cow_auth'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cow_auth

## Usage

TODO: Write usage instructions here

Example Rails model generator command:

    $ bundle exec rails generate model user email:string sid:string encrypted_password:string first_name:string last_name:string sign_in_count:integer

    # Modified migration; includes indexes.
    class CreateUsers < ActiveRecord::Migration[5.0]
      def change
        create_table :users do |t|
          t.string :email, null: false
          t.string :sid, null: false
          t.string :encrypted_password
          t.string :first_name
          t.string :last_name
          t.integer :sign_in_count
          t.timestamps
        end
        add_index :users, :email, unique: true
        add_index :users, :sid, unique: true
      end
    end

### Controllers

Add the following lines in the controller(s) that you want to enforce authenticatication for.

    include CowAuth::Authentication
    before_action :authenticate_user


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

    bundle exec gem build cow_auth.gemspec
    bundle exec gem install cow_auth-0.1.0.gem

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mickey13/cow_auth. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

