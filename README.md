e3-tools
===
# e3TemplateGenerator

The e3 module template generator. Please look at README file in the directory. 

# rt_conf

Linux RT PREEMPT Kernel configuration tool for CentOS 7 and Debian 9.

* For Debian 9, it has its own RT kernel images (main)
* For CentOS 7, it has its own RT kernel images [1]. However, it breaks CentOS package dependency from time to time, because of the slowness of the rt kernel. Here, CERN CentOS 7 rt repository will be used [2] 



# Reference 
[1] One should create CentOS-rt.repo in /etc/yum.repos.d/ as follows:

```
[rt]
name=CentOS-7 - rt
baseurl=http://mirror.centos.org/centos/\$releasever/rt/\$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
```

[2] http://linux.web.cern.ch/linux/centos7/