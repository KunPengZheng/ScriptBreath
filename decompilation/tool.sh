#!/bin/sh
decompilation_apk() {
  # $1表示取传入的参数
  local bool=$1

  # bool局部参数是不是等于0
  if [ "$bool" -eq 0 ]; then
    read -p "请输入 .apk文件 的绝对路径：" ap
  elif [ "$bool" -eq 1 ]; then
    read -p "文件不存在，请重新输入：" ap
  else
    echo "decompilation_apk()未知case"
  fi

  # 获取文件名，包括后缀
  local fn=$(basename "$ap")
  # 获取文件的后缀
  local fe="${fn##*.}"

  # -z表示是否为空字符串 -e表示文件是否存在，fe的后缀名是否不等于apk
  if [ -z "$ap" ] || [ ! -e "$ap" ] || [ "$fe" != "apk" ]; then
    decompilation_apk 1
    return
  fi

  afn=$(basename "$ap" .apk)
  pd=$(cd "$(dirname "$0")" && pwd)
  oa="$pd/$afn"_apktool
  asp="App.smali"
  oab="$pd/$afn"_apktool/dist/$afn.apk
  zap="$pd/$afn"_zipalign.apk
  rsp="$pd/$afn"_zipalign_reSigner.apk
  idsigp="$rsp".idsig
  acp=$pd"/apktool.sh"
  am=$oa"/AndroidManifest.xml"
  ayml=$oa"/apktool.yml"
  icp=$oa"/res/mipmap-xxxhdpi/"
  osicp=$oa"/res/drawable-xxxhdpi/"

  echo
  # 执行官方提供的.sh文件，等同于 java -jar [apktool.jar的绝对路径] d [apk的绝对路径]，生成的文件夹在当前目录
  sh "$acp" d "$ap" -f -o "$oa"
  echo "decompilation finished"
}

grs() {
  local length=$1
  local seed=$(perl -MTime::HiRes=time -e 'printf("%.0f\n", time * 1000)')
  awk -v len="$length" -v seed="$seed" 'BEGIN {
        srand(seed);
        chars = "abcdefghijklmnopqrstuvwxyz";
        str = "";
        for (i = 1; i <= len; i++) {
            str = str substr(chars, int(rand() * length(chars)) + 1, 1);
        }
        print str;
    }'
}

rpn() {
  opn=$(sed -n 's/.*package="\([^"]*\)".*/\1/p' "$am" | head -n 1)

  p1=$(grs 6)
  p2=$(grs 6)
  npn="com"".$p1"".$p2"

  sed -i '' "s/$opn/$npn/g" "$am"

  echo succeed: "$opn" " -> " "$npn"
}

ran() {

  local bool=$1

  oan=$(sed -n 's/.*label="\([^"]*\)".*/\1/p' "$am" | head -n 1)

  if [ "$bool" -eq 0 ]; then
    read -p 当前应该名为："$oan"，请输入新应用名： nan
  elif [ "$bool" -eq 1 ]; then
    read -p 内容为空，请重新输入： nan
  else
    echo "ran()未知case"
  fi

  if [ -z "$nan" ]; then
    ran 1
    return
  fi

  sed -i '' "s/$oan/$nan/g" "$am"

  echo succeed: "$oan" " -> " "$nan"
}

rvn() {
  local bool=$1

  vc=$(sed -n 's/.*versionCode: \([^"]*\).*/\1/p' "$ayml" | head -n 1)
  vn=$(sed -n 's/.*versionName: \([^"]*\).*/\1/p' "$ayml" | head -n 1)

  if [ "$bool" -eq 0 ]; then
    read -p 当前版本为："$vn"，请输入新的版本号： nvn
  else
    read -p 内容为空，请重新输入： nvn
  fi

  if [ -z "$nvn" ]; then
    rvn 1
    return
  fi

  nvc=$((vc + 1))

  sed -i '' "s/versionName: $vn/versionName: $nvn/g" "$ayml"
  sed -i '' "s/versionCode: $vc/versionCode: $nvc/g" "$ayml"

  echo succeed: "$vn" " -> " "$nvn"
}

ric() {
  local bool=$1

  oic=$(sed -n 's/.*icon="@mipmap\/logo_\([0-9]\)".*/\1/p' "$am" | head -n 1)

  if [ "$bool" -eq 0 ]; then
    read -p "请输入新icon(后缀必须为 .webp、 .png、 .jpeg、 .jpg 其中一种)的绝对路径：" nic
  elif [ "$bool" -eq 1 ]; then
    read -p 文件不存在，请重新输入： nic
  else
    echo "ric()未知case"
  fi

  local fn=$(basename "$nic")
  local fe="${fn##*.}"

  if [ -z "$nic" ] || [ ! -e "$nic" ] || [ "$fe" != "webp" ] || [ "$fe" != "png" ] || [ "$fe" != "jpeg" ] || [ "$fe" != "jpg" ]; then
    ric 1
    return
  fi

  rm -rf "$icp"logo_"$oic".*

  cp "$nic" "$icp"logo_"$oic"."$fe"

  echo "succeed"
}

