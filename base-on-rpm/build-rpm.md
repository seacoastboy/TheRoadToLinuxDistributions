
##  制作RPM包

###  什么是RPM包

RPM包源自于Red Hat Linux 分发版，是Linux下常见的软件包格式之一，RPM包有两种包格式：

* 扩展名为 .rpm 封装完成的RPM二进制安装包 
* 扩展名为 .src.rpm 包含编译控制文件的SRPM源码包

### 准备工作环境

构建 RPM 软件包需要做如下准备工作：
* 一是系统中安装好 rpmbuild 打包工具, 执行命令：`yum install rpm-build -y`
* 二是编写一个扩展名为 .spec 文件，该文件指导 rpmbuild 命令如何构建和打包软件。这个文件可以任意地给它命名并把它放到任何地方，RPM对此没有限制。

### 修改上游源码包

本文作为基础篇，不深入讲解如何编写spec文件，我们可以通过获取上游SRPM包重新编译构建来体会rpm的过程。执行命令：`rpm -ivh http://mirrors.ustc.edu.cn/fedora/releases/22/Server/source/SRPMS/b/bc-1.06.95-13.fc22.src.rpm`

rpm会把srpm包解压到 ~/rpmbuild/ 目录，其中：

* spec文件 解压到   ~/rpmbuild/SPECS/ 目录中
* 补丁和源码解压到 ~/rpmbuild/SOURCES/ 目录中

重新编译源码包

`rpmbuild  -ba ~/rpmbuild/SPECS/bc.spec`

编译完成后，结果会存放在 ~/rpmbuild/SRPM/ ~/rpmbuild/RPM/ 目录中，在这里需要了解一下rpm的环境变量，查看rpm的环境变量 `rpm --showrc` ，其中 _topdir 定义了工作目录位置，默认是 $HOME/rpmbuild/，该目录下有五个目录：

* SPECS             放置 .spec 文件
* SOURCES        放置套件的源码及补丁等
* BUILD             用于存放解后压合并布补丁的源码目录
* BUILDROOT    用于存放封装生成的 RPM 安装包的文件 
* RPMS              放置二进制 RPM 安装包 (.rpm)
* SRPMS            放置源码格式的 RPM包 (.src.rpm) 

### rpmbuild 工作流程

下面总结了在您运行 rpm -ba filename.spec 时，RPM 都做些什么：

* 读取并解析 filename.spec 文件
* 运行 %prep 部分来将源代码解包一个临时目录 (~/rpmbuild/BUILD/XXXX)，并应用所有的补丁程序
* 运行 %build 部分来编译代码
* 运行 %install 部分将代码安装到一个临时目录（~/rpmbuild/BUILDROOT/XXXX）
* 读取 %files 部分的文件列表，收集文件并创建二进制和源 RPM 文件。
* 运行 %clean 部分清楚临时构建目录
