#!/usr/bin/ruby
require 'rbvmomi'
require 'optparse'


debug = false
debug_soap = false
delim = ""
# per 300 sec (300/20 = 15)
sampling = 15


class DataStores
  def initialize dc
    @ds = dc.datastore
    @name = @ds.inject({}){|hash, d|
          hash[d.name] = d
          hash
    }
    @instance = @ds.inject({}){|hash, d|
          hash[File::basename(d.info.url)] = d
          hash
    }
  end

  def find_by_instance instance
    return  @instance.has_key?(instance) ? @instance[instance] : nil
  end


  def find_by_name name
    return  @name.has_key?(name) ?  @name[name] : nil
  end

  def list
    @ds.each do |d|
      puts d.name
    end
  end

end

def calc val, method = :default
  case method
    when :throughput
      return val.inject{|sum, i| sum + i}.to_f * 1024
    else
      return val.inject{|sum, i| sum + i}.to_f 
  end
end

metricsTable = {
  :default=>[
    "datastore.numberReadAveraged",                 # req per sec
    "datastore.numberWriteAveraged",
    "datastore.read",                               # kilo byte per sec
    "datastore.write",
    "datastore.totalReadLatency",                   # millisec
    "datastore.totalWriteLatency",
    "datastore.sizeNormalizedDatastoreLatency",     # microsec
    "datastore.datastoreIops",                      # I/O per sec
    "datastore.datastoreReadBytes",                 # byte (counter)
    "datastore.datastoreWriteBytes",
    "datastore.datastoreReadIops",
    "datastore.datastoreWriteIops",
    "datastore.datastoreNormalReadLatency",         # milli sec?
    "datastore.datastoreNormalWriteLatency",
    "datastore.datastoreReadOIO",
    "datastore.datastoreWriteOIO",
  ],
  :latency=>[
    "datastore.totalReadLatency",
    "datastore.totalWriteLatency",
    "datastore.datastoreNormalReadLatency",
    "datastore.datastoreNormalWriteLatency",
    "datastore.sizeNormalizedDatastoreLatency",
  ],
  :iops=>[
    "datastore.datastoreIops",
    "datastore.datastoreReadIops",
    "datastore.datastoreWriteIops",
  ],
  :throughput=>[
    "datastore.datastoreReadBytes",
    "datastore.datastoreWriteBytes",
    "datastore.read",
    "datastore.write",
  ],
  :list=>[
    "datastore.sizeNormalizedDatastoreLatency"
  ]
}


#
# main
#

opt = OptionParser.new
opt.on('-d') { debug = true; delim = "\n"}
opt.on('-s val'){|v| sampling = v.to_i}
#opt.on('-dd') { debug_soap = true}
opt.parse!


metrics = metricsTable[ARGV[1].to_s.to_sym] || metricsTable[:default]
option = {
  :max_samples => sampling,
  :multi_instance => true
}


vim = RbVmomi::VIM.connect host: ARGV[0], user: ENV['ESX_USER'], password: ENV['ESX_PASS'], insecure: true #, debug: true
if vim == nil 
  STDERR.puts "not connect #{ARGV[0]}"
  exit 1
end


dc =  vim.root.childEntity[0]
host = dc.hostFolder.childEntity[0].host

ds = DataStores.new(dc)

# datastore list up
if ARGV[1] == "list" then
  ds.list
  exit 0
end


if  ds.find_by_name(ARGV[2]) == nil
  option[:instance] = "*"
else
  option[:instance] = File::basename(ds.find_by_name(ARGV[2]).info.url)
end


counter = vim.serviceContent.perfManager.retrieve_stats(host, metrics, option)

if counter == nil or counter == {} then
  STDERR.puts "no data found"
  exit 0
end

# for debug
pp counter[host[0]][:metrics].sort if debug


counter[host[0]][:metrics].each do |k, v|
  if (option[:instance] == "*")
    printf("%s@%s:%.2f %s", k[0].split(".")[1], ds.find_by_instance(k[1]).name, calc(v, ARGV[1].to_s.to_sym)/ sampling.to_f, delim)
  else
    printf("%s:%.2f %s", k[0].split(".")[1], calc(v, ARGV[1].to_s.to_sym) / sampling.to_f, delim)
  end

end


exit 0
