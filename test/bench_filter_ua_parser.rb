require_relative 'helper'
require 'fluent/plugin/filter_ua_parser'

# setup
Fluent::Test.setup
config = %[
  @type ua_parser
  key_name user_agent
  delete_key no
  flatten
  out_key ua
]
time = Time.now.to_i
tag = 'foo.bar'
driver = Fluent::Test::FilterTestDriver.new(Fluent::UaParserFilter, tag).configure(config, true)

# bench
require 'benchmark'
require 'csv'
n = 100000

ua_list = CSV.read('bench_ua_list.csv')
ua_list_len = ua_list.length

Benchmark.bm(7) do |x|
  x.report { driver.run { n.times { driver.emit({'user_agent' => ua_list[rand(ua_list_len)][0]}, time) } } }
end


# Without LRU cache
#              user     system      total        real
#        151.570000   0.780000 152.350000 (153.154123)
# With LRU cache(512)  & random 512 UA
#              user     system      total        real
#          3.720000   0.100000   3.820000 (  3.825439)
# With LRU cache(4096) & random 512 UA   <- using
#              user     system      total        real
#          3.830000   0.100000   3.930000 (  3.940422)

# fluent-plugin-woothee
# (https://github.com/woothee/fluent-plugin-woothee)
#              user     system      total        real
#          3.770000   0.050000   3.820000 (  3.850436)
