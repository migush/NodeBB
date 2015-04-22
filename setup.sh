#!/bin/bash

set -e

prod=false
while getopts "p" opt; do
    case $opt in
        p)
            prod=true
            ;;
    esac
done

color() {
      printf '\033[%sm%s\033[m\n' "$@"
      # usage color "31;5" "string"
      # 0 default
      # 5 blink, 1 strong, 4 underlined
      # fg: 31 red,  32 green, 33 yellow, 34 blue, 35 purple, 36 cyan, 37 white
      # bg: 40 black, 41 red, 44 blue, 45 purple
      }

color '36;1' "

     This script installs dependencies for NodeBB.

"

color '35;1' 'Updating packages...'
apt-get update

color '35;1' 'Installing dependencies from apt-get...'

apt-get -y install git \
                   wget \
                   curl \
                   stow \
                   build-essential \
                   gcc \
                   g++ \
                   libgmp3-dev \
                   libavahi-compat-libdnssd-dev \
                   imagemagick

color '35;1' 'Installing Node.js...'
curl -sL https://deb.nodesource.com/setup | bash -
apt-get install -y nodejs

color '35;1' 'Installing npm...'
curl -L https://npmjs.com/install.sh | sh

color "35;1" "Installing mongdb..."
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
echo "deb http://repo.mongodb.org/apt/ubuntu "$(lsb_release -sc)"/mongodb-org/3.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.0.list
apt-get update
apt-get install -y mongodb-org

# Switch to a temporary directory to install dependencies, since the source
# directory might be mounted from a VM host with weird permissions.
src_dir=$(pwd)
temp_dir=`mktemp -d`
cd "$temp_dir"

if ! ${prod}; then
    color "35;1" "Ensuring redis version..."
    redis_version=2.8.19
    if ! [ -e /usr/local/stow/redis-${redis_version} ]; then
        color "35;1" "Downloading and installing redis-${redis_version}..."
        curl -L -O --progress-bar http://download.redis.io/releases/redis-${redis_version}.tar.gz
        echo "3e362f4770ac2fdbdce58a5aa951c1967e0facc8 *redis-${redis_version}.tar.gz" | sha1sum -c --quiet || exit 1
        tar -xf redis-${redis_version}.tar.gz
        cd redis-${redis_version}
        make -j2 || exit 1
        rm -rf /usr/local/stow/redis-${redis_version}
        make PREFIX=/usr/local/stow/redis-${redis_version} install
        stow -d /usr/local/stow/ -R redis-${redis_version}
        cd utils
        echo -e -n "\n\n\n\n\n\n" | ./install_server.sh
        rm -f /tmp/6379.conf
        cd ../..
        rm -rf redis-${redis_version} redis-${redis_version}.tar.gz
    fi
    color '34;1' 'redis-'${redis_version}' installed.'
fi

if ! ${prod}; then
    color "35;1" "Update RabbitMQ"
    color "35;1" "Add the official rabbitmq source to your apt-get sources.list"
    sudo sh -c "echo 'deb http://www.rabbitmq.com/debian/ testing main' > /etc/apt/sources.list.d/rabbitmq.list";

    color "35;1" "Install the certificate"
    wget http://www.rabbitmq.com/rabbitmq-signing-key-public.asc
    sudo apt-key add rabbitmq-signing-key-public.asc
    rm rabbitmq-signing-key-public.asc

    color "35;1" "Now install the latest rabbitmq"
    sudo apt-get update;
    sudo apt-get install -y rabbitmq-server;
    rabbitmqctl add_user fusion fusion
    rabbitmqctl set_user_tags fusion administrator
    rabbitmq-plugins enable rabbitmq_management
fi

color '35;1' 'Finished installing dependencies.'

color '35;1' 'Cleaning up...'
apt-get -y autoremove

color '35;1' 'Installing forever'
npm install -g forever

color '35;1' 'Installing nodejs dependencies'
cd /vagrant
sudo -H -u vagrant npm install

color '35;1' 'Done!.'
