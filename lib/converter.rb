# -*- mode: ruby; coding: utf-8 -*-
require 'base64'
require 'nkf'
require 'cgi/util'

CHARSET_MAP = {
  utf8: 'UTF-8',
  sjis: 'Shift_JIS',
  iso2022jp: 'ISO-2022-JP',
  eucjp: 'EUC-JP'
}

NKF_FLAG_MAP = {
  utf8: 'w',
  sjis: 's',
  iso2022jp: 'j',
  eucjp: 'e'
}

class Converter
  String.class_eval do
    def safe_encode!(charset)
      self.encode!(charset, invalid: :replace, undef: :replace, replace: '?')
    end
  end

  attr_reader :label

  def initialize(label, encode_func, decode_func)
    @label = label
    @encode_func = encode_func
    @decode_func = decode_func
  end

  def encode(data)
    convert_internal(data, @encode_func)
  end

  def decode(data)
    convert_internal(data, @decode_func)
  end

  private
  def convert_internal(data, func)
    converted = nil
    begin
      converted = func.call(data)
    rescue => e
      converted = 'FAILED TO CONVERT'
    end

    converted.safe_encode!(Encoding.default_external)
  end
end

def convert(data, charset_sym)
  charset = CHARSET_MAP[charset_sym]
  data.safe_encode!(charset)
  nkf_flag = NKF_FLAG_MAP[charset_sym]
  result = {}

  base64 = Converter.new("Base64",
                         ->(x) { Base64.encode64(x) },
                         ->(x) { Base64.decode64(x).force_encoding(charset) })

  mime = Converter.new("MIME",
                       ->(x) { NKF.nkf("-%sM" % nkf_flag, data) },
                       ->(x) { NKF.nkf("-%sw" % nkf_flag.upcase, data) })

  urlencode = Converter.new("URL encode",
                            ->(x) { CGI.escape(data) },
                            ->(x) { CGI.unescape(data) })

  quotedprintable = Converter.new("Quoted-Printable",
                                  ->(x) { NKF.nkf("-%sMQ" % nkf_flag, data) },
                                  ->(x) { NKF.nkf("-%swmQ" % nkf_flag.upcase, data) })

  uuencode = Converter.new("uuencode",
                           ->(x) { [data].pack('u') },
                           ->(x) { data.unpack('u').first.force_encoding(Encoding.default_external) })

  [base64, mime, urlencode, quotedprintable, uuencode].each { |cvt|
    key = cvt.label.gsub(/[^a-zA-Z0-9]/, '').downcase
    result[key] = {
      label: cvt.label,
      data: {
        encoded: cvt.encode(data),
        decoded: cvt.decode(data)
      }
    }
  }

  result
end

