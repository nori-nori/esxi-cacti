#!/usr/bin/ruby
require 'rbvmomi'


# per 300 sec (300/20 = 15)
SamplingNum = 15


#
# main
#

exit 1 if ARGV.size < 1 


vim = RbVmomi::VIM.connect host: ARGV[0], user: 'root', password: 'Loto2169', insecure: true
if vim == nil 
  STDERR.puts "not connect #{ARGV[0]}"
  exit 1
end


metricsTable = {
  :default=>[
    "mem.usage",
    "mem.granted",
    "mem.active",
    "mem.shared",
    "mem.zero",
    "mem.unreserved",
    "mem.sharedcommon",
    "mem.heap",
    "mem.heapfree",
    "mem.overhead",
    "mem.reservedCapacity",
    "mem.consumed",
    "mem.sysUsage",
    "mem.activewrite",
    "mem.overheadMax",
    "mem.totalCapacity",
  ]
}
   
metrics = metricsTable[ARGV[1].to_s.to_sym] || metricsTable[:default]

host = vim.root.childEntity[0].hostFolder.childEntity[0].host
counter = vim.serviceContent.perfManager.retrieve_stats(host, metrics,
  :instance=>"",
  :max_samples=> SamplingNum
)
if counter == nil then
  STDERR.puts "error"
  exit 0
end

if ARGV[2] == nil
  counter[host[0]][:metrics].each do |k, v|
    printf("%s:%.2f \n", k, v.inject{|sum, i| sum + i}.to_f / SamplingNum.to_f)
  end
else
  # for debug
  pp counter[host[0]][:metrics].sort
end


exit 0
