# -*- mode: ruby; coding: utf-8 -*-
require 'sinatra'
require 'json'
require File.join(File.dirname(__FILE__), 'lib/converter')

class ConvertFreaks < Sinatra::Base
  configure do
    base64 = Converter.new("Base64",
                           ->(data, charset, nkf_flag) { Base64.encode64(data) },
                           ->(data, charset, nkf_flag) { Base64.decode64(data).force_encoding(charset) })

    mime = Converter.new("MIME",
                         ->(data, charset, nkf_flag) { NKF.nkf("-%sM" % nkf_flag, data) },
                         ->(data, charset, nkf_flag) { NKF.nkf("-%sw" % nkf_flag.upcase, data) })

    urlencode = Converter.new("URL encode",
                              ->(data, charset, nkf_flag) { CGI.escape(data) },
                              ->(data, charset, nkf_flag) { CGI.unescape(data) })

    quotedprintable = Converter.new("Quoted-Printable",
                                    ->(data, charset, nkf_flag) { NKF.nkf("-%sMQ" % nkf_flag, data) },
                                    ->(data, charset, nkf_flag) { NKF.nkf("-%swmQ" % nkf_flag.upcase, data) })

    uuencode = Converter.new("uuencode",
                             ->(data, charset, nkf_flag) { [data].pack('u') },
                             ->(data, charset, nkf_flag) { data.unpack('u').first.force_encoding(Encoding.default_external) })

    @@converters = [base64, mime, urlencode, quotedprintable, uuencode]
  end

  helpers do
    def convert(data, charset_sym)
      charset = CHARSET_MAP[charset_sym]
      data.safe_encode!(charset)
      nkf_flag = NKF_FLAG_MAP[charset_sym]
      result = {}

      @@converters.each { |cvt|
        key = cvt.label.gsub(/[^a-zA-Z0-9]/, '').downcase
        result[key] = {
          label: cvt.label,
          data: {
            encoded: cvt.encode(data, charset, nkf_flag),
            decoded: cvt.decode(data, charset, nkf_flag)
          }
        }
      }

      result
    end
  end

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

