The e3ModuleRelease Practical Examples
===

## Prerequirement

Before running the e3ModuleRelease, there is no changes in master branch. Everything should be committed to the remote repository, before doing this work. 


## e3-base Release Example

After updating the configure/CONFIG_BASE and creating the patch files, and testing them with the existent modules, we have to release e3-base via `e3ModuleRelease`.

#### Go to e3-base, and check how TAG version will be
```
jhlee@proton: e3-base (master)$ pwd
/home/jhlee/e3-7.0.3/e3-base
jhlee@proton: e3-base (master)$ e3ModuleRelease 
>>
  We've found your working environment as follows:
  Working Branch      : master
  Working TARGET_SRC  : master
  Working PATH        : /home/jhlee/e3-7.0.3/e3-base
>>

X11 forwarding request failed on channel 0
Already on 'master'
Your branch is up to date with 'origin/master'.
>>
  We've found your working environment as follows:
  Working Branch      : master
  Working TARGET_SRC  : master
  Working PATH        : /home/jhlee/e3-7.0.3/e3-base
>>


E3 MODULE VERSION  :                                  7.0.3
EPICS BASE VERSION :                                  7.0.3
E3 REQUIRE VERSION :                                     NA

MODULE BRANCH      :                                  7.0.3
MODULE TAG         :      7.0.3-NA/7.0.3-0ec707c-1908061650


Usage : /home/jhlee/bin/e3ModuleRelease [-b <branch_name>] release

            -b : default, master
            -s : SHA-1 Hash
```

One case see potential release TAG version in `MODULE TAG`. 

#### Release it

```
jhlee@proton: e3-base (master)$ e3ModuleRelease release
>>
  We've found your working environment as follows:
  Working Branch      : master
  Working TARGET_SRC  : master
  Working PATH        : /home/jhlee/e3-7.0.3/e3-base
>>

X11 forwarding request failed on channel 0
Already on 'master'
Your branch is up to date with 'origin/master'.
>>
  We've found your working environment as follows:
  Working Branch      : master
  Working TARGET_SRC  : master
  Working PATH        : /home/jhlee/e3-7.0.3/e3-base
>>


E3 MODULE VERSION  :                                  7.0.3
EPICS BASE VERSION :                                  7.0.3
E3 REQUIRE VERSION :                                     NA

MODULE BRANCH      :                                  7.0.3
MODULE TAG         :      7.0.3-NA/7.0.3-0ec707c-1908061651

>>
  Now you are entering the release e3 module...
>>
  You should aware what you are doing now ....
  If you are not sure, please stop this procedure immediately!

>> Do you want to continue (y/N)? 
```

#### Select `y` if one want to continue

This step can detect whether potential branch is existent or not, if not, waits for your decision to create that branch in the local source path `e3-base`.

```
>>
  No Branch 7.0.3 is found, creating ....

>>
  You should aware what you are doing now ....
  If you are not sure, please stop this procedure immediately!

>> Do you want to continue (y/N)? 
```

#### Select `y` 
This step creates the new branch, and wait for your decision to push these changes to the remote repository.

```
>> Do you want to continue (y/N)? y

Switched to a new branch '7.0.3'
On branch 7.0.3
nothing to commit, working tree clean
>>
  Creating .... the tag 7.0.3-NA/7.0.3-0ec707c-1908061651
>>
  You can push these changes to the remote repository...
  Do you want to continue (y/N)? 
```

#### Select `y`

```
>>
  You can push these changes to the remote repository...
  Do you want to continue (y/N)? y
X11 forwarding request failed on channel 0
Total 0 (delta 0), reused 0 (delta 0)
remote: 
remote: Create a pull request for '7.0.3' on GitHub by visiting:
remote:      https://github.com/icshwi/e3-base/pull/new/7.0.3
remote: 
To github.com:icshwi/e3-base
 * [new branch]      7.0.3 -> 7.0.3
X11 forwarding request failed on channel 0
Enumerating objects: 1, done.
Counting objects: 100% (1/1), done.
Writing objects: 100% (1/1), 181 bytes | 181.00 KiB/s, done.
Total 1 (delta 0), reused 0 (delta 0)
To github.com:icshwi/e3-base
 * [new tag]         7.0.3-NA/7.0.3-0ec707c-1908061651 -> 7.0.3-NA/7.0.3-0ec707c-1908061651
>> 
Switched to branch 'master'
Your branch is up to date with 'origin/master'.

Already on 'master'
Your branch is up to date with 'origin/master'.
```

