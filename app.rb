# -*- mode: ruby; coding: utf-8 -*-
require 'sinatra'
require 'json'
require File.join(File.dirname(__FILE__), 'lib/convert_utils')

class ConvertFreaks < Sinatra::Base
  helpers ConvertUtils
  helpers do
    def converters
      @@converters
    end
  end

  configure do
    @@converters = ConvertUtils.create_converters
  end

  get '/' do
    @charset_map = ConvertUtils::CHARSET_MAP
    erb :index
  end

  post '/api/convert' do
    charset = params[:charset].to_sym
    inputdata = params[:inputdata]
    convert(inputdata, charset).to_json
  end
end

