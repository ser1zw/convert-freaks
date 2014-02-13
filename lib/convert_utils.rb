# -*- mode: ruby; coding: utf-8 -*-
require 'base64'
require 'nkf'
require 'cgi/util'
require_relative 'converter'

module ConvertUtils
  def self.create_converters
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

    [base64, mime, urlencode, quotedprintable, uuencode]
  end

  def convert(data, charset_sym)
    charset = Converter::CHARSET_MAP[charset_sym]
    nkf_flag = Converter::NKF_FLAG_MAP[charset_sym]
    data.safe_encode!(charset)
    result = {}

    converters.each { |cvt|
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

  def converters
    []
  end
end

