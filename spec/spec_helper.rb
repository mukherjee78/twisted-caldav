require 'rspec'
require 'rubygems'
require 'webmock/rspec'
require 'twisted-caldav'

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  # some (optional) config here
end
