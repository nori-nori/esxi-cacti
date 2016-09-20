#!/usr/bin/ruby
require 'rbvmomi'


def usage
  STDERR.puts <<_TXT_
usage: esx_resource.rb resource host
  resource: cpu | mem
  
_TXT_
end


def cpuResource summary
  cpuTotal = summary.hardware.cpuMhz * summary.hardware.numCpuThreads

  printf("cpuUsage:%d cpuTotal:%d cpuUsageRate:%3.2f",
    summary.quickStats.overallCpuUsage * 1000000,
    cpuTotal * 1000000,
    summary.quickStats.overallCpuUsage * 100 / cpuTotal
  )
end


def memResource summary
  printf("memUsage:%d memTotal:%d memUsageRate:%3.2f",
    summary.quickStats.overallMemoryUsage * 1024 * 1024 ,
    summary.hardware.memorySize,
    summary.quickStats.overallMemoryUsage * 100 * 1024 * 1024/ summary.hardware.memorySize
  )
end

def vmResource vim
  vms = vim
  
end

#
# main
#


if ARGV.size != 2
  usage
  exit 1
end


vim = RbVmomi::VIM.connect host: ARGV[1], user: ENV['ESX_USER'], password: ENV['ESX_PASS'], insecure: true
if vim == nil 
  STDERR.puts "not connect #{ARGV[0]}"
  exit 1
end


hostSummary = vim.root.childEntity[0].hostFolder.childEntity[0].host[0].summary

case ARGV[0]
  when 'cpu'
    cpuResource hostSummary
  when 'mem'
    memResource hostSummary
  when 'vm'
    vmResource vim
  else
    raise "command error"
end

vim.close
exit 0
