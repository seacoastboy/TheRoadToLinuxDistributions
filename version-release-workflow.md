# 关于工作流程

在深度工作快两年了，客观点讲，无论外界的声音如何，都不可否认，深度是民企中唯一一家优秀的专注做发行版的公司，虽然桌面是深度的亮点，但深度的服务器团队近几年刚刚起步。很多是事情是混乱的，特别是在工作流程上，那我就说说几句槽点：

* 某某领导说，能不能把自动化平台搭建起来，把研发人员解脱出来？
* 某某领导说，我们不能做出高质量的产品，是因为缺少自动化测试？
* 某某员工说，领导对项目时间节点有要求，没有时间梳理和调整流程？
* 某某员工说，能否后面基于构建平台来规范流程，现阶段暂时不做调整？

无论领导和员工，似乎都认为只要把所谓的自动化平台搭建起来，好像一切就都能解脱的感觉，好像之前的所有混乱，所有工程问题只差一个平台，有了平台就能万事具备。而实际情况是，基本每个队伍只有一个或两个研发的时候，领导既要求员工搭建所谓的自动化的平台，又要求保障项目任务完成的时间节点，于是就回到了上面的四个问题，在资源有限的前提下，这是一个死循环，要解决这类问题，我们应该跳出这个死循环，这里不是否定自动化平台的意义，好比同样的计算`1+1`，口算绝对比用计算机得出的结果快，平台是可管理的人员数量和事情复杂到一定的程度的量级的时候才需要考虑的事情，就像大型网站的架构从来是慢慢演化的一样，好多事情不是凭空产生的，这一切问题的核心本质在于能否建立合理的工作流程，有了合理的流程，无论是一个人还是多人，都可以保证工作合理向前推进，下面我们将就创建LINUX发行版本的工作流程！

# LINUX发行版的工作流程

所有发行版大体都遵循这个流程：源码版本控制-> 打包制作安装包 -> 归档入库 -> 制作安装介质 。。。 创建一个LINUX发行版，核心关注点个人理解就是三个，安装包，仓库，安装介质：
 
* 安装包：这项的关注点是如何从源码生成安装包，保证安装包间的依赖关系正确
* 仓库：这项的关注点是如何把安装包导入仓库，并保证仓库中索引和数据一致正确
* 安装介质：这项的关注点是从仓库同步获取最新的软件包，制作成可用可引导介质，比如安装光盘，安装U盘

## 其他细节与规范：

* 使用版本控制工具来管理源码，源码的修改提交一定要是使用版本控制工具，不要觉得使用版本控制工具是多余的步骤，使用版本控制可以方便的完成跟踪，评审，甚至回滚等操作； 
* 打包制作安装包，从源码制作安装包：
   * 一个细节就是尽量每次都能在一个干净的环境下构建
   * 另外一个细节就是软件包每次构建的修订号要保持保持持续增加，就算是代码回滚，修订号依然要保持+1,很多时候的混乱根源就是从打包开始；
* 归档入库 -> 制作安装介质，向仓库导入软件包，有个原则，就是仓库内的软件包原则上只能升级，不能覆盖仓库里同版本的软件包，不能随意降级软件包版本，在生成安装介质的时候，一定要清空本地构建环境，每次都从仓库获取最新软件包；


# 具体实例

以基于debian7，

* 仓库管理工具： reprepro
* deb打包工具： dpkg-dev
* 安装器： debian-installer
* 安装介质制作： shell脚本

## 创建规范

在学生时代，各种教材一直在强调，程序=算法+数据结构，在实际工作中，程序+工程管理才是软件开发的全部，没有良好的工程管理，有再好的算法，有再严谨的数据结构，也做不好软件，操作系统版本开发也一样，走好第一步路，就是创建合理的规范！

