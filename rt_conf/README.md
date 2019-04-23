Linux RT PREEMPT Kernel Installation and Configuration
===

In the simple script, one can change a normal kernel to a Realtime PREEMPT kernel in Debian 9 and CentOS7.


# Packages

## Remove unnecessary packages
* postfix
* sendmail

## Install maybe necessary packages
* ethtool

# Install RT Kernel image and header files

## Debian 9
Use the default Debian repository

## CentOS 7
Use the CERN CentOS 7 rt repository [1] 


# Tuning the Kernel boot parameters

According to the Reference [2], we select the minimum boot parameters as follows:

* idle=pool (with the assumption that TSC is selected as the system clock source)
* intel_idle.max_cstate=0
* processor.max_cstate=1
* skew_tick=1

## Clock Source

* Check the current clock source
```
cat /sys/devices/system/clocksource/clocksource0/current_clocksource
```
* Check the available clock source
```
cat /sys/devices/system/clocksource/clocksource0/available_clocksource
```
* Select the tsc (Time Stamp Counter) [2] as the current clock
```
echo tsc > /sys/devices/system/clocksource/clocksource0/current_clocksource
```

# References

[1] http://linux.web.cern.ch/linux/centos7/  
[2] https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux_for_real_time/7/  
[3] https://en.wikipedia.org/wiki/Time_Stamp_Counter  
