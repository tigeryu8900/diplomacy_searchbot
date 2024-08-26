#!/bin/sh

git config --global --add safe.directory /workspaces/diplomacy_searchbot
git submodule sync
git submodule update --init  --recursive

sudo apt install -y wget bzip2 ca-certificates curl git build-essential clang-format git wget cmake build-essential autoconf libtool pkg-config libgoogle-glog-dev

wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-4.7.10-Linux-x86_64.sh -O ~/miniconda.sh
/bin/bash ~/miniconda.sh -b

# Create conda env
conda create --yes -n diplomacy python=3.8
source activate diplomacy

# conda install conda=4.7.10
# conda install 

# Install pytorch, pybind11
conda install --yes pytorch::pytorch torchvision conda-forge::cudatoolkit=11.0
conda install --yes pybind11

# Install go for boringssl in grpc
# We have some hacky patching code for protobuf that is not guaranteed
# to work on versions other than this.
conda install --yes go~=1.13 protobuf=3.19.1

# Install python requirements
pip install --use-pep517 -r requirements.txt

# Local pip installs
pip install --use-pep517 -e ./thirdparty/github/fairinternal/postman/nest/
pip install --use-pep517 -e ./thirdparty/github/fairinternal/postman/postman/
pip install --use-pep517 -e . -vv

# Make
make
