# -*- mode: ruby; coding: utf-8 -*-

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

