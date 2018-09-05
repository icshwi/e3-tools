E3 Module Template Builder
====

# Requirements

## Template Confiugration File
One should define and understand the following variables first. It is important to understand what differences are

* ```EPICS_MODULE_NAME```  : used for the E3 module name, where one use it as its name
* ```EPICS_MODULE_URL```   : shown as the module source repoistory URL
* ```E3_MODULE_SRC_PATH``` : shown as the source code directory name in EPICS_MODULE_URL
* ```E3_TARGET_URL```      : used for the E3 module repository 

# 
For example, one has the following EPICS source code :
```
https://github.com/jeonghanlee/snmp3
```
And we would like to keep e3 module in the following:
```
https://github.com/icshwi/e3-snmp3
```

In this case, one should define the Module Configuration File as 

```
EPICS_MODULE_NAME:=snmp3
EPICS_MODULE_URL:=https://github.com/jeonghanlee
E3_MODULE_SRC_PATH:=snmp3
E3_TARGET_URL:=https://github.com/icshwi
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
EPICS_MODULE_URL:=https://bitbucket.org/europeanspallationsource
E3_MODULE_SRC_PATH:=m-epics-sis8300
E3_TARGET_URL:=https://github.com/icshwi
```

## Target Git Repository (E3_TARGET_URL)

One should create the empty respository, which has the e3-${EPICS_MODULE_NAME} name  in ${E3_TARGET_URL}.


# Procedure 

## Step 0 : Create e3-${EPICS_MODULE_NAME} in ${E3_TARGET_URL}

## Step 1 : Create configuration file 

For example, modules_conf/ecmctraining.conf

```
E3_TARGET_URL:=https://github.com/icshwi
EPICS_MODULE_NAME:=ecmctraining
EPICS_MODULE_URL:=https://bitbucket.org/europeanspallationsource
E3_MODULE_SRC_PATH:=ecmctraining

```
## Step 2 : Run Generator


```sh

$ ./e3TemplateGenerator.bash -m modules_conf/ecmctraining.conf >> 
EPICS_MODULE_NAME  :                                                     ecmctraining
E3_MODULE_SRC_PATH :                                                     ecmctraining
EPICS_MODULE_URL   :                   https://bitbucket.org/europeanspallationsource
E3_TARGET_URL      :                                        https://github.com/icshwi
>> 
e3 module name     :                                                  e3-ecmctraining
e3 module url full :      https://bitbucket.org/europeanspallationsource/ecmctraining
e3 target url full :                        https://github.com/icshwi/e3-ecmctraining
>> 
Initialized empty Git repository in /home/jhlee/gitsrc/e3-tools/e3TemplateGenerator/e3-ecmctraining/.git/
https://bitbucket.org/europeanspallationsource/ecmctraining is adding as submodule...
Cloning into 'ecmctraining'...

X11 forwarding request failed on channel 0
remote: Counting objects: 7965, done.
remote: Compressing objects: 100% (2566/2566), done.
remote: Total 7965 (delta 6187), reused 7003 (delta 5354)
Receiving objects: 100% (7965/7965), 11.36 MiB | 2.45 MiB/s, done.
Resolving deltas: 100% (6187/6187), done.
Checking connectivity... done.
add ignore = all ... 


>>>> Do you want to add the URL https://github.com/icshwi/e3-ecmctraining for the remote repository?
     In that mean, you already create an empty repository at https://github.com/icshwi/e3-ecmctraining.

     If yes, the script will push the local e3-ecmctraining to the remote repository. (y/n)? n


>>>> Skipping add the remote repository url. 
     And skipping push the e3-ecmctraining to the remote also.

In case, one would like to push this e3 module to git repositories,
Please use the following commands within e3-ecmctraining/ :

   * git remote add origin https://github.com/icshwi/e3-ecmctraining
   * git commit -m "First commit"
   * git push -u origin master

The following files should be modified according to the module : 

   * /home/jhlee/gitsrc/e3-tools/e3TemplateGenerator/e3-ecmctraining/configure/CONFIG_MODULE
   * /home/jhlee/gitsrc/e3-tools/e3TemplateGenerator/e3-ecmctraining/configure/RELEASE

One can check the e3- template works via 
   cd /home/jhlee/gitsrc/e3-tools/e3TemplateGenerator/e3-ecmctraining
   make init
   make vars



```
