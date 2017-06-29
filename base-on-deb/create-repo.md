##  仓库管理

工具 reprepro 一个快速搭建deb软件仓库的工具。

### 安装 apt-get install reprepro -y

### 使用

创建配置文件，比如仓库目录在/var/www/repo  为例

<pre>
cd /var/www/repo/
cat > conf/distributions << "EOF"
Origin: deepin
Label:  jessie
Codename: jessie
Architectures: i386 amd64 source
Components: main
UDebComponents: main
Contents: .gz
Version: 2015.4.17
Description: local repo 2015.4.17
SignWith: 48FE4F60

Origin: deepin
Label:  jessie-updates
Codename: jessie-updates
Architectures: i386 amd64 source
Components: main
UDebComponents: main
Contents: .gz
Version: 2015.4.17
Description: local repo update 2015.4.17
SignWith: 48FE4F60

Origin: deepin
Label:  jessie-security
Codename: jessie-security
Architectures: i386 amd64 source
Components: main
UDebComponents: main
Contents: .gz
Version: 2015.4.17
Description: local repo update 2015.4.17
SignWith: 48FE4F60
EOF
</pre>

### 更新仓库

<pre>
reprepro includedeb wheezy pkgdir/*.deb
reprepro includeudeb wheezy pkgdir/*.udeb
reprepro includedsc wheezy pkgdir/*.dsc
</pre>

<pre>
SignWith: key_id  仓库签名
UDebComponents: main   Udeb包相关
</pre>

    /var/www/repo/
    conf/  
    db/..  
    dists/..  
    pool/..
