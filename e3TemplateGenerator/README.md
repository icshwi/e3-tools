E3 Module / Application Template Builder
====


# Create NON existent E3 Apps / Modules with remote source files


One should define and understand the following variables first. It is important to understand what differences are

* ```EPICS_MODULE_NAME```  : used for the E3 module name, where one use it as its name
* ```E3_MODULE_SRC_PATH``` : shown as the source code directory name in EPICS_MODULE_URL
* ```EPICS_MODULE_URL```   : shown as the module source repoistory URL
* ```E3_TARGET_URL```      : used for the E3 module repository 



## Site Apps / IOCs (siteApps)

### Genesys GEN 5kW Power Supply 

* genesysGEN5kWPS.conf
```
EPICS_MODULE_NAME:=genesysGEN5kWPS
E3_MODULE_SRC_PATH:=genesysGEN5kWPS
EPICS_MODULE_URL:=https://github.com/icshwi
E3_TARGET_URL:=https://github.com/icshwi

```
* generate the e3-genesysGEN5kWPS template 

```
$ bash e3TemplateGenerator.bash -m modules_conf/genesysGEN5kWPS.conf
```


## Site Modules (siteMods)

### mrfioc2

* mrfioc2.conf

```
EPICS_MODULE_NAME:=mrfioc2
E3_MODULE_SRC_PATH:=mrfioc2
EPICS_MODULE_URL:=https://github.com/epics-modules
E3_TARGET_URL:=https://github.com/icshwi
```
* generate the e3-mrfioc2 template 

```
$ bash e3TemplateGenerator.bash -m modules_conf/mrfioc2.conf -y
```


### sis8300

* sis8300.conf
```
EPICS_MODULE_NAME:=sis8300
E3_MODULE_SRC_PATH:=m-epics-sis8300
EPICS_MODULE_URL:=https://bitbucket.org/europeanspallationsource
E3_TARGET_URL:=https://github.com/icshwi
```

* generate the e3-sis8300 template 

```
$ bash e3TemplateGenerator.bash -m modules_conf/sis8300.conf -y
```

### ecmctraining

* ecmctraining.conf
```
EPICS_MODULE_NAME:=ecmctraining
E3_MODULE_SRC_PATH:=ecmctraining
EPICS_MODULE_URL:=https://bitbucket.org/europeanspallationsource
E3_TARGET_URL:=https://github.com/icshwi
```

* generate the e3-ecmctraining template 

```
$ bash e3TemplateGenerator.bash -m modules_conf/ecmctraining.conf -y
```


# Update existent E3 Apps / Modules

```
$ bash e3TemplateGenerator.bash -u e3-iocStats
```


# Create NON existent E3 Apps with local source files
Since we would like to keep all source files within e3 path, we don't need to define ```EPICS_MODULE_URL```

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

