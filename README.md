# CowAuth

The main goal of this gem is to provide session and / or API authentication for Rails (or Rails-like) web applications.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cow_auth'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cow_auth

## Model

### Generator (Example)

    $ bundle exec rails generate model user uuid:string:uniq email:string:uniq sid:string:uniq encrypted_password:string first_name:string last_name:string sign_in_count:integer is_approved:boolean is_deleted:boolean

### Migration (Example)

    # Modified migration; includes indexes and other stuff you might not want.
    class CreateUsers < ActiveRecord::Migration[5.1]
      def change
        create_table :users do |t|
          t.string :uuid, null: false
          t.string :email, null: false
          t.string :sid, null: false
          t.string :encrypted_password, null: false
          t.string :first_name
          t.string :last_name
          t.integer :sign_in_count, default: 0, null: false
          t.boolean :is_approved, default: false, null: false
          t.boolean :is_deleted, default: false, null: false
          t.timestamps
        end
        add_index :users, :uuid, unique: true
        add_index :users, :email, unique: true
        add_index :users, :sid, unique: true
      end
    end

### Model Inheritance

    class User < CowAuth::User
    end


### Create User

    User.create! email: 'email', password: 'password'

## Session Authentication

### Sign In View Example

    <%= form_tag '/sessions' do %>
      <%= label_tag(:email) %><br>
      <%= text_field_tag(:email) %><br>
      <%= label_tag(:password) %><br>
      <%= password_field_tag(:password) %><br>
      <%= submit_tag('Sign In') %>
    <% end %>

### Routes Example

    get 'sessions/new' => 'sessions#new'
    post 'sessions' => 'sessions#create'
    delete 'sessions' => 'sessions#destroy'

### Controllers

Add the following lines in the controller(s) that you want to enforce authentication for.

    include CowAuth::SessionAuth::AuthenticateRequest
    before_action :authenticate_user

### Application Controller Example

    class ApplicationController < ActionController::Base
      include CowAuth::SessionAuth::AuthenticateRequest

      protect_from_forgery with: :exception

      before_action :authenticate_user

      rescue_from CowAuth::NotAuthenticatedError, with: :user_not_authenticated

    private

      def user_not_authenticated(exception)
        flash[:notice] = exception.message
        render sessions_new_path
      end
    end

### Sessions Controller Example

    class SessionsController < ApplicationController
      include CowAuth::SessionAuth::SessionEndpoints

      skip_before_action :authenticate_user, only: [:new, :create]

      def sign_in_success_path
        flash[:notice] = 'Successfully signed in.'
        return home_path
      end

      def sign_out_success_path
        return sessions_new_path
      end
    end

## Token Authentication

### Authenticate (Example)

    curl -X POST -i --data-urlencode email=user@domain.tld --data-urlencode password=password https://api.domain.tld/v1/sessions

    curl -X DELETE -i https://api.domain.tld/v1/sessions -H "Authorization: Token token=b5503c9b85b881f8b3ddbd82f511912cb5503c9b85b881f8b3ddbd82f511912c,sid=C3281846f3976809796f91cf6bbb35c53"

### Authenticated Request

Note that token and sid are both required.

Example GET:

    curl -X GET -i https://api.domain.tld/v1/test -H "Authorization: Token token=b5503c9b85b881f8b3ddbd82f511912cb5503c9b85b881f8b3ddbd82f511912c,sid=C3281846f3976809796f91cf6bbb35c53"

### Controllers

Add the following lines in the controller(s) that you want to enforce authentication for.

    include CowAuth::TokenAuth::AuthenticateRequest
    before_action :authenticate_user

### Application Controller Example

    class ApplicationController < ActionController::API
      include CowAuth::TokenAuth::AuthenticateRequest

      before_action :authenticate_user

      rescue_from CowAuth::NotAuthenticatedError, with: :user_not_authenticated

    private

      def user_not_authenticated(exception)
        render json: { error: exception.message }, status: :unauthorized
      end
    end

### Sessions Controller Example

    class Api::V1::SessionsController < ApplicationController
      include CowAuth::TokenAuth::SessionEndpoints

      skip_before_action :authenticate_user, only: [:create]
    end

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

    bundle exec gem build cow_auth.gemspec
    bundle exec gem install cow_auth-0.1.0.gem

### Notes

    cow_auth> bundle exec gem build cow_auth.gemspec

    app> bundle

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mickey13/cow_auth. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
