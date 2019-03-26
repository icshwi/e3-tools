Cross Compiler Setup
===


Download latest toolchains (ifc14xx and cct) and install them in

```
/opt/ifc14xx/2.6-4.14
/opt/cct/2.6-4.14/
```
,where `2.6-4.14` can be changed according to the latest version. One needs `SUDO` permission. 



```
cc_setup (master)$ bash toolchain_setup.bash
```

In order to setup each environment, one should run one of them

```
$ . /opt/ifc14xx/2.6-4.14/environment-setup-ppc64e6500-fsl-linux
$ . /opt/cct/2.6-4.14/environment-setup-corei7-64-poky-linux
 ```