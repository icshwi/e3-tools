E3 Module Template Builder
====


# Create NON existent E3 Modules with remote source files


One should define and understand the following variables first. It is important to understand what differences are

* ```EPICS_MODULE_NAME```  : used for the E3 module name, where one use it as its name
* ```E3_MODULE_SRC_PATH``` : shown as the source code directory name in EPICS_MODULE_URL
* ```EPICS_MODULE_URL```   : shown as the module source repoistory URL
* ```E3_TARGET_URL```      : used for the E3 module repository 

**Note that this name should be letters (upper and lower case) and digits.** The underscore character `_` is also permitted. Technically, this name is coverted into char variable within c program. Thus, it should follow the c programming variable rule. 

## Run a template generator
Usage    : ./e3TemplateGenerator.bash [-m <module_configuraton_file>] [-d <module_destination_path>]

               -m : a module configuration file, please check ../e3-tools/e3TemplateGenerator/modules_conf
               -d : a destination, optional, Default $PWD : ../e3-tools/e3TemplateGenerator 
               -u : an existent module path for updating configuration files
               -r : generate the RELEASE file with your EPICS env variables instead of the default values
### Option `-r` 
If the -r option is used, the RELEASE file will look like the following:
```
EPICS_BASE:=$(EPICS_BASE)
E3_REQUIRE_NAME:=$(E3_REQUIRE_NAME)
E3_REQUIRE_VERSION:=$(E3_REQUIRE_VERSION)
....
```

In this way the Makefile will fetch the above variables at compilation time from you EPICS environment (be sure to source it before), avoiding the needs to edit the file to change the default values if you need to change them. This can be useful if for instance you have multiple version of EPICS and you don't want to edit the RELEASE file everytime you compile your APPS with different version of EPICS. 

## siteMods

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
$ bash e3TemplateGenerator.bash -m modules_conf/mrfioc2.conf
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
$ bash e3TemplateGenerator.bash -m modules_conf/sis8300.conf 
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


