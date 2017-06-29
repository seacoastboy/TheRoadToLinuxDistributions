
## 创建YUM仓库

yum主要用于自动安装、升级rpm软件包，它能自动查找并解决rpm包之间的依赖关系。使用yum就需要有添加一个包含各种rpm软件包的repository（软件仓库），这个软件仓库我们习惯称为yum源，下面我们就讲述如何创建自定义的软件仓库。
 
### 创建仓库

执行命令 `yum install createrepo -y`，安装一个名为createrepo的软件包，然后使用createrepo就可以完成yum仓库的创建，示例如下：`createrepo -g dvd-comps.xml -u Packages/ /repo`

* -g  dvd-comps.xml  指定分组配置文件
* -u Packages/           使用Packages/ 这个rpm包存放目录
*  /repo                      仓库根目录， 默认生成的索引文件存放在这个目录下

各个版本软件分组参考可以从这里获取 ：`git clone git://git.fedorahosted.org/git/comps.git`

### 更新仓库

在一个已创建好的yum仓库目录下，添加或删除rpm包后，使用 --update 参数就可以完成仓库的更新: `createrepo -g dvd-comps.xml -u Packages/ --update /repo`

### YUM仓库索引

在创建好的yum仓库目录下会创建repodata目录，里面存放XML格式或sqlite数据库的仓库索引文件，执行命令`yum update`，就是在同步yum源的索引，下面是repodata索引部分的概述：

```
repomd.xml                   描述的其他元数据文件的文件
primary.[xml/sqlite].[gz]    主要元数据信息文件，记录软件包报名,版本，预配置文件，依赖关系等
filelists.[xml/sqlite].[gz]  软件包文件，目录列表描述信息
other.[xml/sqlite].[gz]      目前只记录存储数据的变更记录
comps.xml.[gz]               用于记录软件包组分类等信息(需要创建仓库的时候指定分组文件)
```

更多细节可参考文档 <http://createrepo.baseurl.org/>

### 添加软件源

以上文提到的创建好的yum的软件仓库为例，添加一个软件源。创建配置文件：`/etc/yum.repos.d/local.repo`  
```
[local]
name=local
baseurl=file:///repo/
gpgcheck=0
```
重新执行命令`yum update`之后就可以使用这个软件仓库了。

### 软件源格式

yum仓库配置文件扩展名是 .repo, 配置文件存放目录：`/etc/yum.repos.d/`。一个 repo 文件可以添加多个repository配置，repo文件中的 repository 配置遵循如下格式：

```
[serverid]
name=Some name for this server
baseurl=url://path/to/repository/
其他可选配置
```

* serverid 是用于区分不同的 repository ，必须有一个独一无二的名称；
* name     定义 repository 的描述部分
* baseurl  定义 repository 的访问方式

### baseurl的格式

baseurl 指向是repository服务器设置中最重要的部分，一个repository 配置中只能有一个baseurl, 只有设置正确，yum才能从上面获取软件。它的格式是：

```
baseurl=url://server1/path/to/repository/
　　　  url://server2/path/to/repository/
　　　  url://server3/path/to/repository/
```

其中url 支持的协议有` http:// ftp:// file:// `三种。baseurl 后可以跟多个url。
