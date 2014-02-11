# -*- mode: ruby; coding: utf-8 -*-
require 'sinatra'
require 'json'
require File.join(File.dirname(__FILE__), 'lib/converter')

class ConvertFreaks < Sinatra::Base
  get '/' do
    @charset_map = CHARSET_MAP
    erb :index
  end

  post '/api/convert' do
    charset = params[:charset].to_sym
    inputdata = params[:inputdata]
    convert(inputdata, charset).to_json
  end
end

