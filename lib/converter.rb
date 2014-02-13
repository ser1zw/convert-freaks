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

  def encode(data, charset, nkf_flag)
    convert_internal(data, @encode_func, charset, nkf_flag)
  end

  def decode(data, charset, nkf_flag)
    convert_internal(data, @decode_func, charset, nkf_flag)
  end

  private
  def convert_internal(data, func, charset, nkf_flag)
    converted = nil
    begin
      converted = func.call(data, charset, nkf_flag)
    rescue => e
      converted = 'FAILED TO CONVERT'
    end

    converted.safe_encode!(Encoding.default_external)
  end
end

