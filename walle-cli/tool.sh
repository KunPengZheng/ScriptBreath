#!/bin/sh
parent_dir=$(
  cd $(dirname $0)
  pwd
)

w2_path=$parent_dir"/w2.jar"
w1_path=$parent_dir"/walle-cli-all.jar"
ct_path=$parent_dir"/channel.txt"

showChannel() {
  read -p "请输入应用文件（.apk）的绝对路径：" apk_path
  java -jar "$w1_path" show "$apk_path"
  echo "执行成功!"
}

rename() {
  # 原始文件名的前缀和后缀
  prefix="app-release-"
  suffix=".apk"
  # 新文件名的前缀
  new_prefix=""

  if [ -z "$prefix" ]; then
    read -p "请输入.apk文件要去除的前缀：" prefix
  fi

  read -p "请输入需要批量修改前缀的文件的所在文件夹的绝对路经：" folder_path

  # 遍历当前脚本所在文件夹下的所有文件
  for file in "$folder_path"/*; do
    # 判断文件是否以指定前缀和后缀命名
    if [[ "$file" == *"$prefix"* && "$file" == *"$suffix"* ]]; then
      # 提取文件名中的编号
      num=$(echo "$file" | sed "s/${prefix}//" | sed "s/${suffix}//")
      # 生成新的文件名
      new_name="${new_prefix}${num}${suffix}"
      # 重命名文件
      mv "$file" "$new_name"
    fi
  done

  echo "Done!"
}

ch() {
  read -p "请输入母包（.apk文件）的绝对路经：" apk_path

  apk_file_name=$(basename "$apk_path" .apk)

  out_path=$parent_dir"/"$apk_file_name

  option_tip="请选择渠道来源："
  option1="1). channel.txt文件（所需的渠道提前写入此文件中，存在多个渠道则每个渠道各自占一行）"
  option2="2). 输入渠道（存在多个则用英文逗号分隔）"

  echo ""
  echo "$option_tip"
  echo "$option1"
  echo "$option2"
  echo ""
  read -r choice

  case $choice in
  "1")
    java -jar "$w2_path" batch -f "$ct_path" "$apk_path" "$out_path"
    echo "执行成功!输出文件为：" "\033]8;;file://$out_path\033\\$out_path\033]8;;\033\\"
    ;;
  "2")
    read -p "请输入渠道：" cs
    java -jar "$w2_path" batch -c "$cs" "$apk_path" "$out_path"
    echo "执行成功!输出文件为：" "\033]8;;file://$out_path\033\\$out_path\033]8;;\033\\"
    ;;
  *)
    echo "无此选项，请重新选择"
    ch
    ;;
  esac
}

opt() {
  option_tip="请选择以下选项："
  option1="1). 生成渠道包"
  option2="2). 显示渠道信息"
  option3="3). 重命名"

  echo ""
  echo "$option_tip"
  echo "$option1"
  echo "$option2"
  echo "$option3"
  echo ""

  read -r choice

  case $choice in
  "1")
    ch
    opt
    ;;
  "2")
    showChannel
    opt
    ;;
  "3")
    rename
    opt
    ;;
  *)
    echo "无此选项，请重新选择"
    opt
    ;;
  esac
}

if ! java -version >/dev/null 2>&1; then
  echo "java 未安装，请先安装java环境 "
  return
fi

echo "walle-cli 命令：https://github.com/Meituan-Dianping/walle/tree/master/walle-cli"

opt