rosic() {
  local bool=$1

  oosic=$(sed -n 's/.*icon="@mipmap\/logo_\([0-9]\)".*/\1/p' "$am" | head -n 1)

  if [ "$bool" -eq 0 ]; then
    read -p "请输入开屏页新封面(后缀必须为 .webp、 .png、 .jpeg、 .jpg 其中一种)的绝对路径：" nosic
  elif [ "$bool" -eq 1 ]; then
    read -p 文件不存在，请重新输入： nic
  else
    echo "rosic()未知case"
  fi

  local fn=$(basename "$nosic")
  local fe="${fn##*.}"

  if [ -z "$nosic" ] || [ ! -e "$nosic" ] || [ "$fe" != "webp" ] || [ "$fe" != "png" ] || [ "$fe" != "jpeg" ] || [ "$fe" != "jpg" ]; then
    rosic 1
    return
  fi

  rm -rf "$osicp"ic_os_"$oosic".*

  cp "$nosic" "$osicp"ic_os_"$oosic"."$fe"

  echo "succeed"
}

rebuilt_apk() {
  # 执行官方提供的.sh文件，等同于 java -jar [apktool.jar的绝对路径] b [文件夹路径]
  # 如果出现报错信息：W: invalid resource directory name: /xxx/yyy/zzz/res navigation 或者 invalid resource directory name: /xxx/yyy/zzz/res drawable-
  # 原因：aapt2才支持navigation ，而AndroidKiller默认采用aapt
  # 解决：使用aapt2，需要先配置好aapt环境（aapt和aapt2都在同一个文件夹下），在b命令后面加上--use-aapt2。例如 "apktool b --use-aapt2 [反编译apk后的文件夹，如test] -o [指定二次打包的apk报名，如test_unsigned.apk]"
  sh "$acp" b "$oa"
}

zip_align() {
  # 执行对齐
  # -v表示详细输出，因为输出日志太长，所以暂时不添加-v
  # zipalign -p -f -v 4 "$apkPath" "$zipalign_apk_path"
  zipalign -p -f 4 "$oab" "$zap"
}

zip_align_info() {
  echo "请输入未签名的apk文件路径："
  read -r apkPath

  echo
  # 检查对齐方式
  zipalign -c -v 4 "$apkPath"
  echo

  echo "zipalign对齐工具命令执行完毕！"
}

signer() {
  echo "提示🔔：请输入签名文件的密码（输入的密码在界面不显示）"
  echo

  apksigner sign --verbose --ks "$ksp" --out "$rsp" "$zap"
  echo
  echo "apksigner签名执行完毕！输出文件为：" "\033]8;;file://$rsp\033\\$rsp\033]8;;\033\\"
}

signer_verify() {
  echo "Using apksigner apk签名工具（其它命令参数请输入apksigner查看）："
  apksigner --version

  echo
  echo "请输入apk文件路径："
  read -r apkPath
  echo

  echo "apk签名信息："
  # 打印签名信息，可以用于查看apk是否被签名了
  apksigner verify -v "$apkPath"
  echo

  echo "apk的证书信息："
  # apksigner 的 --print-certs 参数用于打印 APK 文件中的证书信息。
  apksigner verify --print-certs "$apkPath"
  echo

  echo "命令执行完毕!!!"
}

create_jks() {
  read -p "请输入签名文件的名字(注意后缀为.jks)：" kn
  echo
  read -p "请输入签名文件的别名：" an

  echo
  echo "提示🔔："
  echo "1. 签名文件的密码至少必须为 6 个字符"
  echo "2. 输入完 【名字与姓氏】【组织名称】【所在的省/市/自治区名称】等等，会提示所输入的信息是否正确，输入y表示完成 或者 输入n表示重新输入"
  echo

  kp=$pd/$kn

  # -genkey: 指定要生成一个新的密钥对。
  # -alias [name]: 指定要创建的密钥对的别名。在签名 APK 时，您将使用这个别名来引用这个密钥对。
  # -keyalg [RSA]: 指定使用 RSA 算法生成密钥对。RSA 是一种非对称加密算法，用于生成公钥和私钥。
  # -validity [20000]: 指定密钥的有效期限，以天为单位。在这种情况下，密钥将在 20000 天后过期。
  # -keystore [android.keystore]: 指定要创建的密钥库文件的名称。如果密钥库文件不存在，它将被创建；如果存在，将更新其中的密钥对。
  keytool -genkey -alias "$an" -keyalg RSA -validity 20000 -keystore "$kp"

  echo "签名文件生成完成：" "\033]8;;file://$kp\033\\$kp\033]8;;\033\\"
}

