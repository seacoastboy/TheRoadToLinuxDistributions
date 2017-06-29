
## 打包辅助工具

实际开发过程中必须模拟用户的环境或是构建一个“干净”的环境（一个仅仅满足编译构建的最小系统环境）使用mock命令就达到在一个“干净”的环境重新编译构建。

* 安装软件包： `yum install mock -y`

### YUM仓库的配置
使用 mock 工具编译软件包，需要在yum仓库中建立了一个sysbuild分组，该分组包含了一个最小化系统所需的基础软件包。以下是 comps.xml 参考：
```
<?xml version='1.0' encoding='UTF-8'?>
<!DOCTYPE comps PUBLIC "-//CentOS//DTD Comps info//EN" "comps.dtd">
<comps>
  <group>
    <id>sysbuild</id>
    <name>mock build base group</name>
    <name xml:lang="zh_CN">自动编译基础系统</name>
    <name xml:lang="zh_TW">自动编译基础系统</name>
    <description>mock build base group</description>
    <description xml:lang="zh_CN">自动编译基础系统</description>
    <description xml:lang="zh_TW">自动编译基础系统</description>
    <default>false</default>
    <uservisible>true</uservisible>
    <packagelist>
        <packagereq type="default">bash</packagereq>
        <packagereq type="default">gawk</packagereq>
        <packagereq type="default">rpm</packagereq>
        <packagereq type="default">rpm-build</packagereq>
        <packagereq type="default">bzip2</packagereq>
        <packagereq type="default">gcc</packagereq>
        <packagereq type="default">sed</packagereq>
        <packagereq type="default">coreutils</packagereq>
        <packagereq type="default">git</packagereq>
        <packagereq type="default">deepin-release</packagereq>
        <packagereq type="default">tar</packagereq>
        <packagereq type="default">cpio</packagereq>
        <packagereq type="default">gnupg2</packagereq>
        <packagereq type="default">texinfo</packagereq>
        <packagereq type="default">curl</packagereq>
        <packagereq type="default">grep</packagereq>
        <packagereq type="default">unzip</packagereq>
        <packagereq type="default">diffutils</packagereq>
        <packagereq type="default">gzip</packagereq>
        <packagereq type="default">redhat-rpm-config</packagereq>
        <packagereq type="default">util-linux-ng</packagereq>
        <packagereq type="default">findutils</packagereq>
        <packagereq type="default">make</packagereq>
        <packagereq type="default">patch</packagereq>
        <packagereq type="default">which</packagereq>
    </packagelist>
  </group>
  <category>
    <id>sysbuild</id>
    <name>sysbuild</name>
    <description>mock mini require</description>
    <display_order>60</display_order>
    <grouplist>
      <groupid>sysbuild</groupid>
    </grouplist>
  </category>
</comps>
```


### mock工具的配置

根据需要修改默认配置 `/etc/mock/default.cfg`，配置文件中`config_opts['chroot_setup_cmd'] = 'install @sysbuild'` 分组名称`sysbuild`需要和仓库配置保持一致，参考配置如下：
```
config_opts['root'] = 'deepin-15-x86_64'
config_opts['target_arch'] = 'x86_64'
config_opts['legal_host_arches'] = ('x86_64',)
config_opts['chroot_setup_cmd'] = 'install @sysbuild'
config_opts['dist'] = 'deepin15'  # only useful for --resultdir variable subst
config_opts['yum.conf'] = """
[main]
keepcache=1
debuglevel=2
reposdir=/dev/null
logfile=/var/log/yum.log
retries=20
obsoletes=1
gpgcheck=0
assumeyes=1
syslog_ident=mock
syslog_device=
mdpolicy=group:primary
best=1

# repos
[deepin]
name=deepin server enterprise linux repo - amd64 
baseurl=http://10.1.10.21/server-dev/dsee-15-amd64/main/ 
enabled=1 
gpgcheck=0 
"""
``` 
### mock的基本使用

一切准备就绪，开始使用mock 重新编译一个软件包。

* mock --init
* mock --rebuild pkg.src.rpm

小技巧：使用mock编译辅助脚本，并行编译软件包

```bash
#！/bin/bash
pkg=$1

cat > /etc/mock/$1.cfg <<EOF
config_opts['dist'] = 'deepin15'
config_opts['root'] = '$pkg'
config_opts['target_arch'] = 'x86_64'
config_opts['legal_host_arches'] = ('x86_64',)
config_opts['chroot_setup_cmd'] = 'install @buildsys-build'
config_opts['yum.conf'] = """
[main]
keepcache=1
debuglevel=2
reposdir=/dev/null
logfile=/var/log/yum.log
retries=20
obsoletes=1
gpgcheck=0
assumeyes=1
syslog_ident=mock
syslog_device=
mdpolicy=group:primary
best=1

[deepin]
name=deepin server enterprise linux repo - amd64
baseurl=http://10.1.10.21/server-dev/dsee-15-amd64/main/
enabled=1
priority=1
gpgcheck=0
#gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-release

"""
EOF

mock -r $pkg --nocheck --cleanup-after --rebuild $pkg --resultdir=/data &>/tmp/$1.log &

```
