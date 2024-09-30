#!/bin/bash

echo -e '\e[40m\e[32m'
echo -e '███╗   ██╗ ██████╗ ██████╗ ███████╗██████╗ ██╗   ██╗███╗   ██╗███╗   ██╗███████╗██████╗ '
echo -e '████╗  ██║██╔═══██╗██╔══██╗██╔════╝██╔══██╗██║   ██║████╗  ██║████╗  ██║██╔════╝██╔══██╗'
echo -e '██╔██╗ ██║██║   ██║██║  ██║█████╗  ██████╔╝██║   ██║██╔██╗ ██║██╔██╗ ██║█████╗  ██████╔╝'
echo -e '██║╚██╗██║██║   ██║██║  ██║██╔══╝  ██╔══██╗██║   ██║██║╚██╗██║██║╚██╗██║██╔══╝  ██╔══██╗'
echo -e '██║ ╚████║╚██████╔╝██████╔╝███████╗██║  ██║╚██████╔╝██║ ╚████║██║ ╚████║███████╗██║  ██║'
echo -e '╚═╝  ╚═══╝ ╚═════╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝'
echo -e '\e[0m'

echo -e "\nПодписаться на канал may.crypto{🦅} чтобы быть в курсе самых актуальных нод - https://t.me/maycrypto\n"


# Определение стиля текста и цветов
BOLD="\033[1m"
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

# Определение функции для выполнения команд с выводом сообщений
execute_with_prompt() {
    echo -e "${BLUE}$1${NC}" # Сообщение о том, что команда выполняется
    eval "$2" # Выполнение переданной команды
    if [ $? -ne 0 ]; then
        echo -e "${RED}Ошибка при выполнении команды: $2${NC}"
        exit 1
    fi
}

echo -e "${GREEN}Начинается установка узла Analog...${NC}"

# Обновление системных зависимостей
echo -e "${BLUE}Обновление системных зависимостей...${NC}"
echo
sudo apt update && sudo apt upgrade -y
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
echo

# Проверка установки Docker
echo -e "${BOLD}${CYAN}Проверка установки Docker...${NC}"
if command -v docker >/dev/null 2>&1; then
    echo -e "${GREEN}Docker уже установлен.${NC}"
else
    echo -e "${RED}Docker не установлен. Начинаем установку Docker...${NC}"
    sudo apt update && sudo apt install -y curl net-tools
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    echo -e "${GREEN}Docker успешно установлен.${NC}"
fi

# Проверка установки Docker
echo -e "${BLUE}Проверка установки Docker...${NC}"
echo
sudo docker run hello-world
echo

# Загрузка Docker-образа Analog Timechain
echo -e "${BLUE}Загрузка Docker-образа Analog Timechain...${NC}"
echo
docker pull analoglabs/timechain
echo

# Установка переменной NODE_NAME
echo -e "${BLUE}Установка переменной NODE_NAME...${NC}"
echo
read -p "Введите имя для узла: " NODE_NAME
echo "export NODE_NAME=\"$NODE_NAME\"" >> ~/.bash_profile
source ~/.bash_profile
echo
echo -e "${BLUE}Запомните имя узла, оно понадобится при отправке формы на белый список.${NC}"
echo

# Установка UFW и открытие портов
execute_with_prompt "Установка UFW..." "sudo apt-get install -y ufw"
execute_with_prompt "Открытие необходимых портов..." \
    "sudo ufw enable && \
    sudo ufw allow ssh && \
    sudo ufw allow 9944/tcp && \
    sudo ufw allow 30303/tcp"

# Запуск Docker-контейнера Analog Timechain
echo -e "${BLUE}Запуск Docker-контейнера Analog Timechain...${NC}"
echo
docker run -d --name analog -p 9944:9944 -p 30303:30303 analoglabs/timechain \
    --base-path /data \
    --rpc-external \
    --unsafe-rpc-external \
    --rpc-cors all \
    --name $NODE_NAME \
    --telemetry-url="wss://telemetry.analog.one/submit 9" \
    --rpc-methods Unsafe
echo

# Установка websocat
echo -e "${BLUE}Установка websocat...${NC}"
sudo wget -qO /usr/local/bin/websocat https://github.com/vi/websocat/releases/latest/download/websocat.x86_64-unknown-linux-musl
sudo chmod a+x /usr/local/bin/websocat
echo

# Проверка версии websocat
echo -e "${BLUE}Проверка версии websocat...${NC}"
echo
websocat --version
if [ $? -ne 0 ]; then
    echo "Не удалось установить websocat или он недоступен по пути."
    exit 1
fi
echo

# Установка jq
sudo apt-get install -y jq

# Небольшая пауза
sleep 2

# Генерация ротационного ключа с помощью websocat
echo -e "${BLUE}Генерация ротационного ключа с помощью websocat...${NC}"
echo
RESPONSE=$(echo '{"id":1,"jsonrpc":"2.0","method":"author_rotateKeys","params":[]}' | websocat -n1 -B 99999999 ws://127.0.0.1:9944)
if [ $? -ne 0 ]; then
    echo "Не удалось сгенерировать ротационный ключ с помощью websocat."
    exit 1
fi
KEY=$(echo $RESPONSE | jq -r '.result')
echo -e "Ротационный ключ: ${GREEN}$KEY${NC}"
read -p "Пожалуйста, сохраните ротационный ключ и нажмите Enter: "

echo -e "${YELLOW}Для продолжения используйте 16 пункт в гайде...${NC}"
exit
