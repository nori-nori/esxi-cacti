
# ESXi monitoring scripts for cacti

for *ESXi host* scripts.


# requirement
gem: rbvmoni



# usage
## environment variables 

ESX_USER=*user*

ESX_PASS=*password*

***

## scripts

- esx_diskInfo.rb

datastore information

ex.

    $ ruby esx_diskInfo.rb 192.168.206.51
     datastoreWriteIops@das130:3.07
     sizeNormalizedDatastoreLatency@das130:2570.20
     datastoreReadBytes@das130:238.93
     datastoreNormalWriteLatency@das130:4770.40
     write@das130:0.00
     totalReadLatency@das130:0.67
     ...

iops, latency, r/w bytes, etc ...

When write latency increasing, virtual machines freezing ...

***

- esx_resource.rb

cpu or memory usage

usage: ruby esx_resource.rb (cpu|mem)  target

ex.

    $ ruby esx_resource.rb cpu 192.168.0.1
    cpuUsage:1193000000 cpuTotal:38400000000 cpuUsageRate:3.00



***

-  esx_resourceSample.rb

sampling all metrics.
not for cacti.

ex.

    [[["cpu.coreUtilization", ""], [3376, 3454]],
     [["cpu.coreUtilization", "0"], [4389, 7129]],
     [["cpu.coreUtilization", "1"], [4389, 7129]],
     [["cpu.coreUtilization", "10"], [5420, 5323]],
     [["cpu.coreUtilization", "11"], [5420, 5323]],
     [["cpu.coreUtilization", "12"], [1365, 1772]],
    ...






