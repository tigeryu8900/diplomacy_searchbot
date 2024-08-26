#!/bin/bash

set -e

# # wget http://developer.download.nvidia.com/compute/cuda/11.0.2/local_installers/cuda_11.0.2_450.51.05_linux.run
# sudo sh cuda_11.0.2_450.51.05_linux.run  --override

# # wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin
# # sudo mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600

# # #add public keys

# # # Old key
# # #sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/7fa2af80.pub

# # # new key, added 2022-04-25 22:52
# # sudo apt-key adv --yes --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/3bf863cc.pub

# # sudo add-apt-repository --yes "deb http://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/ /"

# # sudo apt update
# # sudo apt install --yes cuda-toolkit-11-0

# # tar -xzvf cudnn-11.2-linux-x64-v8.1.1.33.tgz

# sudo cp cuda/include/cudnn*.h /usr/local/cuda/include
# sudo cp cuda/lib64/libcudnn* /usr/local/cuda/lib64
# sudo chmod a+r /usr/local/cuda/include/cudnn*.h /usr/local/cuda/lib64/libcudnn*

# export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/cuda/lib64:/usr/local/cuda/extras/CUPTI/lib64"
# export CUDA_HOME=/usr/local/cuda
# export PATH="/usr/local/cuda/bin:$PATH"

# Initialize submodules
git config --global --add safe.directory /workspaces/diplomacy_searchbot
git submodule sync
git submodule update --init  # Non-recursive for now

# Create env and install deps
. /opt/conda/etc/profile.d/conda.sh

set -x
conda create --yes -n diplomacy python=3.7
source activate diplomacy

# conda install conda==24.7.0
# conda install setuptools==58.2.0
conda install setuptools

export NO_CUDA=1
conda env config vars set NO_CUDA=1

# ci-hack: Install from conda to get cpu only version.
conda install pytorch==1.4 cpuonly -c pytorch --yes
# conda install --yes pytorch=1.7.1 torchvision cudatoolkit=11.0 -c pytorch
conda install pybind11 --yes

# For boringssl in grpc.
conda install go --yes

pip install -r requirements.txt --progress-bar off
conda install protobuf --yes

# export CUDA_HOME=$CONDA_PREFIX

# if ! ls /postman/postman*.whl; then
#     echo "Need full postman install"
#     git submodule update --recursive
#     pushd thirdparty/github/fairinternal/postman/
#     NO_CUDA=1 make compile
#     make build_wheel
#     rm -rf /postman
#     mkdir /postman
#     cp -v postman/dist/*whl /postman/
#     cp -v postman/python/postman/rpc*so /postman/
#     popd
# fi
# pip install /postman/postman*.whl
# # Due to a bug postman wheel doesn't contain .so. So installing it manually.
# cp /postman/*.so $CONDA_PREFIX/lib/python3.*/site-packages/postman
# N_DIPCC_JOBS=8 SKIP_TESTS=1 make deps all
# pip install -U protobuf

conda install --yes go~=1.13 protobuf=3.19.1

# Install python requirements
pip install --use-pep517 -r requirements.txt

# Local pip installs
pip install --use-pep517 -e ./thirdparty/github/fairinternal/postman/nest/
pip install --use-pep517 -e ./thirdparty/github/fairinternal/postman/postman/
pip install --use-pep517 -e . -vv

# Hello world
source activate diplomacy
# python run.py --help

# Check test game cache is up-to-date
# source activate diplomacy
# Enable once the cache is deterministic
# python tests/build_test_cache.py
# git status
# if ! git diff-index --quiet HEAD --; then
#     echo "ERROR: tests/build_test_cache.py produced new cache! Re-build and commit cache if it's expected."
#     exit 1
# fi

# Make
make
