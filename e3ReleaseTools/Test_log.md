e3-StreamDevice

e3-StreamDevice (master)$ e3ModuleRelease.bash release
>>
  Now you are entering the release e3 module...
  You should aware what you are doing now ....
  If you are not sure, please stop this procedure immediately
>>
  We've found your working environment as follows:
  
  Working Branch      : master
  Working PATH        : /home/jhlee/playground/e3-StreamDevice

>> Do you want to continue (y/N)? y

Already on 'master'
Your branch is up-to-date with 'origin/master'.

E3 MODULE VERSION  :                        2.7.14p
EPICS BASE VERSION :                         3.15.5
E3 REQUIRE VERSION :                          3.0.0

MODULE BRANCH      :                        2.7.14p
MODULE TAG         : 3.15.5-3.0.0/2.7.14p-1810312211

Switched to a new branch '2.7.14p'
On branch 2.7.14p
nothing to commit, working tree clean
Total 0 (delta 0), reused 0 (delta 0)
remote: 
remote: Create a pull request for '2.7.14p' on GitHub by visiting:
remote:      https://github.com/jeonghanlee/e3-StreamDevice/pull/new/2.7.14p
remote: 
To https://github.com/jeonghanlee/e3-StreamDevice
 * [new branch]      2.7.14p -> 2.7.14p
Counting objects: 1, done.
Writing objects: 100% (1/1), 180 bytes | 0 bytes/s, done.
Total 1 (delta 0), reused 0 (delta 0)
To https://github.com/jeonghanlee/e3-StreamDevice
 * [new tag]         3.15.5-3.0.0/2.7.14p-1810312211 -> 3.15.5-3.0.0/2.7.14p-1810312211

 e3-StreamDevice (2.7.14p)$ git checkout master

 e3-StreamDevice (master)$ git branch
  2.7.14p
* master



jhlee@faiserver: e3-StreamDevice (master)$ e3ModuleRelease.bash -b 2.7.14p release
>>
  Now you are entering the release e3 module...
  You should aware what you are doing now ....
  If you are not sure, please stop this procedure immediately
>>
  We've found your working environment as follows:
  
  Working Branch      : 2.7.14p
  Working PATH        : /home/jhlee/playground/e3-StreamDevice

>> Do you want to continue (y/N)? y

Switched to branch '2.7.14p'

E3 MODULE VERSION  :                        2.7.14p
EPICS BASE VERSION :                         3.15.5
E3 REQUIRE VERSION :                          3.0.0

MODULE BRANCH      :                        2.7.14p
MODULE TAG         : 3.15.5-3.0.0/2.7.14p-1810312212

>>> 0 : 3.15.5-3.0.0/2.7.14p-1810312211 is existent 
>>>     in the branch 3.15.5-3.0.0/2.7.14p-1810312212 already.
>>> We end the request procedure here.




### Change Require 3.0.2 from 3.0.0 

 git add configure/RELEASE 
git commit -m "update RELEASE to use 3.0.2 require"
git push --set-upstream origin 2.7.14p


### Create tag in 2.7.14p
jhlee@faiserver: e3-StreamDevice (master)$ e3ModuleRelease.bash -b 2.7.14p release
>>
  Now you are entering the release e3 module...
  You should aware what you are doing now ....
  If you are not sure, please stop this procedure immediately
>>
  We've found your working environment as follows:
  
  Working Branch      : 2.7.14p
  Working PATH        : /home/jhlee/playground/e3-StreamDevice

>> Do you want to continue (y/N)? y

Switched to branch '2.7.14p'
Your branch is up-to-date with 'origin/2.7.14p'.

E3 MODULE VERSION  :                        2.7.14p
EPICS BASE VERSION :                         3.15.5
E3 REQUIRE VERSION :                          3.0.2

MODULE BRANCH      :                        2.7.14p
MODULE TAG         : 3.15.5-3.0.2/2.7.14p-1810312215

Counting objects: 1, done.
Writing objects: 100% (1/1), 181 bytes | 0 bytes/s, done.
Total 1 (delta 0), reused 0 (delta 0)
To https://github.com/jeonghanlee/e3-StreamDevice
 * [new tag]         3.15.5-3.0.2/2.7.14p-1810312215 -> 3.15.5-3.0.2/2.7.14p-1810312215


 e3-StreamDevice (2.7.14p)$ git tag
