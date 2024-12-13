1. 环境配置：下载apktool.jar、apktool.sh、dextools、jd-gui-1.6.6.jar、jadx、以及安装android studio（包括jdk，adk等等）
2. apktool_decompilation_apk.sh：反编译脚本，解压.apk文件
2. apktool_built_apk.sh：对.apk文件解压后的文件夹进行重新打包
2. dex2jar_mult.sh：多个dex文件转换为多个jar文件
2. dex2jar_single.sh：单个dex文件转换为单个jar文件
3. open_jd_gui.sh：可视化工具，将编译后的文件夹直接拖入该工具中。
4. open_jadx_gui.sh：更加优秀可视化工具
5. keytool_create.sh：创建签名文件
6. keytool_info.sh：获取签名文件的信息
7. zipalign.sh：将重新编译后的apk文件进行对齐操作
8. zipalign_info.sh：对执行完对齐操作后的文件，检查其对齐方式
9. apksigner_sign.sh：对执行完对齐操作的apk文件，进行签名
10. apksigner_verify.sh：获取apk的签名信息