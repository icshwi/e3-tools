Command Collection
==


## Get the tid of ecmc_rt

```
ps -eTo pid,tid,rtprio,cls,pri,cmd c | grep -v grep | sort -n
```

## Change the Scheduling Policy

```
chrt -f -p 80 10071
```
, where 80 is the `rtprio` and 10071 is `tid`, and `-f` is the `SCHED_FIFO`