#### One can see the new and created branch now

```
jhlee@proton: e3-base (master)$ git branch -a
  7.0.3
* master
  remotes/origin/3.15.5
  remotes/origin/3.15.6
  remotes/origin/7.0.3
  remotes/origin/HEAD -> origin/master
  remotes/origin/devel/n_cc
  remotes/origin/master
```

#### Branch and Tag name rules

`e3-base` has its branch based on the EPICS BASE version, And its tag version has the following rule: `BASE_VERSION-NA/BASE_VERSION-E3_BASE_GIT_HASH-YYMMDDHHMM`.



## e3-require Release Example


#### Go to e3-require, and check how TAG version will be

```
jhlee@proton: e3-require (master)$ e3ModuleRelease 
>>
  We've found your working environment as follows:
  Working Branch      : master
  Working TARGET_SRC  : master
  Working PATH        : /home/jhlee/e3-7.0.3/e3-require
>>

X11 forwarding request failed on channel 0
M       tools/ess-env.conf
Already on 'master'
Your branch is up to date with 'origin/master'.
>>
  We've found your working environment as follows:
  Working Branch      : master
  Working TARGET_SRC  : master
  Working PATH        : /home/jhlee/e3-7.0.3/e3-require
>>

/home/jhlee/ics_gitsrc/e3-tools/e3ReleaseTools/.e3_module_release_functions: line 39: exit: ERROR : the master branch was changed, but we don't know how to resolve it: numeric argument required
```
The following file `tools/ess-env.conf` is changed when one install e3-require, so it is a normal behaviour. Please commit these changes to the remote repository and run it again. 

```
jhlee@proton: e3-require (master)$ git st
On branch master
Your branch is up to date with 'origin/master'.

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

        modified:   tools/ess-env.conf

no changes added to commit (use "git add" and/or "git commit -a")
jhlee@proton: e3-require (master)$ git add tools/ess-env.conf 
jhlee@proton: e3-require (master)$ git commit -m "update ess-env.conf"
[master 62a6fd6] update ess-env.conf
 1 file changed, 1 insertion(+), 1 deletion(-)
jhlee@proton: e3-require (master)$ git push
X11 forwarding request failed on channel 0
Enumerating objects: 7, done.
Counting objects: 100% (7/7), done.
Delta compression using up to 4 threads
Compressing objects: 100% (3/3), done.
Writing objects: 100% (4/4), 352 bytes | 352.00 KiB/s, done.
Total 4 (delta 2), reused 0 (delta 0)
remote: Resolving deltas: 100% (2/2), completed with 2 local objects.
To github.com:icshwi/e3-require
   86ae879..62a6fd6  master -> master
```

```
jhlee@proton: e3-require (master)$ e3ModuleRelease 
>>
  We've found your working environment as follows:
  Working Branch      : master
  Working TARGET_SRC  : master
  Working PATH        : /home/jhlee/e3-7.0.3/e3-require
>>

X11 forwarding request failed on channel 0
Already on 'master'
Your branch is up to date with 'origin/master'.
>>
  We've found your working environment as follows:
  Working Branch      : master
  Working TARGET_SRC  : master
  Working PATH        : /home/jhlee/e3-7.0.3/e3-require
>>


E3 MODULE VERSION  :                                  3.1.0
EPICS BASE VERSION :                                 3.15.6
E3 REQUIRE VERSION :                                  3.1.0

MODULE BRANCH      :                                  3.1.0
MODULE TAG         :  3.15.6-3.1.0/3.1.0-62a6fd6-1908061709


Usage : /home/jhlee/bin/e3ModuleRelease [-b <branch_name>] release

            -b : default, master
            -s : SHA-1 Hash

jhlee@proton: e3-require (master)$ 
```

As you see this, `e3-require` has the different EPICS BASE VERSION. So, we also have to change it in order to sync the EPICS BASE version in `e3-base`, because we would like not to use `*.local` file when we will build the production environment. Edit `configure/CONFIG_MODULE` to use 7.0.3 and commit these changes to the remote repository.

