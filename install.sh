#!/bin/bash

# Pętla dla wszystkich plików YAML w bieżącym katalogu
# Pliki nie są w odpowiedniej kolejności
#for file in *.yaml; do
#  if [[ -f "$file" ]]; then
#    echo "☁️  Wykonywanie pliku $file"
#    kubectl apply -f "$file"
#  fi
#done

# Pozostaje zatem ręcznie
echo -e "\n\t ☁️ Instalacja zainicjowana. ☁️\n"

date

echo -e "\n\t 🔧 Tworzenie przestrzeni nazw\n"
minikube kubectl -- create ns lab5

sleep 2

echo -e "\n\t 🔧 Aplikowanie plików .yaml\n"
minikube kubectl -- apply -f lab5quota.yaml

sleep 2

minikube kubectl -- apply -f worker_resoursed.yaml

sleep 2

echo -e "\n\t 🔧 Uruchomienie serwera metryk\n"
minikube addons enable metrics-server
minikube addons list | grep -i metrics-server

sleep 2

echo -e "\n\t 🔧 HPA time!\n"
minikube kubectl -- create -f php-apache_autoscale.yaml

minikube kubectl -- apply -f php-apache.yaml

echo -e "\n\t ☁️ Instalacja zakończona. ☁️\n\n"

minikube kubectl -- get quota -n lab5
minikube kubectl -- describe hpa php-apache -n lab5

echo -e "\n\n Chwilę należy odczekać po uruchomieniu."