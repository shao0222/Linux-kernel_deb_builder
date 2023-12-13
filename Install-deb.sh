#!/bin/bash

# 定义 deb 包的后缀
suffix=".deb"

# 进入 artifact 目录
cd artifact

# 获取所有 deb 包的文件名，用空格分隔
DEBS=$(ls *.deb)

# 用 for 循环依次处理每个 deb 包
for DEB in $DEBS; do
  # 判断文件名是否以 .deb 结尾，如果不是，跳过
  if [[ "$DEB" != *"$suffix"  ]]; then
    echo "file type must be deb!"
    continue
  fi
  # 提示开始解压 deb 包
  echo "Extract $DEB from the archive"
  # 使用 ar 命令解压 deb 包，生成三个文件：debian-binary，control.tar.zst 和 data.tar.zst
  ar x $DEB
  # 提示开始转换压缩格式
  echo "Uncompress zstd $DEB and re-compress them using xz"
  # 使用 zstd 命令解压 control.tar.zst 文件，然后使用 xz 命令压缩它，生成 control.tar.xz 文件
  zstd -d < control.tar.zst | xz > control.tar.xz
  # 使用 zstd 命令解压 data.tar.zst 文件，然后使用 xz 命令压缩它，生成 data.tar.xz 文件
  zstd -d < data.tar.zst | xz > data.tar.xz
  # 提示开始重新打包 deb 包
  echo "Re-create the Debian package in /tmp/$DEB"
  # 使用 ar 命令重新打包 deb 包，将 debian-binary，control.tar.xz 和 data.tar.xz 三个文件合并为一个 deb 包，并保存在 /tmp 目录下，文件名与原来的 deb 包相同
  ar -m -c -a sdsd /tmp/$DEB debian-binary control.tar.xz data.tar.xz
  # 提示开始清理临时文件
  echo 'Clean up'
  # 使用 rm 命令删除解压和转换过程中生成的临时文件
  rm debian-binary control.tar.xz data.tar.xz control.tar.zst data.tar.zst
  # 提示开始执行 ~/installDeb.sh 脚本
  # echo "Execute ~/installDeb.sh $DEB"
  # 执行 ~/installDeb.sh 脚本，传入 deb 包的文件名作为参数
  #sudo ~/Install-deb.sh $DEB
done