* 定义版本的生命周期：和软件开发，做应用项目一样，一个版本同样有它的生命周期，比如规划阶段，开发阶段，维护阶段，支持结束等一个完整的生命周期，某技术领导在带领开发一个操作系统版本的时候，无休止的添加新功能，在有限的人力下，依然保持，频繁的发布版本，最后大家都陷入了一种不知道要做成什么样子，不知道做到成么程度才能结束的状态，定义合理的版本生命周期，有始有终是重中之重！
* 定义基础工具链: （kernel，libc，gcc，binutils）这些个核心包是操作系统版本的基石，开发阶段主版本号一确定，只能修订，不可再变更，牵一发而动全身，一但升级某个基础工具链软件包，几乎将导致整个仓库需要全部重新构建，甚至会带来很多潜在的问题。
   * 以北京团队为例，曾经有一个产品是以debian8为上游，技术领导曾计划将内核从3.16升级到4.x版本，所幸没有升级，不然就是一场灾难，
   * 以上海团队为例，某个版本，内核版本从3.10升级到4.4，并且在开发仓库同时存在多个并行版本`4.4.32, 4.4.69, 4.4.71`，没有合理的规划，注定要步入混乱的后尘。 
* 定义软件包命名方式：

## 同步上游

* conf/distributions
```
Origin: orion
Label: Deepin Linux Server Main Repo
Codename: kui
Suite: stable
Architectures: mipsel mips64el source
Components: main non-free contrib
UDebComponents: main
Contents: udebs percomponent allcomponents
Description: Deepin Linux Server 
SignWith: Deepin Server kui Automatic Signing Key <packages@linuxdeepin.com> 
Log: orion.log
Update: upstream-main
```

* conf/updates

```
Name: upstream-main
Method: http://sh.deepin.io:6500/mips64el-deepin/ 
Suite: kui
Components: main contrib non-free
Architectures: mips64el source
GetInRelease: yes
FilterSrcList: install filterlist/debian-stretch-src
VerifyRelease: blindtrust
```

```
reprepro -V update
```



## 管理源码与打包

打包是维护发行版很重要的一个环节，很多开发人员能很好的的完成功能，却不能提交一个高质量的debian格式的源码包，以上海团队为例。提交的debian格式的内核源码包，重新构建时，存在如下两个问题，提交到Gitlab的 `linux-4.4.32` 的deb格式的源码包重新构建时，存在如下问题：

* 缺失编译依赖`firmware-amd-graphics`;
* 构建过程中存在如下错误：
```
firmware/radeon/RV710_pfp.bin.gen.S: Assembler messages:                                                                                           
firmware/radeon/RV710_pfp.bin.gen.S:5: 错误：file not found: /opt/deb-build/linux-4.4.32/firmware/radeon/RV710_pfp.bin                             
/opt/deb-build/linux-4.4.32/scripts/Makefile.build:294: recipe for target 'firmware/radeon/RV710_pfp.bin.gen.o' failed                             
make[6]: *** [firmware/radeon/RV710_pfp.bin.gen.o] Error 1                                                               
```

```
dh_strip: Compatibility levels before 9 are deprecated (level 7 in use)                                                                                                                                                                                      
Can't exec "-objcopy": 没有那个文件或目录 at /usr/share/perl5/Debian/Debhelper/Dh_Lib.pm line 255.                                                                                                                                                           
dh_strip: -objcopy --only-keep-debug --compress-debug-sections debian/linux-kbuild-4.4/usr/lib/linux-kbuild-4.4/scripts/conmakehash debian/.debhelper/linux-kbuild-4.4/dbgsym-root/usr/lib/debug/.build-id/45/158994612cd39a07da1080d6fa04966833bff9.debug fa
iled to to execute: No such file or directory  
```


不要幻想过度依赖的自动化平台来解决效率问题，基础工作没有做好，根本就无从谈起自动化，这种质量的软件包在自动构建流程是跑不通的，一个高质量的debian格式的源码包，最基本的要求是要满足编译依赖，运行依赖正确，可反复重新构建


### 参考实例：使用git托管的deb源码包