3.15.5-3.0.0/2.7.14p-1810312211
3.15.5-3.0.2/2.7.14p-1810312215
R0.2.0.0
R0.2.0.1



### Update BASE 7.0.1.1

jhlee@faiserver: e3-StreamDevice (2.7.14p)$ emacs configure/RELEASE
jhlee@faiserver: e3-StreamDevice (2.7.14p)$ git st
On branch 2.7.14p
Your branch is up-to-date with 'origin/2.7.14p'.
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

	modified:   configure/RELEASE

no changes added to commit (use "git add" and/or "git commit -a")
jhlee@faiserver: e3-StreamDevice (2.7.14p)$ git add configure/RELEASE 
jhlee@faiserver: e3-StreamDevice (2.7.14p)$ git st
On branch 2.7.14p
Your branch is up-to-date with 'origin/2.7.14p'.
Changes to be committed:
  (use "git reset HEAD <file>..." to unstage)

	modified:   configure/RELEASE

jhlee@faiserver: e3-StreamDevice (2.7.14p)$ git commit -m "up to base 7.0.1.1"
[2.7.14p b43ae19] up to base 7.0.1.1
 1 file changed, 1 insertion(+), 1 deletion(-)
jhlee@faiserver: e3-StreamDevice (2.7.14p)$ git push
Counting objects: 4, done.
Delta compression using up to 4 threads.
Compressing objects: 100% (4/4), done.
Writing objects: 100% (4/4), 397 bytes | 0 bytes/s, done.
Total 4 (delta 3), reused 0 (delta 0)
remote: Resolving deltas: 100% (3/3), completed with 3 local objects.
To https://github.com/jeonghanlee/e3-StreamDevice
   38703d3..b43ae19  2.7.14p -> 2.7.14p
jhlee@faiserver: e3-StreamDevice (2.7.14p)$ git checkout master
Switched to branch 'master'
Your branch is up-to-date with 'origin/master'.


e3-StreamDevice (master)$ e3ModuleRelease.bash -b 2.7.14p release
jhlee@faiserver: e3-StreamDevice (master)$ e3ModuleRelease.bash -b 2.7.14p release
>>
  Now you are entering the release e3 module...
  You should aware what you are doing now ....
  If you are not sure, please stop this procedure immediately
>>
  We've found your working environment as follows:
  
  Working Branch      : 2.7.14p
  Working PATH        : /home/jhlee/playground/e3-StreamDevice

>> Do you want to continue (y/N)? y

Switched to branch '2.7.14p'
Your branch is up-to-date with 'origin/2.7.14p'.

E3 MODULE VERSION  :                        2.7.14p
EPICS BASE VERSION :                        7.0.1.1
E3 REQUIRE VERSION :                          3.0.2

MODULE BRANCH      :                        2.7.14p
MODULE TAG         : 7.0.1.1-3.0.2/2.7.14p-1810312223

Counting objects: 1, done.
Writing objects: 100% (1/1), 183 bytes | 0 bytes/s, done.
Total 1 (delta 0), reused 0 (delta 0)
To https://github.com/jeonghanlee/e3-StreamDevice
 * [new tag]         7.0.1.1-3.0.2/2.7.14p-1810312223 -> 7.0.1.1-3.0.2/2.7.14p-1810312223





    33 : e3-tsclib
   34 : e3-ifcdaqdrv2
   35 : e3-nds3
   36 : e3-nds3epics
   37 : e3-ifc14edrv
   38 : e3-ifcfastint
   39 : e3-exprtk
   40 : e3-motor
   41 : e3-ecmc
   42 : e3-ethercatmc
   43 : e3-ecmctraining
   44 : e3-ADSupport
   45 : e3-ADCore
   46 : e3-ADSimDetector
   47 : e3-NDDriverStdArrays
   48 : e3-ADAndor
   49 : e3-ADAndor3
   50 : e3-ADPointGrey
   51 : e3-ADProsilica
   52 : e3-ADPluginEdge
   53 : e3-ADPluginCalib
   54 : e3-loki
   55 : e3-nds
   56 : e3-sis8300drv
   57 : e3-sis8300
   58 : e3-sis8300llrfdrv
   59 : e3-sis8300llrf
