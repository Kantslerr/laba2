#!/bin/bash
#Переменная сравнения = имя компьютера
name=$(hostname)
#Проверка на совпадение имени и есть ли уже директория shara
if [[ "$name" == "Server"  &&   -d /mnt/shara ]]; then
  echo “Скрипт был уже запущен ранее, не трогай больше его рукожоп”
elif [[ "$name" == "Server"  && !   -d /mnt/shara ]]; then
#Установка и обновление пакетов на сервере
  sudo apt-get update
  sudo apt-get install nfs-kernel-server nfs-common -y
#Создание директории и изменения прав
  sudo mkdir –p /mnt/shara
  sudo chown nobody:nogroup /mnt/shara
  sudo chmod 777 /mnt/shara
#Разрешения доступа для подсети 192.168.100.0 ссылка на пояснения параметров https://help.ubuntu.ru/wiki/nfs
  sudo echo "/mnt/shara 192.168.100.0/24(rw,insecure,nohide,all_squash,anonuid=1000,anongid=1000,no_subtree_check)" | tee -a  /etc/exports
#Экспорт общего каталога и ребут ядра NFS
  sudo exportfs -a
  sudo systemctl restart nfs-kernel-server
#Установка и настройка брандмауэра для проверки открытия порта sudo ufw status
  sudo apt install ufw
  sudo ufw enable
  sudo ufw allow from 192.168.100.0/24 to any port nfs
  sudo ufw allow ssh
#Блок проверки для клиента NFS
elif [[ "$name" == "Client"  &&   -d /mnt/shara_client ]]; then
  echo “Скрипт был уже запущен ранее, не трогай больше его рукожоп”
elif [[ "$name" == "Client"  &&  ! -d /mnt/shara_client ]]; then
  sudo apt-get update
  sudo apt-get install nfs-common -y
# Создание точки монтирования для клиента NFS
  sudo mkdir -p /mnt/shara_client
  sudo chmod 777 /mnt/shara_client
#Подключение общего каталога сервера к клиенту
  sudo mount -t nfs -O uid=1000,iocharset=utf-8 192.168.100.28:/mnt/shara    /mnt/shara_client
else
  echo “Идите лесом мы вас не звали”
fi

