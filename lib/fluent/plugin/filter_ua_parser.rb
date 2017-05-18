require 'fluent/plugin/filter'
require 'user_agent_parser'
require 'lru_redux'

module Fluent::Plugin
  class UaParserFilter < Fluent::Plugin::Filter
    Fluent::Plugin.register_filter('ua_parser', self)

    def initialize
      @ua_cache = LruRedux::Cache.new(4096)
      super
    end

    config_param :key_name, :string, default: 'user_agent'
    config_param :delete_key, :bool, default: false
    config_param :out_key, :string, default: 'ua'
    config_param :flatten, :bool, default: false
    config_param :patterns_path, :string, default: nil

    def configure(conf)
      super
      begin
        @parser = UserAgentParser::Parser.new(patterns_path: @patterns_path)
      rescue => e
        @parser = UserAgentParser::Parser.new
        log.warn "Failed to configure parser. Use default pattern.", error_class: e.class, error: e.message
        log.warn_backtrace
      end
    end

    def filter(tag, time, record)
      ua_string = record[@key_name]
      record.delete(@key_name) if @delete_key
      unless ua_string.nil?
        user_agent_detail = @ua_cache.getset(ua_string) { get_ua_detail(ua_string) }
        if flatten
          record.merge! hash_flatten(user_agent_detail, [@out_key])
        else
          record[@out_key] = user_agent_detail
        end
      end
      record
    end

    private

    def get_ua_detail(ua_string)
      ua = @parser.parse(ua_string)
      data = {"browser"=>{}, "os"=>{}, "device"=>""}
      return data if ua.nil?
      data['browser']['family'] = ua.family
      data['browser']['version'] = ua.version.to_s
      data['browser']['major_version'] = ua.version.major.to_i unless ua.version.nil?
      data['os']['family'] = ua.os.family
      data['os']['version'] = ua.os.version.to_s
      data['os']['major_version'] = ua.os.version.major.to_i unless ua.os.version.nil?
      data['device'] = ua.device.to_s
      data
    end

    def hash_flatten(a, keys=[])
      ret = {}
      a.each{|k,v|
        ks = keys + [k]
        if v.class == Hash
          ret.merge!(hash_flatten(v, ks))
        else
          ret.merge!({ks.join('_')=> v})
        end
      }
      ret
    end

  end
end
