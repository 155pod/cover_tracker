source "https://rubygems.org"

ruby "~> 3.1"

# Cover Tracker runs Rails 7 with Puma as an application server. SASS is
# compiled via `sass-rails`, and our JSON endpoints use `jbuilder`. Our database
# is SQLite 3 because we hate spending money on our hobbies. We're probably
# not locking to these verions for any particular reason.
#
gem "rails", "~> 7.0.4"
gem "sqlite3", "~> 1.4"
gem "puma", "~> 6.0"
gem "sass-rails", ">= 6"
gem "jbuilder", "~> 2.7"

# We use Devise to handle user authentication.
#
gem "devise"

# Bootsnap reduces boot times through caching. Required in config/boot.rb
#
gem "bootsnap", ">= 1.4.4", require: false

# FIXME:
# We transpile and compile JavaScript using `webpacker` right now. But in the
# future we'd like to use `esbuild` or stop needing to transpile and compile
# JavaScript entirely.
#
gem "webpacker", "6.0.0.rc.6"

# FIXME:
# We use ActionCable, so I feel like we should be using Redis in production.
# But it's been commented out in the Gemfile for ever. We should look into this
# sometime.
#
## gem "redis", "~> 4.0"

# We store user uploads in S3 in production. We manage files using
# ActiveStorage, and any transformations of attachment images may use
# `image_processing` (and `libvips` as a non-Ruby system dependency) to do that.
#
gem "aws-sdk-s3"
gem "image_processing"

# We soft-delete records using Discard.
#
gem "discard"

# Barnes reports performance stuff to StatsD.
#
gem "barnes"

group :development do
  # `rack-mini-profiler` display performance information such as SQL time and
  # flame graphs for each request in your browser.
  #
  gem "rack-mini-profiler", "~> 3.0"

  # `listen` tells you about modifications to files whenever they happen.
  #
  gem "listen", "~> 3.3"
end

group :test do
  # Capybara support for Capybara system testing and the Selenium driver.
  # `webdrivers` makes getting set up with browsers for automated testing very
  # easy.
  #
  gem "capybara", ">= 3.26"
  gem "selenium-webdriver"
  gem "webdrivers"
end
