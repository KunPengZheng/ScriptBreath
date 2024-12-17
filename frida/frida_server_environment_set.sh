#!/bin/bash

init() {
  echo "使用 frida 工具（其它命令参数请输入frida -h查看）："
  frida --version

  echo
  echo "使用 adb 命令来获取手机 CPU 处理器架构："
  adb shell getprop ro.product.cpu.abi

  echo
  # 注意 frida-server 需要和之前电脑安装版本一致才可以
  read -p "请输入 和手机CPU处理器架构相同 并且 和电脑端frida版本相同 的解压后的frida-server的绝对路径：" frida_path

  # 获取 APK 文件的文件名（不含路径和扩展名）
  frida_name=$(basename "$frida_path")

  # 将下载好的 so 库通过 adb 命令复制到手机 /data/local/tmp 目录上面
  adb push "$frida_path" /data/local/tmp

  # 运行adb shell并发送su命令
  adb shell <<EOF
  su
  cd /data/local/tmp
  chmod 777 "$frida_name"
EOF
}

no_init() {
  # 运行adb shell并发送su命令
  adb shell <<EOF
  su
  cd /data/local/tmp
  ./frida-server-16.2.1-android-arm64
EOF
}

opt() {
  echo ""
  echo "请选择以下选项："
  echo "1). 第一次安装frida"
  echo "2). 启动frida"
  echo ""

  read -r choice

  case $choice in
  "1")
    init
    opt
    ;;
  "2")
    no_init 0
    opt
    ;;
  *)
    echo "无此选项，请重新选择"
    opt
    ;;
  esac
}

init
