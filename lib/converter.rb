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


String.class_eval do
  def safe_encode!(charset)
    self.encode!(charset, invalid: :replace, undef: :replace, replace: '?')
  end
end

def convert_internal(data, func)
  converted = nil
  begin
    converted = func.call(data)
  rescue => e
    converted = 'FAILED TO CONVERT'
  end

  converted.safe_encode!(Encoding.default_external)
end

def convert(data, charset_sym)
  charset = CHARSET_MAP[charset_sym]
  data.safe_encode!(charset)
  nkf_flag = NKF_FLAG_MAP[charset_sym]
  result = {}

  # Base64
  result[:base64] = {
    label: "Base64",
    data: {
      encoded: convert_internal(data, ->(x) { Base64.encode64(x) }),
      decoded: convert_internal(data, ->(x) { Base64.decode64(x) })
    }
  }

  # MIME
  result[:mime] = {
    label: "MIME",
    data: {
      encoded: convert_internal(data, ->(x) { NKF.nkf("-%sM" % nkf_flag, data) }),
      decoded: convert_internal(data, ->(x) { NKF.nkf("-%sw" % nkf_flag.upcase, data) })
    }
  }

  # URL encode
  result[:url] = {
    label: "URL encode",
    data: {
      encoded: convert_internal(data, ->(x) { CGI.escape(data) }),
      decoded: convert_internal(data, ->(x) { CGI.unescape(data) })
    }
  }

  # Quoted-Printable
  result[:quotedprintable] = {
    label: "Quoted-Printable",
    data: {
      encoded: convert_internal(data, ->(x) { NKF.nkf("-%sMQ" % nkf_flag, data) }),
      decoded: convert_internal(data, ->(x) { NKF.nkf("-%swmQ" % nkf_flag.upcase, data) })
    }
  }

  # uuencode
  result[:uuencode] = {
    label: "uuencode",
    data: {
      encoded: convert_internal(data, ->(x) { [data].pack('u') }),
      decoded: convert_internal(data, ->(x) { data.unpack('u').first.force_encoding(Encoding.default_external) })
    }
  }

  result
end

