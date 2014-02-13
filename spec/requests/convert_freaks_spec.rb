ENV['RACK_ENV'] = 'test'

require File.join(File.dirname(__FILE__), '..', '..', 'app.rb')
require 'sinatra'
require 'rack/test'
require 'rspec'

describe 'Convert Freaks Spec' do
  include Rack::Test::Methods

  def app
    ConvertFreaks
  end

  describe 'view page' do
    it 'should be OK' do
      get '/'
      expect(last_response).to be_ok
    end
  end
end

