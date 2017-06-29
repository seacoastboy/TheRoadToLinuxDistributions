# isobuilder

ISO 制作向导

## debian 系发行版安装盘

获取ISO仓库软件包列表，以debian9为例:


最小系统所需deb列表

```
debootstrap --print-debs --no-check-gpg --include=ssh,iptables,vim,linux-image-4.9.0-1-amd64,grub-pc,grub-efi --components=main,non-free,contrib --arch=amd64 stretch /tmp http://mirrors.ustc.edu.cn/debian > all_deb.list
```

安装盘所需udeb列表

```
wget http://10.1.10.21/server-dev/dsce-15-amd64/dists/kui/main/debian-installer/binary-amd64/Packages.gz
zcat Packages.gz | grep Filename | awk  '{print $2}' > all_udeb.list
```

通过`apt-get download 和 wget` 命令获取软件包列表,具体步骤略，创建本地仓库可阅读[参考文档](https://bj.git.sndu.cn/server-dev/engineering-docs-tools/blob/master/manuals/reprepro-howto.md)

## 创建工作目录:

```
git clone git@bj.git.sndu.cn:server-packages/isobuilder.git
cp -av isobuilder/iso-templet ~/iso-build/  # 拷贝一份模版目录副本
cd ~/iso-build/                             # 进入工作目录
cp -av pool dists .                         # 拷贝仓库好的本地仓库到工作目录
mkdir -pv install.amd/                      # 创建存放安装器的目录，存放`initrd.gz  vmlinuz`,
根据需要创建 preseed.cfg custom.postinstall 
find . -type f | grep -v -e ^\./\.disk -e ^\./dists | xargs md5sum >> md5sum.txt
```

安装器下载地址: http://10.1.10.72/installer/x86/V15.1/cdrom/gtk/

## 封装ISO

```
xorriso -as mkisofs -r -V 'Deepin Server V15'                                                             \
    -J -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin                                                      \
    -J -joliet-long                                                                                       \
    -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot                                           \
    -boot-load-size 4 -boot-info-table -eltorito-alt-boot                                                 \
    -e boot/grub/efi.img -no-emul-boot -isohybrid-gpt-basdat -isohybrid-apm-hfsplus  iso-build            \
    -o deepin-server-v15.iso
```
