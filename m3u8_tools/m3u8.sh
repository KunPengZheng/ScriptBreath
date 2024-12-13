#!/bin/sh
folder_path=$(
  cd $(dirname $0)
  pwd
)
#echo "脚本当前路径:"$PARENT_DIR
mp4_path=$folder_path"/mp4"
m3u8_path=$folder_path"/m3u8"
# 用于写入到.m3u8中的加密信息文件
key_info_path=$folder_path"/key_info.txt"

# 判断文件如果不存在
if [ ! -d $key_info_path ]; then
  # 创建文件
  touch -f $key_info_path

  # 写入内容到指定文件中

  # 正常情况都是https地址，会被写入到.m3u8中
  echo "/vkey/enc.key" >>"$key_info_path"
  # 解密文件地址，一般都为本地文件的绝对路径，不会被写入.m3u8中
  echo "$folder_path/enc.key" >>"$key_info_path"
  # iv，会被写入到.m3u8中
  echo "f0b50540c59a49168d0ce0c9435e7103" >>"$key_info_path"
fi

for file in $(find "$mp4_path" -type f -name "*.mp4"); do
  name=${file%*.mp4}
  name=${name##*/}
  m3u8_file_path=$m3u8_path"/$name"
  echo $m3u8_file_path

  # 文件夹如果存在
  if [ -d $m3u8_file_path ]; then
    # 删除文件夹
    rm -f $m3u8_file_path
  fi
  # 创建文件夹
  mkdir -p $m3u8_file_path

  # 带加密信息的切片命令，切出来的.ts文件不可以直接播放，要解密合并成mp4
  ffmpeg -i "$file" -codec: copy -start_number 0 -hls_time 10 -hls_list_size 0 -hls_key_info_file $key_info_path -f hls "$m3u8_file_path/$name.m3u8"
  # 不带加密信息的切片命令，切出来的.ts可以直接播放
  #  ffmpeg -i "$file" -codec: copy -start_number 0 -hls_time 10 -hls_list_size 0 -f hls "$m3u8_file_path/$name.m3u8"

done
