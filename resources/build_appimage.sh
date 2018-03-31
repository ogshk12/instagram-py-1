#!/usr/bin/bash
# The MIT Licence.
# Copyright (C) 2018 Antony Jr.
#
# This shell script builds a AppImage for the
# continous integration.
# -------------------------------------------

# Make Required Directories
mkdir -p dist/instagram-py.AppDir
mkdir -p dist/tor_install
cd dist


# Get Conda to create portable python environments.
wget -c -q https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
chmod +x Miniconda3-latest-Linux-x86_64.sh
./Miniconda3-latest-Linux-x86_64.sh -b -p ./conda


# Conda installation ( Kind of ? )
PATH=$(pwd)/conda/bin:$PATH # set path with prefix.

# create a new environment.
conda create -n instagram-py python=3.6 -y # we need python 3.6 >= for instagram-py.

# Install instagram-py into the new environment
source activate instagram-py
pip install requests[socks]
pip install stem
pip install instagram-py # always install from official repo.

# Only copy our newly created environment to our appdir.
cp -p -r conda/envs/instagram-py instagram-py.AppDir/usr
python ../resources/patch_shebang.py instagram-py.AppDir/usr/bin/instagram-py # Patch the shebang.


# Creating the AppImage.
cp ../resources/instagram-py.desktop instagram-py.AppDir/ # Desktop file
cp ../resources/icon.png instagram-py.AppDir/ # icon file ( just touched! )
# copy a small wrapper to set the environmental variable to make instagram-py
# do some magic for portability.
cp -p ../resources/instagram-py-wrapper instagram-py.AppDir/usr/bin/
# Next we need to build tor and then install it into our appimage.
wget -q -c "https://github.com/torproject/tor/archive/tor-0.3.2.10.tar.gz"
tar -xvf tor-0.3.2.10.tar.gz
cd tor-tor-0.3.2.10
sh autogen.sh
./configure --disable-asciidoc
make -j$(nproc)
make DESTDIR=../tor_install install -j$(nproc)
cd ..
cp -r -p tor_install/usr/local/* instagram-py.AppDir/usr/ # Copy tor installation.
cp /usr/lib/libevent* instagram-py.AppDir/usr/lib/ # Copy libevent from travis build system.

# Get the AppRun.
wget -O instagram-py.AppDir/AppRun -c -q "https://github.com/AppImage/AppImageKit/releases/download/continuous/AppRun-x86_64"
chmod +x instagram-py.AppDir/AppRun


# Thats it we are ready to pack.
# The package should be approx. 45 MiB.

# Lets get the tools
wget -c -q "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage"
chmod +x appimagetool-x86_64.AppImage

# Pack Everything with AppImageTool.
./appimagetool-x86_64.AppImage -g instagram-py.AppDir
