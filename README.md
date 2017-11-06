# 1. Introduction
***
Dandified Yum (DNF) is the next upcoming major version of [Yum](http://yum.baseurl.org/). It does package management using [RPM](http://rpm.org/), [libsolv](https://github.com/openSUSE/libsolv) and [hawkey](https://github.com/rpm-software-management/hawkey) libraries. For metadata handling and package downloads it utilizes [librepo](https://github.com/tojaj/librepo). To process and effectively handle the comps data it uses [libcomps](https://github.com/midnightercz/libcomps).

Because after yocto2.3, rpm5 and smart are replaced by rpm4 and dnf, so the  package management tool(dnf) in yocto need to be developed, and it is called dnf-yocto.

# 2. Overview
***
In order to manage packages in yocto, the following functions need to be developed.
  1. dnf command line functions		
  2. dnf GUI functions

The dnf-yocto can be used both in host(a x86 PC with Linux) and target(a arm-soc board) environment.		

# 3. Usage of dnf-yocto
***
## 3.1 In host
### 3.1.1 Prepare the rpm repo
```
$ ls /home/zhengrq/workdir/dnf_test/oe_repo/
repodata  rpm
```

  * If you want to mange spdx or srpm, you should also create spdx or srpm repo.
```
$ ls /home/zhengrq/workdir/dnf_test/oe_repo/
repodata  rpm  spdx_repo  srpm_repo
```

### 3.1.2 Install and source toolchain
```
$ sh poky-glibc-x86_64-meta-toolchain-i586-toolchain-2.3.1.sh
$ . /opt/poky/2.3.1/environment-setup-i586-poky-linux
```
* After this operation, you can use dnf command in your host, but it is just a bare dnf, we need some set up to use it more convenient.

### 3.1.3 Initialize the environment
```
$ dnf-host init
The repo directory: (default:/home/zhengrq/workdir/dnf_test/oe_repo).
Is this ok?[y/N]:
y
repo directory: /home/zhengrq/workdir/dnf_test/oe_repo
The rootfs destination directory: (default: /home/zhengrq/workdir/dnf_test/rootfs).
Is this ok?[y/N]:
y
rootfs destination directory: /home/zhengrq/workdir/dnf_test/rootfs
The SPDX repo directory: (default: file:///home/zhengrq/workdir/dnf_test/oe_repo/spdx_repo).
Is this ok?[y/N]:
y
SPDX repo directory: file:///home/zhengrq/workdir/dnf_test/oe_repo/spdx_repo
The SPDX file destination directory: (default: /home/zhengrq/workdir/dnf_test/spdx_download).
Is this ok?[y/N]:
y
SPDX file destination directory: /home/zhengrq/workdir/dnf_test/spdx_download
The SRPM repo directory: (default: file:///home/zhengrq/workdir/dnf_test/oe_repo/srpm_repo).
Is this ok?[y/N]:
y
SRPM repo directory: file:///home/zhengrq/workdir/dnf_test/oe_repo/srpm_repo
The SRPM file destination directory: (default: /home/zhengrq/workdir/dnf_test/srpm_download).
Is this ok?[y/N]:
y
SRPM file destination directory: /home/zhengrq/workdir/dnf_test/srpm_download
```

### 3.1.4 Use dnf-host to do command
* In the new environment, you can use dnf-host instead of bare dnf command.
```
$ dnf-host info bash
Added oe-repo repo from file:///home/zhengrq/workdir/dnf_test/oe_repo
Last metadata expiration check: 21:29:17 ago on Mon Oct 16 17:17:07 2017 UTC.
Installed Packages
Name         : bash
Version      : 4.3.30
Release      : r0
Arch         : i586
Size         : 1.0 M
Source       : bash-4.3.30-r0.src.rpm
Repo         : @System
From repo    : oe-repo
Summary      : An sh-compatible command language interpreter
URL          : http://tiswww.case.edu/php/chet/bash/bashtop.html
License      : GPLv3+
Description  : An sh-compatible command language interpreter.

[zhengrq@localhost dnf_test]$ dnf-host install base-files
Added oe-repo repo from file:///home/zhengrq/workdir/dnf_test/oe_repo
Last metadata expiration check: 21:31:41 ago on Mon Oct 16 17:17:07 2017 UTC.
Dependencies resolved.
=======================================================================================
 Package                     Arch       Version                       Repository  Size
=======================================================================================
Installing:
 base-files                  qemux86    3.0.14-r89                    oe-repo     12 k
Installing dependencies:
 bash                        i586       4.3.30-r0                     oe-repo    482 k
 libc6                       i586       2.25-r0                       oe-repo    1.5 M
 libtinfo5                   i586       6.0+20161126-r0               oe-repo     67 k
 update-alternatives-opkg    i586       0.3.4+git0+1a708fd73d-r0      oe-repo    8.2 k

Transaction Summary
=======================================================================================
Install  5 Packages

Total size: 2.0 M
Installed size: 4.2 M
Is this ok [y/N]: y
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Installing  : update-alternatives-opkg-0.3.4+git0+1a708fd73d-r0.i586             1/5
  Installing  : libc6-2.25-r0.i586                                                 2/5
  Installing  : libtinfo5-6.0+20161126-r0.i586                                     3/5
  Installing  : bash-4.3.30-r0.i586                                                4/5
grep: /home/zhengrq/workdir/dnf_test/rootfs/etc/shells: No such file or directory
update-alternatives: Linking /home/zhengrq/workdir/dnf_test/rootfs/bin/bash to /bin/bash.bash
update-alternatives: Linking /home/zhengrq/workdir/dnf_test/rootfs/bin/sh to /bin/bash.bash
  Installing  : base-files-3.0.14-r89.qemux86                                      5/5
  Verifying   : base-files-3.0.14-r89.qemux86                                      1/5
  Verifying   : bash-4.3.30-r0.i586                                                2/5
  Verifying   : libc6-2.25-r0.i586                                                 3/5
  Verifying   : libtinfo5-6.0+20161126-r0.i586                                     4/5
  Verifying   : update-alternatives-opkg-0.3.4+git0+1a708fd73d-r0.i586             5/5

Installed:
  base-files.qemux86 3.0.14-r89
  bash.i586 4.3.30-r0
  libc6.i586 2.25-r0
  libtinfo5.i586 6.0+20161126-r0
  update-alternatives-opkg.i586 0.3.4+git0+1a708fd73d-r0

Complete!
```

### 3.1.5 Use new add command in dnf-yocto

(1) Modify the config file of dnf
```
[zhengrq@localhost dnf_test]$ cat rootfs/etc/dnf/dnf.conf
[main]
spdx_repodir=file:///home/zhengrq/workdir/dnf_test/oe_repo/spdx_repo
spdx_download=/home/zhengrq/workdir/dnf_test/spdx_download
srpm_repodir=file:///home/zhengrq/workdir/dnf_test/oe_repo/srpm_repo
srpm_download=/home/zhengrq/workdir/dnf_test/srpm_download
```
Note:
* spdx_repodir/srpm_repodir：the path of spdx/srpm repo
*　　 If the repo is local, start with file://
*     If the repo is remote, start with http://
* spdx_download/srpm_download：download path of spdx/srpm file

(2) Usage of --with-spdx and --with-srpm
```
[zhengrq@localhost dnf_test]$ dnf-host install --with-spdx bash
Added oe-repo repo from file:///home/zhengrq/workdir/dnf_test/oe_repo
Last metadata expiration check: 21:35:52 ago on Mon Oct 16 17:17:07 2017 UTC.
Dependencies resolved.
=======================================================================================
 Package                     Arch       Version                       Repository  Size
=======================================================================================
Installing:
 bash                        i586       4.3.30-r0                     oe-repo    482 k
Installing dependencies:
 base-files                  qemux86    3.0.14-r89                    oe-repo     12 k
 libc6                       i586       2.25-r0                       oe-repo    1.5 M
 libtinfo5                   i586       6.0+20161126-r0               oe-repo     67 k
 update-alternatives-opkg    i586       0.3.4+git0+1a708fd73d-r0      oe-repo    8.2 k

Transaction Summary
=======================================================================================
Install  5 Packages

Total size: 2.0 M
Installed size: 4.2 M
Is this ok [y/N]: y
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Installing  : update-alternatives-opkg-0.3.4+git0+1a708fd73d-r0.i586             1/5
  Installing  : base-files-3.0.14-r89.qemux86                                      2/5
  Installing  : libc6-2.25-r0.i586                                                 3/5
  Installing  : libtinfo5-6.0+20161126-r0.i586                                     4/5
  Installing  : bash-4.3.30-r0.i586                                                5/5
update-alternatives: Linking /home/zhengrq/workdir/dnf_test/rootfs/bin/bash to /bin/bash.bash
update-alternatives: Linking /home/zhengrq/workdir/dnf_test/rootfs/bin/sh to /bin/bash.bash
  Verifying   : bash-4.3.30-r0.i586                                                1/5
  Verifying   : base-files-3.0.14-r89.qemux86                                      2/5
  Verifying   : libc6-2.25-r0.i586                                                 3/5
  Verifying   : libtinfo5-6.0+20161126-r0.i586                                     4/5
  Verifying   : update-alternatives-opkg-0.3.4+git0+1a708fd73d-r0.i586             5/5

Installed:
  bash.i586 4.3.30-r0
  base-files.qemux86 3.0.14-r89
  libc6.i586 2.25-r0
  libtinfo5.i586 6.0+20161126-r0
  update-alternatives-opkg.i586 0.3.4+git0+1a708fd73d-r0

spdx file: base-files-3.0.14.spdx does not exist.....
bash-4.3.30.spdx copy is OK.
spdx file: glibc-2.25.spdx does not exist.....
spdx file: ncurses-6.0+20161126.spdx does not exist.....
spdx file: opkg-utils-0.3.4+git0+1a708fd73d.spdx does not exist.....
Complete!

[zhengrq@localhost dnf_test]$ ls spdx_download/
bash-4.3.30.spdx
```

* --with-srpm is the same as --with-spdx

(3) Usage of fetchspdx and fetchsrpm
```
[zhengrq@localhost dnf_test]$ dnf-host fetchspdx bash
Added oe-repo repo from file:///home/zhengrq/workdir/dnf_test/oe_repo
Last metadata expiration check: 21:37:13 ago on Mon Oct 16 17:17:07 2017 UTC.
bash-4.3.30.spdx copy is OK.
Dependencies resolved.
Nothing to do.
Complete!

[zhengrq@localhost dnf_test]$ ls spdx_download/
bash-4.3.30.spdx
```

* fetchsrpm is the same as fetchspdx

## 3.2 In target
### 3.2.1 Set up the repodata of yum
* First you need a http server with yum repo to access
```
[root@localhost target]# cat etc/yum.repos.d/Base.repo
[base]
name=myrepo
baseurl=http://192.168.65.144/oe_repo/
enabled=1
gpgcheck=0
```
* Here 192.168.65.144 is the ip of http server

### 3.2.2 Modify the config file of dnf
* Here is a example, the mean of each key is the say of host
```
[root@localhost target]# cat etc/dnf/dnf.conf
[main]
gpgcheck=1
installonly_limit=3
clean_requirements_on_remove=True
spdx_repodir=http://192.168.65.144/oe_repo/spdx_repo
spdx_download=/home/root/spdx_download
srpm_repodir=http://192.168.65.144/oe_repo/srpm_repo
srpm_download=/home/root/srpm_download
```
### 3.2.3 Usage of dnf in target
The usage of dnf in target is the same of in host, just use dnf instead of dnf-host, for example:
```
dnf-host list/dnf list
......
sed-locale-hu.i586                       4.2.2-r0         oe-repo      GPLv3+
sed-locale-id.i586                       4.2.2-r0         oe-repo      GPLv3+
sed-locale-it.i586                       4.2.2-r0         oe-repo      GPLv3+
sed-locale-ja.i586                       4.2.2-r0         oe-repo      GPLv3+
sed-locale-ko.i586                       4.2.2-r0         oe-repo      GPLv3+
sed-locale-nb.i586                       4.2.2-r0         oe-repo      GPLv3+
sed-locale-nl.i586                       4.2.2-r0         oe-repo      GPLv3+
sed-locale-pl.i586                       4.2.2-r0         oe-repo      GPLv3+
sed-locale-pt.i586                       4.2.2-r0         oe-repo      GPLv3+
sed-locale-pt-br.i586                    4.2.2-r0         oe-repo      GPLv3+
sed-locale-ro.i586                       4.2.2-r0         oe-repo      GPLv3+
sed-locale-ru.i586                       4.2.2-r0         oe-repo      GPLv3+
sed-locale-sk.i586                       4.2.2-r0         oe-repo      GPLv3+
sed-locale-sl.i586                       4.2.2-r0         oe-repo      GPLv3+
sed-locale-sr.i586                       4.2.2-r0         oe-repo      GPLv3+
sed-locale-sv.i586                       4.2.2-r0         oe-repo      GPLv3+
sed-locale-tr.i586                       4.2.2-r0         oe-repo      GPLv3+
sed-locale-uk.i586                       4.2.2-r0         oe-repo      GPLv3+
sed-locale-vi.i586                       4.2.2-r0         oe-repo      GPLv3+
sed-locale-zh-cn.i586                    4.2.2-r0         oe-repo      GPLv3+
sed-locale-zh-tw.i586                    4.2.2-r0         oe-repo      GPLv3+
sed-ptest.i586                           4.2.2-r0         oe-repo      GPLv3+
sln.i586                                 2.25-r0          oe-repo      GPLv2 & LGPLv2.1
sqlite3.i586                             3:3.17.0-r0      oe-repo      PD
sqlite3-dbg.i586                         3:3.17.0-r0      oe-repo      PD
tzcode.i586                              2.25-r0          oe-repo      GPLv2 & LGPLv2.1
```

# 4. Documentation
***
If you want to know more knowledge about dnf, read the documentation of dnf.
The DNF package distribution contains man pages, dnf(8) and dnf.conf(8). It is also possible to [read the DNF documentation](http://dnf.readthedocs.org/)online, the page includes API documentation. There's also a [wiki](https://github.com/rpm-software-management/dnf/wiki) meant for contributors to DNF and related projects.
