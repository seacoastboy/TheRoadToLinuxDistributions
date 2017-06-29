
## 深入理解RPM打包与仓库索引

### spec 文件的内容

spec 文件有几个部分。第一部分是未标记的；其它部分以 %prep 和 %build 这样的行开始。

### spec 文件摘要部分

定义了多种信息，其格式类似电子邮件消息头。

* Summary 是一行关于该软件包的描述。
* Name 是该软件包的基名， Version 是该软件的版本号。 Release 是 RPM 本身的版本号 ― 如果修复了 spec 文件中的一个错误并发布了该软件同一版本的新 RPM，就应该增加发行版号。
* License 应该给出一些许可术语（如：“GPL”、“Commercial”、“Shareware”）。
* Group 标识软件类型；那些试图帮助人们管理 RPM 的程序通常按照组列出 RPM。您可以在 /usr/share/doc/rpm-4.8.0/GROUPS 文件看到一个 Red Hat 使用的组列表
* Source0 、 Source1 等等给这些源文件命名（通常为 tar.gz 文件）。 %{name} 和 %{version} 是 RPM 宏，它们扩展成为头中定义的 rpm 名称和版本。不要在 Source 语句中包含任何路径。缺省情况下，RPM 会在 rpmbuild/SOURCES/ 中寻找文件。请将您的源文件复制到那里。
接下来的部分从 %description 行开始。您应该在这里提供该软件更多的描述，这样任何人使用 rpm -qi 查询您的软件包时都可以看到它。您可以解释这个软件包做什么，描述任何警告或附加的配置指令，等等。

### spec 文件中shell脚本

下面几部分是嵌入 spec 文件中的 shell 脚本。

* %prep 负责对软件包解包。在最常见情况下，您只要用 %setup 宏即可，它会做适当的事情，在构建目录下解包源 tar 文件。加上 -q 项只是为了减少输出。
* %build 应该编译软件包。该 shell 脚本从软件包的子目录下运行，在我们这个例子里是 indent-2.2.6 目录，因而这常常与运行 make 一样简单。
* %install 在构建系统上安装软件包。这似乎和 make install 一样简单，唯一的关键点是要把所有二进制文件安装到rpmbuild/BUILDROOT/目录。
* %files 列出应该捆绑到 RPM 中的文件，并能够可选地设置许可权和其它信息。
在 %files 中，
    * 可以使用 一次%defattr 来定义缺省的许可权、所有者和组；在这个示例中， %defattr(-,root,root) 会安装 root 用户拥有的所有文件，使用当 RPM 从构建系统捆绑它们时它们所具有的任何许可权。
    * 可以用 %attr(permissions,user,group) 覆盖个别文件的所有者和许可权。
    * 可以在 %files 中用一行包括多个文件。
     * 可以通过在行中添加 %doc 或 %config 来标记文件。 %doc 告诉 RPM 这是一个文档文件，因此如果用户安装软件包时使用 --excludedocs ，将不安装该文件。您也可以在 %doc 下不带路径列出文件名，RPM 会在构建目录下查找这些文件并在 RPM 文件中包括它们，并把它们安装到 /usr/share/doc/%{name}-%{version} 。以 %doc 的形式包括 README 和 ChangeLog 这样的文件是个好主意。
* %config 告诉 RPM 这是一个配置文件。在升级时，RPM 将会试图避免用 RPM 打包的缺省配置文件覆盖用户仔细修改过的配置。
警告：如果在 %files 下列出一个目录名，RPM 会包括该目录下的所有文件。通常这不是您想要的，特别对于 /bin 这样的目录
* %changelog 记录变更日志 

* 源配置文件

yum的软件仓库配置文件以.repo为扩展名，一个配置文件可以记录多个仓库，以 192.168.0.108机器RPM仓库local目录为例,将之前导出的公钥 RPM-GPG-KEY-CentOS-KS 放到 /etc/pki/rpm-gpg/目录中 编辑 /etc/yum.repos.d/ks.repo 文件，开启gpgcheck选项，指定
gpgkey，首次执行yum update 会自动提示导入.

```
[local]
name=local
baseurl=http://192.168.0.108/local/
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-KS

[local-update]
name=local-update
baseurl=http://192.168.0.108/local-update/
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-KS
```


## 高级话题



### 搭建koji系统

### RPM包签名

### 建GPG密钥/公钥

创建过程可参考文档<http://www.cryptnet.net/fdp/crypto/keysigning_party/en/keysigning_party.html>

* 列出系统中已有的密钥信息 `gpg --list-keys`
* 导出公钥,用于验证已签名的软件包或备份
`gpg --armor --output RPM-GPG-KEY-CentOS-KS --export [用户ID]`
* 导出私钥，留作做备份
`gpg --armor --output private-key.csr --export-secret-keys`

### RPM签名的准备工作

定义如下配置:

```
%_signature gpg
%_gpg_path /root/.gnupg                         #GPG密钥位置 
%_gpg_name HaiTao Pan &ltpanht@knownsec.com>    #证书UID
%_gpgbin /usr/bin/gpg
```

* 可以保存在全局配置文件/usr/lib/rpm/macros 
* 可以保存用户自定义配置文件 $HOME/.rpmmacros ,
* 或执行rpm,rpmbuild命令通过 -D, --define='MACRO EXPR' 选项定义配置

### 使用 rpmbuild 签名
引用配置文件中定义的配置签名

```
rpmbuild -ba --sign ~/rpmbuild/SPECS/package.spec 
或通过 -D 选项定义配置
rpmbuild -D '%_gpg_name HaiTao Pan &ltpanht@knownsec.com>' -D '%_gpg_path /root/.gnupg' -D '%_gpgbin /usr/bin/gpg' -D '%_signature gpg' -ba --sign ~/rpmbuild/SPECS/package.spec
```

签名过程中会提示输入私钥密码

### 使用 rpm 签名
```
rpm --addsign package.rpm
rpm --resign package.rpm
```

签名过程中会提示输入私钥密码

### 签名验证

```
rpm -K package.rpm
rpm -qpi package.rpm 
```



## 其他
结合 yum-utils软件包 repomanager 等工具可以辅助管理仓库内的rpm文件。

### 参考文档
* <http://docs.fedoraproject.org/en-US/Fedora_Draft_Documentation/0.1/html/RPM_Guide/ch11s04s02.html>
* <http://yum.baseurl.org/wiki/RepoCreate>
* <http://fedoraproject.org/wiki/Docs/Drafts/BuildingPackagesGuide>
* <http://fedoraproject.org/wiki/Packaging/Guidelines>
* <http://fedoraproject.org/wiki/ParagNemade/PackagingNotes>
* <http://www.rpm.org/max-rpm/>
