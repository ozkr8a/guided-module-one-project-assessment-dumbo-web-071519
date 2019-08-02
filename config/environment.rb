require 'bundler'
require 'rest-client'

Bundler.require

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: 'db/development.db')

ActiveRecord::Base.logger = nil

require_all 'lib'
require_all 'api'
require_relative "../bin/cli.rb"
