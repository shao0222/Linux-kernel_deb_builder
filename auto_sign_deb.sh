#!/bin/bash

# 设置变量
PASSWORD="your_password" # gpg密钥的密码
KEYID="your_key_id" # gpg密钥的ID
DIR="your_directory" # deb包所在的目录

# 定义一个函数，用于清理临时文件
cleanup() {
  # 删除所有的.sig文件
  rm -f $DIR/*.sig
  # 删除所有的.deb.asc文件
  rm -f $DIR/*.deb.asc
}

# 定义一个函数，用于处理错误或中断
error() {
  # 输出错误信息
  echo "An error occurred. Cleaning up..."
  # 调用清理函数
  cleanup
  # 退出脚本
  exit 1
}

# 使用trap命令，捕获可能发生的错误或中断
trap error ERR INT TERM

# 遍历目录下的所有deb包，使用find命令
find $DIR -name "*.deb" -print0 | while read -d $'\0' file
do
  # 对deb包进行签名，使用dpkg-sig --sign命令
  # 使用--pinentry-mode loopback --batch --passphrase参数来免交互输入密码
  dpkg-sig --sign builder --gpg-options "--pinentry-mode loopback --batch --passphrase $PASSWORD --default-key $KEYID" $file
  # 检查签名是否成功，使用dpkg-sig --verify命令
  dpkg-sig --verify $file
  # 如果成功，输出文件名和签名信息
  if [ $? -eq 0 ]; then
    echo "Signed $file successfully."
    dpkg-sig --list $file
  # 如果失败，输出错误信息
  else
    echo "Failed to sign $file."
  fi
done

# 调用清理函数
cleanup

