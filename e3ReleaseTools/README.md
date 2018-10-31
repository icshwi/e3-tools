e3 Module Release Rule
===

We will release each e3 module according to three version numbers. Let's call them the golden versions:

* BASE version 
* REQUIRE version
* MODULE version 

The master branch of each module repository should contain the latest changes in terms of these golden versions.


Each module version can be existent in each Base and each Require combinations such as
```
 base-3.15.5/require/3.0.0/siteMods/a_module/0.0.0/  T=t0
                                            /1.0.0/  T=t1
					   
                    /3.0.3/siteMods/a_module/1.0.0/  T=t2
                                            /1.8.4/  T=t3
					    
bash-7.0.1.1/require/3.0.3/siteMods/a_module/1.0.0   T=t4
                                            /1.8.4   T=t4
```
where T=tx shows the time when we install that version of a module.

Therefore, MODULE version should be constant in the time domain and BASE and REQUIRE versions should be changed within e3 module repository according to the selected time along the time domain within a specific MODULE version. In other words, BASE and REQUIRE versions are functions of time respectively within each MODULE version, which can be represented as a limited parallel universe of a module. In order to fulfill this requirement, the MODULE version should be used as the e3 repository branch name. 


# e3ModuleRelease.bash

This script helps us to *do* release with the following release tag format:

```
BASE_VERSION-REQUIRE_VERSION/MODULE_VERSION-YYMMDD-HHMM
```
For example, the following tag is created with Base 7.0.1.1, require 3.0.2, its module version is 2.7.14p when 2018-10-31, 22:23. Remember the script only get three golden version numbers, but the tag will have all changes in the e3 module repository.


```
7.0.1.1-3.0.2/2.7.14p-1810312223
```


```
$ e3ModuleRelease.bash

Usage : /home/jhlee/bin/e3ModuleRelease.bash [-b <branch_name>] release

            -b : default, master
```
There are two scenarios which we cover now.

## Release MODULE version branch within the up-to-date MASTER branch.

```
$ e3ModuleRelease.bash release
```
* If MODULE version doesn't exist, it will create the branch name with MODULE version, and create a tag to do release.
* If MODULE version does exist, it will end and will do nothing.


##  Release a tag within an existent MODULE version branch.
```
$ e3ModuleRelease.bash -b 2.7.14p release
```
* If the "released" tag is not found, it will create a tag for the new release
* If the "released" tag is found, it will end and will do nothing.




This script is only valid for the evolving Master branch. The main goal is to create the MODULE version branch if that branch doesn't exist at all.


# Assumption

To run this script on the current "up-to-date" master or existent (module version) branch is the if-and-if-only strong assumption. 