```
jhlee@proton: e3-require (master)$ git add configure/RELEASE 
jhlee@proton: e3-require (master)$ git commit -m "update BASE to match 7.0.3"
[master 69aed08] update BASE to match 7.0.3
 1 file changed, 1 insertion(+), 1 deletion(-)
jhlee@proton: e3-require (master)$ git push
X11 forwarding request failed on channel 0
Enumerating objects: 7, done.
Counting objects: 100% (7/7), done.
Delta compression using up to 4 threads
Compressing objects: 100% (4/4), done.
Writing objects: 100% (4/4), 370 bytes | 370.00 KiB/s, done.
Total 4 (delta 3), reused 0 (delta 0)
remote: Resolving deltas: 100% (3/3), completed with 3 local objects.
To github.com:icshwi/e3-require
   62a6fd6..69aed08  master -> master
```

Run `e3ModuleRelease` again to see how `MODULE TAG` is. 

```
jhlee@proton: e3-require (master)$ e3ModuleRelease 
>>
  We've found your working environment as follows:
  Working Branch      : master
  Working TARGET_SRC  : master
  Working PATH        : /home/jhlee/e3-7.0.3/e3-require
>>

X11 forwarding request failed on channel 0
Already on 'master'
Your branch is up to date with 'origin/master'.
>>
  We've found your working environment as follows:
  Working Branch      : master
  Working TARGET_SRC  : master
  Working PATH        : /home/jhlee/e3-7.0.3/e3-require
>>


E3 MODULE VERSION  :                                  3.1.0
EPICS BASE VERSION :                                  7.0.3
E3 REQUIRE VERSION :                                  3.1.0

MODULE BRANCH      :                                  3.1.0
MODULE TAG         :   7.0.3-3.1.0/3.1.0-69aed08-1908061713


Usage : /home/jhlee/bin/e3ModuleRelease [-b <branch_name>] release

            -b : default, master
            -s : SHA-1 Hash

jhlee@proton: e3-require (master)$ 
```


#### Release it

Will skip few steps which were described in `e3-base`. 

```
jhlee@proton: e3-require (master)$ e3ModuleRelease release
>>
  We've found your working environment as follows:
  Working Branch      : master
  Working TARGET_SRC  : master
  Working PATH        : /home/jhlee/e3-7.0.3/e3-require
>>

X11 forwarding request failed on channel 0
Already on 'master'
Your branch is up to date with 'origin/master'.
>>
  We've found your working environment as follows:
  Working Branch      : master
  Working TARGET_SRC  : master
  Working PATH        : /home/jhlee/e3-7.0.3/e3-require
>>


E3 MODULE VERSION  :                                  3.1.0
EPICS BASE VERSION :                                  7.0.3
E3 REQUIRE VERSION :                                  3.1.0

MODULE BRANCH      :                                  3.1.0
MODULE TAG         :   7.0.3-3.1.0/3.1.0-69aed08-1908061715

>>
  Now you are entering the release e3 module...
>>
  You should aware what you are doing now ....
  If you are not sure, please stop this procedure immediately!

>> Do you want to continue (y/N)? y

>>
  No Branch 3.1.0 is found, creating ....

>>
  You should aware what you are doing now ....
  If you are not sure, please stop this procedure immediately!

>> Do you want to continue (y/N)? y

Switched to a new branch '3.1.0'
On branch 3.1.0
nothing to commit, working tree clean
>>
  Creating .... the tag 7.0.3-3.1.0/3.1.0-69aed08-1908061715
>>
  You can push these changes to the remote repository...
  Do you want to continue (y/N)? y
X11 forwarding request failed on channel 0
Total 0 (delta 0), reused 0 (delta 0)
remote: 
remote: Create a pull request for '3.1.0' on GitHub by visiting:
remote:      https://github.com/icshwi/e3-require/pull/new/3.1.0
remote: 
To github.com:icshwi/e3-require
 * [new branch]      3.1.0 -> 3.1.0
X11 forwarding request failed on channel 0
Enumerating objects: 1, done.
Counting objects: 100% (1/1), done.
Writing objects: 100% (1/1), 183 bytes | 183.00 KiB/s, done.
Total 1 (delta 0), reused 0 (delta 0)
To github.com:icshwi/e3-require
 * [new tag]         7.0.3-3.1.0/3.1.0-69aed08-1908061715 -> 7.0.3-3.1.0/3.1.0-69aed08-1908061715
>> 
Switched to branch 'master'
Your branch is up to date with 'origin/master'.

Already on 'master'
Your branch is up to date with 'origin/master'.
```
