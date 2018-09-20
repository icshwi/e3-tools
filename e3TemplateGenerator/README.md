E3 Module Template Builder
====


# Local Module Source
One would like to hold all source files and e3 module configuration files in e3-*

## Requirements

### Template Configuration file
One should define and understand the following variables first. It is important to understand what differences are

* ```EPICS_MODULE_NAME```  : used for the E3 module name, where one use it as its name
* ```E3_MODULE_SRC_PATH``` : shown as the source code directory name in EPICS_MODULE_URL
* ```E3_TARGET_URL```      : used for the E3 module repository 

For example,  we would like to have the e3 module for this in the following:
```
https://github.com/icshwi/e3-example
```

In this case, one should define the Module Configuration File as 

```
EPICS_MODULE_NAME:=example
E3_MODULE_SRC_PATH:=example
E3_TARGET_URL:=https://github.com/icshwi
```
Note that **-loc** will be added in the creating ```E3_MODULES_SRC_PATH```.

## Generate the e3 front-end module (Example)

For example,
```sh
$ bash e3TemplateGenerator.bash -m modules_conf/localexample.conf 
$ make -C e3-example rebuild
$ iocsh.bash e3-example/cmds/example.cmd 
 
```

Please look at the exampleApp, which is the carbon-copy from EPICS base (makeBaseApp).
```
exampleApp/
├── Db
│   dbExample1.db
│   dbExample2.db
│   dbSubExample.db
└── src
      1.1K]  dbSubExample.c
    ├── [jhlee     110]  dbSubExample.dbd
    ├── [jhlee     900]  myexampleHello.c
    ├── [jhlee      25]  myexampleHello.dbd
    ├── [jhlee      31]  sncExample.dbd
    └── [jhlee     455]  sncExample.stt
```

## Target Git Repository (E3_TARGET_URL)

One should create the empty respository, which has the e3-${EPICS_MODULE_NAME} name  in ${E3_TARGET_URL}.



# Remote Module Source
One would like to get source files from an external repository and hold e3 module configuration files in e3-*

## Requirements

### Template Confiugration File
One should define and understand the following variables first. It is important to understand what differences are

* ```EPICS_MODULE_NAME```  : used for the E3 module name, where one use it as its name
* ```E3_MODULE_SRC_PATH``` : shown as the source code directory name in EPICS_MODULE_URL
* ```E3_TARGET_URL```      : used for the E3 module repository 
* ```EPICS_MODULE_URL```   : shown as the module source repoistory URL

For example, one has the following EPICS source code :
```
https://github.com/epics-modules/mrfioc2
```
And we would like to have the e3 module for this in the following:
```
https://github.com/icshwi/e3-mrfioc2
```

In this case, one should define the Module Configuration File as 

```
EPICS_MODULE_NAME:=mrfioc2
E3_MODULE_SRC_PATH:=mrfioc2
E3_TARGET_URL:=https://github.com/icshwi
EPICS_MODULE_URL:=https://github.com/epics-modules
```

The second example, the EPICS source code : 
```
https://bitbucket.org/europeanspallationsource/m-epics-sis8300
```
And we would like to keep this in :
```
https://github.com/icshwi/e3-sis8300
```

In this case, one should define the Module Configuration File as 

```
EPICS_MODULE_NAME:=sis8300
E3_MODULE_SRC_PATH:=m-epics-sis8300
E3_TARGET_URL:=https://github.com/icshwi
EPICS_MODULE_URL:=https://bitbucket.org/europeanspallationsource
```

The thrid example, 
```
EPICS_MODULE_NAME:=ecmctraining
E3_MODULE_SRC_PATH:=ecmctraining
E3_TARGET_URL:=https://github.com/icshwi
EPICS_MODULE_URL:=https://bitbucket.org/europeanspallationsource
```

## Generate the e3 front-end module 

```sh
$ bash e3TemplateGenerator.bash -m modules_conf/ecmctraining.conf 

```


