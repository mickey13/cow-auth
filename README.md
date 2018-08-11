# CowAuth

The main goal of this gem is to provide token-based authentication for Rails (or Rails-like) web applications.

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

### Model

Configure your user model to add the authentication mechanism.

#### Generator (Example)

    $ bundle exec rails generate model user uuid:string:uniq email:string:uniq sid:string:uniq encrypted_password:string locale:string first_name:string last_name:string sign_in_count:integer is_enabled:boolean is_deleted:boolean

#### Migration (Example)

    # Modified migration; includes indexes and other stuff you might not want.
    class CreateUsers < ActiveRecord::Migration[5.2]
      def change
        create_table :users do |t|
          t.string :uuid, null: false
          t.string :email, null: false
          t.string :sid, null: false
          t.string :encrypted_password, null: false
          t.string :locale, null: false
          t.string :first_name
          t.string :last_name
          t.integer :sign_in_count, default: 0, null: false
          t.boolean :is_enabled, default: false, null: false
          t.boolean :is_deleted, default: false, null: false
          t.timestamps
          t.index [:uuid], unique: true
          t.index [:email], unique: true
          t.index [:sid], unique: true
        end
      end
    end

#### Model Concern

    class User < ApplicationRecord
      include CowAuth::User
    end

#### Create User

    User.create! email: 'user@domain.tld', password: 'password'

### Controllers

Configure the appropriate controllers to require authentication.

#### Controller Concern

Add the following lines in the controller(s) that you want to enforce authentication for.

    include CowAuth::TokenAuth::AuthenticateRequest
    before_action :authenticate_user

Add the following private method to the ApplicationController (assuming User is the model doing the authentication) to define the authentication class for the controller concern.

    def authentication_class
      return User
    end

#### Application Controller Example

    class ApplicationController < ActionController::API
      include CowAuth::TokenAuth::AuthenticateRequest

      before_action :authenticate_user

      rescue_from CowAuth::NotAuthenticatedError, with: :user_not_authenticated

    private

      def user_not_authenticated(exception)
        render json: { error: exception.message }, status: :unauthorized
      end

      def authentication_class
        return User
      end
    end

#### Sessions Controller HTML Example

The `sign_in_success_path` and `sign_out_success_path` methods need to be defined for redirecting after successful sign-in and sign-out.

    class SessionsController < ApplicationController
      include CowAuth::SessionAuth::SessionEndpoints

      skip_before_action :authenticate_user, only: [:new, :create]

    private

      def sign_in_success_path
        return root_url
      end

      def sign_out_success_path
        return sign_in_url
      end
    end

#### Sessions Controller JSON Example

The `sign_in_success_response_payload` method can optionally be overridden to customize the response payload for a successful sign-in.

    class Api::V1::SessionsController < ApplicationController
      include CowAuth::TokenAuth::SessionEndpoints

      skip_before_action :authenticate_user, only: [:create]

    protected

      def sign_in_success_response_payload
        return { uuid: @user.uuid, sid: @user.sid, auth_token: @user.auth_token }
      end
    end

### Token Authentication

#### Authenticate (Example)

    curl -X POST -i --data-urlencode email=user@domain.tld --data-urlencode password=password https://api.domain.tld/v1/sessions

    curl -X DELETE -i https://api.domain.tld/v1/sessions -H "Authorization: Token token=b5503c9b85b881f8b3ddbd82f511912cb5503c9b85b881f8b3ddbd82f511912c,sid=C3281846f3976809796f91cf6bbb35c53"

#### Authenticated Request

Note that "token" and "sid" are both required.

Example GET:

    curl -X GET -i https://api.domain.tld/v1/test -H "Authorization: Token token=b5503c9b85b881f8b3ddbd82f511912cb5503c9b85b881f8b3ddbd82f511912c,sid=C3281846f3976809796f91cf6bbb35c53"

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Notes

    cow_auth> bundle exec gem build cow_auth.gemspec
    cow_auth> bundle exec gem install cow_auth-0.1.0.gem
    app> bundle

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mickey13/cow_auth. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the CowAuth project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/mickey13/cow-auth/blob/master/CODE_OF_CONDUCT.md).