jks_info() {

  echo "Using keytool 密钥和证书管理工具："
  keytool -version

  echo
  echo "请输入密钥对(一般以.keystore或者.jks作为后缀)文件的路径："
  read -r keystorePath

  # 打印证书的信息
  keytool -list -v -keystore "$keystorePath"
  # 也可以使用apksigner 的 --print-certs 参数，用于打印 APK 文件中的证书信息，区别就是接受对象是apk文件
  # apksigner verify --print-certs "$apkPath"

  # 密钥库类型专用为PKCS12，如果类型为JKS，那么建议使用如下命令
  # -srckeystore [原始密钥库.jks或者.keystor文件的路径]指定原始 JKS 密钥库的路径。
  # -destkeystore [/xx.jks] 指定转换后的 PKCS12 格式密钥库的输出路径。
  # -deststoretype pkcs12 指定目标密钥库的类型为 PKCS12。
  # "keytool -importkeystore -srckeystore /xxx/xx.jks -destkeystore /xxx/xx.jks -deststoretype pkcs12" 迁移到行业标准格式 PKCS12。
}

jks() {
  local bool=$1

  if [ "$bool" -eq 0 ]; then
    read -p "请输入签名文件的（.jks）的绝对路径：" jksp
  elif [ "$bool" -eq 1 ]; then
    read -p "文件不存在，请重新输入：" jksp
  else
    echo "rass()未知case"
  fi

  # 获取文件名（不包含路径）
  local fn=$(basename "$jksp")
  # 获取扩展名
  local fe="${fn##*.}"

  if [ -z "$jksp" ] || [ ! -e "$jksp" ] || [ "$fe" != "jks" ]; then
    jks 1
    return
  fi

  echo "$jksp"
}

jd_gui() {
  java -jar "/Users/zkp/Desktop/Decompilation/jd-gui-1.6.6.jar"
}

jadx_gui() {
  # 需要先安装jadx
  # 打开jadx的可视化界面，其它命令请输出jadx -h查看
  jadx-gui
}

dex2jar_single() {
  # 提示用户输入要处理的 APK 文件路径
  read -p "请输入要处理的 .apk 文件的绝对路径: " apk_path

  # 检查输入的文件是否存在
  if [ ! -f "$apk_path" ]; then
    echo ".apk文件不存在: $apk_path"
    exit 1
  fi

  # 获取当前脚本所在目录
  script_dir=$(cd "$(dirname "$0")" && pwd)

  # 获取 APK 文件的文件名（不含路径和扩展名）
  apk_file_name=$(basename "$apk_path" .apk)
  # 获取 APK 文件的父路径
  apk_parent_dir=$(dirname "$apk_path")
  # d2j-dex2jar.sh的路径
  d2j_dex2jar_sh_path="$script_dir/dextools/d2j-dex2jar.sh"

  # 执行 d2j-dex2jar.sh，-f表示输出文件强制覆盖，-o指定输出路径
  sh $d2j_dex2jar_sh_path -f -o "$script_dir/$apk_file_name-dex2jar.jar" $apk_path

  echo "dex2jar命令执行完成！输出路径为：$script_dir/$apk_file_name-dex2jar.jar"
}

