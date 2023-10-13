#!/bin/bash
function on_exit() {
  docker compose down --volumes
}

trap 'on_exit; exit 1' 2 15

if [[ $1 == with_api ]];then
  docker compose up --remove-orphans --build --profile $1 || on_exit
else
  docker compose up --remove-orphans || on_exit
fi
