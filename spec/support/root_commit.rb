RSpec.configure do |config|
  # The root commit gets destroyed by the database cleaner, so we
  # need to make sure it is reloaded when necessary.
  config.before(:each) { Commit.instance_variable_set(:@root, nil) }
end
