source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.0'
# Use postgresql as the database for Active Record
gem 'pg'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.3'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer',  platforms: :ruby

gem 'sprockets'

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0',          group: :doc

# For front-end angular
gem 'angularjs-rails'

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
gem 'spring',        group: :development

# For CORS interaction with Angular
gem 'rack-cors', :require => 'rack/cors'

gem 'devise'
gem 'omniauth'
gem 'devise_token_auth'

group :development, :test do 
	gem 'rspec-rails' 
	gem 'factory_girl_rails' 
end

group :test do 
	gem 'faker' 
	gem 'capybara' 
	gem 'database_cleaner'
	gem 'launchy' 
	gem 'selenium-webdriver'
end

# For Application Server
gem 'foreman'
gem 'puma'
#gem 'rack-timeout',  '~> 0.2.4'

# For Heroku
gem 'rails_12factor', group: :production

ruby "2.2.1"