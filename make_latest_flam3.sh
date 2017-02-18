#!/bin/bash

sudo apt-get install git make gcc zlib1g-dev libpng-dev libjpeg-dev autotools-dev libxml2-dev automake
git clone https://github.com/scottdraves/flam3.git
pushd flam3
sed -ie '2314s/1.14/1.15/' configure
ln -sf /usr/share/automake-1.15/compile compile
./configure
make
sudo make install
popd