* 如何源码目录 debian/source/format 是3.0 (native)格式，那么这个工作就比较简单，连同代码和debian目录文件，全部提交到远端git仓库，每次克隆下来就是一套完整的deb源码包，直接构建就好。

* 如何源码目录 debian/source/format 是3.0 (quilt))格式，可以考虑使用git托管debian目录
```
apt-get source pkg_name                           # 从仓库获取源码
cd pkg_name/ && rm -rvf pkg_name/debian           # 删除陈旧的debian目录
cd pkg_name/ && git clone git_repo_url debian     # 从仓库获取最新最新的debian
编译构建 。。。
```

## 管理仓库

`reprepro` 可以用来方便的管理的deb包导入仓库，推荐的方式是使用reprepro工具操作.changes文件，完整的导入二进制和源码

示例如下：`reprepro inlude <codename> glibc_2.23_amd64.changes`

下面是一个结合inotifywait实现自动管理仓库的脚本，结合dput把构建好的软件包提交到仓库对应主机 /data/deepin-server/UploadQueue目录就能实现自动管理仓库

```
#!/bin/bash

inotifywait -me close_write --format '%w%f' /data/deepin-server/UploadQueue 2> /dev/null | while read line
do
    if [ "${line##*.}" = "changes" ];then
        DIST=`cat $line | grep Distribution | awk '{print $2}'` 
        cd repo_tools_dir && reprepro.sh include $DIST $line
    fi
done
```


## 制作安装介质

制作安装介质，要注意的就是每次构建都要确保清空当前残留环境，重新重仓库获取最新软件包，保持安装介质内的软件包版本同步更新！

```
rm -rvf   kui-15-build/db
rm -rvf   kui-15-build/dists
rm -rvf   kui-15-build/pool
rm -rvf   kui-15-build/md5sum.txt
rm -rvf   /tmp/roofs
rm -rvf   udeb/*
rm -vf    Packages*

version=`cat db/count` 
count=$[ $version + 1]
echo ${count} > db/count 
DateID=`date +%Y%m%d`
export BuildID=${DateID}-B${count}

debootstrap --no-check-gpg --include=locales,busybox,initramfs-tools,sudo,vim,psmisc,ssh,iptables,linux-image-4.9.0-2-amd64-unsigned,grub-pc,grub-efi --components=main,non-free,contrib --arch=amd64 kui /tmp/rootfs http://10.1.10.21/server-dev/dsce-15-amd64/
wget http://10.1.10.21/server-dev/dsce-15-amd64/dists/kui/main/debian-installer/binary-amd64/Packages.gz
zcat Packages.gz | grep Filename | awk  '{print $2}' > all_udeb.list
sed -i "s@^@http://10.1.10.21/server-dev/dsce-15-amd64/@g" all_udeb.list  
wget -i all_udeb.list -P udeb/

echo "Deepin Community Linux Server ${BuildID}" > kui-15-build/.disk/info

cd kui-15-build/
reprepro includedeb kui /tmp/rootfs/var/cache/apt/archives/*.deb
reprepro includeudeb kui ../udeb/*.udeb
rm -rvf /tmp/rootfs/var/cache/apt/archives/*.deb
mksquashfs /tmp/rootfs/kui-15-build/live/filesystem.suqashfs
find . -type f | grep -v -e ^\./\.disk -e ^\./dists | xargs md5sum >> md5sum.txt

cd ../
xorriso -as mkisofs -r -V 'Deepin Community Linux Server'                                                 \
    -J -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin                                                      \
    -J -joliet-long                                                                                       \
    -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot                                           \
    -boot-load-size 4 -boot-info-table -eltorito-alt-boot                                                 \
    -e boot/grub/efi.img -no-emul-boot -isohybrid-gpt-basdat -isohybrid-apm-hfsplus kui-15-build/         \
    -o deepin-community-server-minimal-amd64-${BuildID}.iso

```