dex2jar_mult() {
  # 提示用户输入要处理的 APK 文件路径
  read -p "请输入要处理的 .apk 文件的绝对路径: " apk_path

  # 检查输入的文件是否存在
  if [ ! -f "$apk_path" ]; then
    echo ".apk文件不存在: $apk_path"
    exit 1
  fi

  # 获取当前脚本所在目录
  script_dir=$(cd "$(dirname "$0")" && pwd)

  # 获取 APK 文件的文件名（不含路径和扩展名）
  apk_file_name=$(basename "$apk_path" .apk)
  # 获取 APK 文件的父路径
  apk_parent_dir=$(dirname "$apk_path")
  # zip解压的路径
  unzip_path="$script_dir/$apk_file_name"
  # 重命名 APK 文件为 ZIP 文件
  zip_path="$unzip_path.zip"
  # 移动apk文件到指定的zip文件的路径下
  mv "$apk_path" "$zip_path"
  # 解压 ZIP 文件到当前脚本的路径下的和apk文件名相同的文件夹中。-q安静模式不会有日志输出，-o强制覆盖，-d指定输出路径
  unzip -q -o -d "$unzip_path" "$zip_path"
  # 将 ZIP 文件移回原目录，并重命名为原来的 APK 文件名
  mv "$zip_path" "$apk_parent_dir/$apk_file_name.apk"
  echo "解压完成，文件已保存到: $unzip_path"

  dex_path="$unzip_path/dex"
  # 删除文件夹
  rm -rf $dex_path
  # 创建存放所有.dex文件的文件夹
  mkdir "$dex_path"
  # 复制所有 .dex 文件到指定文件夹下
  cp "$unzip_path"/*.dex "$dex_path/"
  # d2j-dex2jar.sh的路径
  d2j_dex2jar_sh_path="$script_dir/dextools/d2j-dex2jar.sh"
  # 遍历当前脚本所在文件夹下的所有文件
  for file in "$dex_path"/*; do
    # 获取文件后缀
    extension="${file##*.}"
    # 后缀为dex
    if [ "$extension" == "dex" ]; then
      # 获取文件名字
      dex_file_name=$(basename "$file" .dex)
      echo "当前执行的dex文件：$dex_file_name"
      # 执行 d2j-dex2jar.sh，-f表示输出文件强制覆盖，-o指定输出路径
      sh $d2j_dex2jar_sh_path -f -o "$dex_path/$dex_file_name-dex2jar.jar" $file
    fi
  done

  echo "dex2jar命令执行完成！输出路径为（所有文件的后缀都为-dex2jar.jar）：$dex_path/"
}

abi_info() {
  echo "Using aapt（其它命令参数请输入aapt查看）："
  aapt version

  echo
  echo "请输入apk文件路径："
  read -r apkPath
  echo

  echo "apk的abi信息："
  aapt dump "$apkPath" | grep native-code
  echo

  echo "命令执行完毕!!!"
}

opt() {
  echo ""
  echo "请选择以下选项："
  echo "=========================="
  echo "0). 反编译apk(其余功能都需要先完成此操作)"
  echo "1). 更换包名(自动随机生成)"
  echo "2). 更换应用名"
  echo "3). 更换应用icon"
  echo "4). 更换版本号"
  echo "10). 重新编译"
  echo "========================="

  echo ""

  echo "=========================="
  echo "5). 创建证书(签名文件)"
  echo "9). 查看证书(签名文件)信息"
  echo "=========================="

  echo ""

  echo "=========================="
  echo "6). 打开jd_gui"
  echo "7). 打开jadx_gui"
  echo "11). apk文件转化为jar文件"
  echo "12). apk文件中的dex文件转化为jar文件"
  echo "=========================="

  echo ""

  echo "=========================="
  echo "8). 查看apk的签名信息"
  echo "13). 查看apk的cpu架构信息"
  echo "=========================="

  echo ""

  read -r choice

  case $choice in
  "0")
    decompilation_apk 0
    opt
    ;;
  "1")
    rpn
    opt
    ;;
  "2")
    ran 0
    opt
    ;;
  "3")
    ric 0
    opt
    ;;
  "4")
    rvn 0
    opt
    ;;
  "5")
    create_jks
    opt
    ;;
  "6")
    jd_gui
    opt
    ;;
  "7")
    jadx_gui
    opt
    ;;
  "8")
    signer_verify
    ;;
  "9")
    jks_info
    ;;
  "10")
    ksp=$(jks 0)

    echo "Recompile, Please wait........"
    echo

    rebuilt_apk

    echo

    zip_align
    echo

    signer
    echo

    rm -rf "$oa"
    rm "$zap"
    rm "$idsigp"
    ;;
  "11")
    dex2jar_single
    opt
    ;;
  "12")
    dex2jar_mult
    opt
    ;;
  "13")
    abi_info
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

if ! gradle -v >/dev/null 2>&1; then
  echo "gradle 未安装， 请参考 "https://blog.csdn.net/lovedingd/article/details/123337180" 进行安装和配置"
  return
fi

if ! command -v adb >/dev/null 2>&1; then
  echo "android sdk 未安装，请参考 https://blog.csdn.net/OnlyoneFrist/article/details/132039089 进行安装和配置。"
  return
fi

if ! awk --version >/dev/null 2>&1; then
  echo "awk 未安装，可以使用 "brew install awk" 命令进行安装"
  return
fi

if ! perl -v >/dev/null 2>&1; then
  echo "perl 未安装，可以使用 "brew install perl" 命令进行安装"
  return
fi

opt
