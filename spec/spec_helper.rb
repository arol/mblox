require "mblox"
require "yaml"

CONFIG = YAML::load(File.open('config.yml'))

def set_configuration
  Mblox.configure do |config|
    config.outbound_url = CONFIG['outbound_url']
    config.profile_id = CONFIG['profile_id']
    config.sender_id = CONFIG['sender_id']
    config.password = CONFIG['password']
    config.partner_name = CONFIG['partner_name']
    config.tariff = CONFIG['tariff']
    config.service_id = CONFIG['service_id']
  end
end

set_configuration

TEST_NUMBER = CONFIG['test_number']

def the_message
  "Mblox gem test sent at #{Time.now}"
end

def result_ok
  "RequestResult: \"0:OK\" / SubscriberResult: \"0:OK\""
end

def result_unroutable
  "RequestResult: \"0:OK\" / SubscriberResult: \"10:MsipRejectCode=29 Number unroutable:2e Do not retry:2e\""
end

module Mblox
  class << self
    def reset_configuration
      @config = Configuration.new
    end
  end
end
