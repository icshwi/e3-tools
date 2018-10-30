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

Therefore, MODULE version should be constant in the time domain amd BASE and REQUIRE versions should be changed within e3 module reposiotory according to the selected time along the time domain within a specific MODULE version. In other words, BASE and REQUIRE versions are functions of time respectively within each MODULE version, which can be represented as a limited parallel universe of a module. In order to fullfil this requirement, the MODULE version should be used as the e3 repository branch name. 


# Assumption

To run this script on the current "up-to-date" master branch is the strong assumption. If we forget to run it, that changes will be gone in the history in the master branch. In order to minimize this event, it would be better to do this within the continouse integration with each git commit automatically within each e3 module repository by travis-ci. 