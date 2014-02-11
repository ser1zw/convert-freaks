# -*- mode: ruby; coding: utf-8 -*-
require 'sinatra'
require 'json'
require './lib/converter'

get '/' do
  @charset_map = CHARSET_MAP
  erb :index
end

post '/api/convert' do
  charset = params[:charset].to_sym
  inputdata = params[:inputdata]
  convert(inputdata, charset).to_json
end

