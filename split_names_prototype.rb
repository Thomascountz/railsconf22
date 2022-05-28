#! /usr/bin/env ruby

## Usage: 
# $ chmod +x ./split_names_prototype.rb
# $ ./split_names_prototype.rb

## Run Specs
# Remove breakpoint: (`binding.pry`)
# $ rspec ./split_names_prototype.rb

require "bundler/inline"

# Include required gems
gemfile do
  source "https://rubygems.org"
  gem "activerecord", require: "active_record"
  gem "sqlite3", require: true
  gem "faker", require: true
  gem "pry", require: true
  gem "pry-nav", require: true
  gem "rspec", require: true
end

# Ensure logs go to STDOUT
ActiveRecord::Base.logger = Logger.new($stdout)

# Use in-memory sqlite 
ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: ":memory:"
)

# Define a `users` table with only necessary columns from production
ActiveRecord::Schema.define do
  create_table :users do |t|
    t.string :first_name
    t.string :last_name
    t.timestamps
  end
end

# METHOD UNDER TEST!
class User < ActiveRecord::Base
  def split_names!
    return self if !last_name.nil?
    names = first_name.split(/\s+/)
    tap do |user|
      user.first_name = names[0]
      user.last_name = names[1]
    end
  end
end

# Create a "random" distribution of Users with a full name in the first_name column
# and first and last name in their respective columns; mimicking production data
users = Array.new(100) do
  name = Faker::Name.name
  [{first_name: name, last_name: nil}, {first_name: name[0], last_name: name[1]}].sample
end
User.insert_all(users)

# Test to be run by removing the binding below and invocking `$ rspec`
RSpec.describe User do
  describe "#split_names!" do
    it "splits the first_name into first_name and last_name" do
      first_name = "Thomas Countz"
      u = User.new(first_name: first_name)
      u.split_names!
      expect(u.first_name).to eq("Thomas")
      expect(u.last_name).to eq("Countz")
    end
  end
end

# Breakpoint to drop into this file with all of the context loaded
binding.pry
