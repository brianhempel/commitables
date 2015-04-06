# A sample Guardfile
# More info at https://github.com/guard/guard#readme

## Uncomment and set this to only include directories you want to watch
# directories %w(app lib config test spec features)

## Uncomment to clear the screen before every task
# clearing :on

## Guard internally checks for changes in the Guardfile and exits.
## If you want Guard to automatically start up again, run guard in a
## shell loop, e.g.:
##
##  $ while bundle exec guard; do echo "Restarting Guard..."; done
##
## Note: if you are using the `directories` clause above and you are not
## watching the project directory ('.'), then you will want to move
## the Guardfile to a watched dir and symlink it back, e.g.
#
#  $ mkdir config
#  $ mv Guardfile config/
#  $ ln -s config/Guardfile .
#
# and, you'll have to watch "config/Guardfile" instead of "Guardfile"

guard :bundler do
  require 'guard/bundler'
  require 'guard/bundler/verify'
  helper = Guard::Bundler::Verify.new

  files = ['Gemfile']
  files += Dir['*.gemspec'] if files.any? { |f| helper.uses_gemspec?(f) }

  # Assume files are symlinked from somewhere
  files.each { |file| watch(helper.real_path(file)) }
end

# Note: The cmd option is now required due to the increasing number of ways
#       rspec may be run, below are examples of the most common uses.
#  * bundler: 'bundle exec rspec'
#  * bundler binstubs: 'bin/rspec'
#  * spring: 'bin/rspec' (This will use spring if running and you have
#                          installed the spring binstubs per the docs)
#  * zeus: 'zeus rspec' (requires the server to be started separately)
#  * 'just' rspec: 'rspec'

guard :rspec, cmd: "bundle exec rspec" do
  require "guard/rspec/dsl"
  dsl = Guard::RSpec::Dsl.new(self)

  # Feel free to open issues for suggestions and improvements

  # RSpec files
  rspec = dsl.rspec
  watch(rspec.spec_helper)   { rspec.spec_dir }
  watch(rspec.spec_support)  { rspec.spec_dir }
  watch("spec/factories.rb") { rspec.spec_dir }
  watch(rspec.spec_files)

  # Ruby files
  ruby = dsl.ruby
  dsl.watch_spec_files_for(ruby.lib_files)

  # Rails files
  rails = dsl.rails(view_extensions: %w(erb haml slim))
  dsl.watch_spec_files_for(rails.app_files)
  dsl.watch_spec_files_for(rails.views)

  watch(rails.views) do |m|
    thing = m[1][/\Aviews\/([^\/]+)/, 1]
    rspec.spec.("features/manage_#{thing}")
  end

  watch(/^app\/models\/.*/) do
    [
      "#{rspec.spec_dir}/integration/table_reckoning_spec.rb"
    ]
  end

  watch(rails.routes) do
    [
      "#{rspec.spec_dir}/routing",
      "#{rspec.spec_dir}/controllers",
      "#{rspec.spec_dir}/features"
    ]
  end

  watch(rails.controllers) do |m|
    [
      rspec.spec.("routing/#{m[1]}_routing"),
      rspec.spec.("controllers/#{m[1]}_controller"),
      rspec.spec.("features/manage_#{m[1]}")
    ]
  end

  # Rails config changes
  watch(rails.spec_helper)    { rspec.spec_dir }
  watch(rails.app_controller) { "#{rspec.spec_dir}/controllers" }

  # Capybara features specs
  watch(rails.view_dirs)     { |m| rspec.spec.("features/#{m[1]}") }
end
