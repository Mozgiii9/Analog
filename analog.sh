#!/bin/bash

# Функция для отображения логотипа
display_logo() {
  echo -e '\e[40m\e[32m'
  echo -e '███╗   ██╗ ██████╗ ██████╗ ███████╗██████╗ ██╗   ██╗███╗   ██╗███╗   ██╗███████╗██████╗ '
  echo -e '████╗  ██║██╔═══██╗██╔══██╗██╔════╝██╔══██╗██║   ██║████╗  ██║████╗  ██║██╔════╝██╔══██╗'
  echo -e '██╔██╗ ██║██║   ██║██║  ██║█████╗  ██████╔╝██║   ██║██╔██╗ ██║██╔██╗ ██║█████╗  ██████╔╝'
  echo -e '██║╚██╗██║██║   ██║██║  ██║██╔══╝  ██╔══██╗██║   ██║██║╚██╗██║██║╚██╗██║██╔══╝  ██╔══██╗'
  echo -e '██║ ╚████║╚██████╔╝██████╔╝███████╗██║  ██║╚██████╔╝██║ ╚████║██║ ╚████║███████╗██║  ██║'
  echo -e '╚═╝  ╚═══╝ ╚═════╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝'
  echo -e '\e[0m'

  echo -e "\nПодписаться на канал may.crypto{🦅} чтобы быть в курсе самых актуальных нод - https://t.me/maycrypto\n"
}

# Функция для установки необходимых пакетов
install_packages() {
  sudo apt-get update && sudo apt-get upgrade -y
  sudo apt install -y tmux docker.io
  wget https://github.com/vi/websocat/releases/latest/download/websocat.x86_64-unknown-linux-musl -O websocat
  chmod +x websocat
  sudo mv websocat /usr/local/bin/
  websocat --version
}

# Функция для запуска ноды
run_node() {
  read -p "Введите имя ноды: " NODE_NAME
  sudo docker pull analoglabs/timechain
  sudo docker run -d -p 9944:9944 -p 30303:30303 --name analog_node analoglabs/timechain --base-path /data --unsafe-rpc-external --rpc-methods=Unsafe --name "$NODE_NAME" --telemetry-url='wss://telemetry.analog.one/submit 9'
}

# Функция для проверки логов ноды
check_logs() {
  echo "Через 15 секунд пойдут логи ноды. Для выхода из логов используйте комбинацию клавиш CTRL+C"
  sleep 15
  sudo docker logs -f analog_node
}

# Функция для сохранения результата
save_result() {
  echo '{"id":1,"jsonrpc":"2.0","method":"author_rotateKeys","params":[]}' | websocat -n1 -B 99999999 ws://127.0.0.1:9944
}

# Основное меню
main_menu() {
  display_logo
  while true; do
    echo "Меню:"
    echo "1. Установить ноду Analog"
    echo "2. Проверить логи ноды Analog"
    echo "3. Выйти из скрипта"
    read -p "Выберите опцию: " option

    case $option in
      1)
        install_packages
        run_node
        ;;
      2)
        check_logs
        ;;
      3)
        echo "Выход из скрипта."
        exit 0
        ;;
      *)
        echo "Неверный ввод. Пожалуйста, выберите правильную опцию."
        ;;
    esac
  done
}

# Запуск основного меню
main_menu
