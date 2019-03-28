Cross Compiler Setup
===

The `setup_toolchain.bash` will download latest toolchains of ESS ICS Yocto Linux for IFC14xx and Concurrent CPU, and will install them into the following paths:

```
/opt/ifc14xx/2.6-4.14
/opt/cct/2.6-4.14/
```
, where `2.6-4.14` can be changed according to the latest Yocto and Kernel versions. 

In order to achieve them seamless, one needs the `SUDO` permission. Each path also has an unique file with the `SHA-` prefix, which tells us which hash id was used to create each toolchain.

Note that the `setup_toolchain.bash` will overwrite existent target paths. If one would like to evaluate them individually, please check the reference [1]. In this case, if one would like to use them with ESS EPICS Environment, one also should understand how the e3-base (ESS customized EPICS Base) can be configured. 


## Commands
```
cc_setup (master)$ bash setup_toolchain.bash
```


## Setup the CC Environment

In order to setup each environment, one should run one of them

```
$ . /opt/ifc14xx/2.6-4.14/environment-setup-ppc64e6500-fsl-linux
$ . /opt/cct/2.6-4.14/environment-setup-corei7-64-poky-linux
 ```


## References

[1] https://artifactory.esss.lu.se/artifactory/yocto/toolchain/
