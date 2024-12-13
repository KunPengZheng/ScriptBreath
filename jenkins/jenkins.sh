#!/bin/sh
opt() {

  option_tip="请选择以下选项："
  option1="1). 启动jenkins"
  option2="2). 停止jenkins"
  option3="3). 重启jenkins"
  option4="4). 账号密码"

  echo ""
  echo "$option_tip"
  echo "$option1"
  echo "$option2"
  echo "$option3"
  echo "$option4"
  echo ""

  read -r choice

  case $choice in
  "1")
    if brew services list | grep -q "jenkins.*started"; then
      brew services restart jenkins
    else
      brew services start jenkins
    fi
    open -a "Google Chrome" http://localhost:8080/
    opt
    ;;
  "2")
    osascript -e 'tell application "Google Chrome" to close (tabs of window 1 whose URL contains "localhost:8080")'
    brew services stop jenkins
    opt
    ;;
  "3")
    brew services restart jenkins
    open -a "Google Chrome" http://localhost:8080/
    opt
    ;;
  "4")
    local pp="/Users/zkp/.jenkins/secrets/initialAdminPassword"
    echo "account: admin password: e2b19ba3e8ed4482807d59dee6aaca05(\033]8;;file://$pp\033\\$pp\033]8;;\033\\)"
    echo "account: root  password: root"
    opt
    ;;
  *)
    echo "无此选项，请重新选择"
    opt
    ;;
  esac
}

opt
