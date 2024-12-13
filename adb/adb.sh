#!/bin/bash

opt() {

  option_tip="请选择以下选项："
  option1="1). 启动adb"
  option2="2). 停止adb"
  option3="3). 监听指定的网络端口"
  option4="4). 查询已连接的设备/模拟器列表"
  option5="5). 查询已连接的设备的应用列表"
  option6="6). 查询已连接的设备的型号信息"
  option7="7). 查询已连接的设备的电池状态"
  option8="8). 查询已连接的设备的屏幕分辨率"
  option9="9). WiFi无线调试(前提：Android设备版本≥11,adb版本 ≥ 30.0.0)"
  option10="10). 查询已连接设备的指定应用的详细信息"
  option11="11). 启动设备的系统设置页面"
  option12="12). 实时显示设备的系统日志"
  option12="12). 查询设备支持的cpu架构(abi)"

  echo ""
  echo "$option_tip"
  echo "$option1"
  echo "$option2"
  echo "$option3"
  echo "$option4"
  echo "$option5"
  echo "$option6"
  echo "$option7"
  echo "$option8"
  echo "$option9"
  echo "$option10"
  echo "$option11"
  echo "$option12"
  echo ""

  read -r choice

  case $choice in
  "1")
    # 启动adb：一般无需手动执行此命令，在运行 adb 命令时若发现 adb server 没有启动会自动调起。
    adb start-server
    opt
    ;;
  "2")
    # 停止adb
    adb kill-server
    opt
    ;;
  "3")
    # -p 指定 adb server 的网络端口，默认端口为 5037
    read -p "请输入监听的网络端口：" port
    adb -P "$port" start-server
    opt
    ;;
  "4")
    adb devices -l
    opt
    ;;
  "5")
    adb shell pm list packages
    opt
    ;;
  "6")
    adb shell getprop ro.product.model
    opt
    ;;
  "7")
    # AC powered 是否通过交流电源充电。true 表示是，false 表示否。
    # USB powered 是否通过 USB 供电。
    # Wireless powered 是否通过无线充电供电。
    # Max charging current 最大充电电流（单位：微安）。
    # Max charging voltage 最大充电电压（单位：微伏）。
    # Charge counter 当前电池剩余的电量（单位：微安时，具体取决于设备）。
    # status 电池状态（如下状态码）。
    # health 电池健康状态（如下状态码）。
    # present 电池是否存在（通常为 true）。
    # level 当前电量百分比（如 85%）。
    # scale 电量百分比的最大值（通常为 100）。
    # voltage 电池电压（单位：毫伏）。
    # temperature 电池温度（单位：0.1 摄氏度，如 300 表示 30.0°C）。
    # technology 电池技术类型（如 Li-ion 表示锂电池）。
    adb shell dumpsys battery
    opt
    ;;
  "8")
    # Physical size: 设备的物理分辨率，即屏幕的实际硬件像素。
    # Override size: 被修改的分辨率（如果存在）。如果没有修改，则不会显示此行。
    adb shell wm size
    opt
    ;;
  "9")
    # 1. 手机和电脑需连接在同一 WiFi 下；
    # 2. 保证 SDK 为最新版本（adb --version ≥ 30.0.0）；Android设备版本 ≥ 11
    # 3. 手机启用开发者选项和无线调试模式；
    # 4. 允许无线调试后，选择使用配对码配对。记下显示的配对码、IP 地址和端口号；
    # 5. 运行adb pair ip:port，使用第 4 步中的 IP 地址和端口号；
    # 6. 根据提示，输入第 3 步中的配对码，系统会显示一条消息，表明您的设备已成功配对；
    # 7. 最后连接手机，运行 adb connect ip:port。
    read -p "请输入手机ip地址和端口：" ipport
    adb pair "$ipport"
    adb connect "$ipport"
    opt
    ;;
  "10")
    # 1. userId=10234:
    #   • 系统为应用分配的唯一用户 ID，用于文件权限管理。
    # 2. versionCode 和 versionName:
    #   • 应用的内部版本号和外部展示版本号。
    # 3. installPermissions:
    #   • 列出应用所声明的权限及其授予状态。
    # 4. dataDir:
    #   • 应用的私有数据存储目录。
    # 5. codePath 和 resourcePath:
    #   • 应用 APK 文件的存放路径。
    # 6. firstInstallTime 和 lastUpdateTime:
    #   • 应用的首次安装时间和最近一次更新的时间。
    # 7. signingKeySet:
    #   • 应用签名的密钥信息。
    # 8. packageFlags:
    #   • 包含应用的特性标志，例如是否为系统应用、可调试等。
    read -p "请输入应用包名" pn
    adb shell dumpsys package "$pn"
    opt
    ;;
  "11")
    adb shell am start -a android.settings.SETTINGS
    opt
    ;;
  "12")
    adb logcat
    opt
    ;;
  "13")
    adb shell getprop ro.product.cpu.abilist
    opt
    ;;
  *)
    echo "无此选项，请重新选择"
    opt
    ;;
  esac
}

opt
