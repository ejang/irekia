source 'http://rubygems.org'

gem 'rails', '3.0.9'
gem 'sass', '~> 3.1.3'
gem 'pg', '0.11.0'
gem 'oa-oauth', '0.2.6', :require => "omniauth/oauth"
gem 'devise', '~> 1.4.2'
gem 'carrierwave', '~> 0.5.5'
gem 'mini_magick', '~> 3.3'
gem 'kaminari', '~> 0.12.4'
gem 'activerecord-postgis-adapter', '~> 0.3.5'
gem 'geocoder', '~> 1.0.2'
gem 'colored', '~> 1.2'
gem 'pg_search', :git => 'git://github.com/Casecommons/pg_search.git'

group :development do
  gem 'capistrano'
  gem 'capistrano-ext'
  gem 'compass'
end

group :development, :test do
  gem 'ruby-debug19', :platforms => :mri_19
  gem 'rspec-rails', '~> 2.6'
  gem 'capybara', '~> 1.0.1'
  gem 'launchy'
  gem 'irbtools', :require => 'irbtools/configure'
  gem 'railroady'
  gem 'escape_utils'
end

group :development, :test, :staging do
  gem 'delorean'
end
