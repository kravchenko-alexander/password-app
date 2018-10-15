require 'rails_helper'
require 'rspec_api_documentation'
require 'rspec_api_documentation/dsl'

RspecApiDocumentation.configure do |config|
  config.format = :json
  config.curl_host = 'http://localhost:8080/'
  config.api_name = 'API'
  config.request_headers_to_include = %w(Host Content-Type Access-Token Access-Token-Expired-At Refresh-Token Refresh-Token-Expired-At)
  config.response_headers_to_include = %w(Host Content-Type Access-Token Access-Token-Expired-At Refresh-Token Refresh-Token-Expired-At)
  config.curl_headers_to_filter = ['Authorization']
  config.keep_source_order = true
end
