#!/bin/sh

git submodule sync
git submodule update --init  # Non-recursive for now

sudo apt install -y wget bzip2 ca-certificates curl git build-essential clang-format git wget cmake build-essential autoconf libtool pkg-config libgoogle-glog-dev

# Create conda env
conda create --yes -n diplomacy python=3.8
source activate diplomacy

# Install pytorch, pybind11
conda install --yes pytorch::pytorch torchvision conda-forge::cudatoolkit=11.0
conda install --yes pybind11

# Install go for boringssl in grpc
# We have some hacky patching code for protobuf that is not guaranteed
# to work on versions other than this.
conda install --yes go protobuf=3.19.1

# Install python requirements
pip install --use-pep517 -r requirements.txt

# Local pip installs
pip install --use-pep517 -e ./thirdparty/github/fairinternal/postman/nest/
pip install --use-pep517 -e ./thirdparty/github/fairinternal/postman/postman/
pip install --use-pep517 -e . -vv

# Make
make
