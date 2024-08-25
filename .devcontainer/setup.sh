#!/bin/sh

set -e

# Initialize submodules
git submodule sync
git submodule update --init  # Non-recursive for now

# Create env and install deps
. /opt/conda/etc/profile.d/conda.sh

set -x
conda create --yes -n diplomacy python=3.7
source activate diplomacy

# ci-hack: Install from conda to get cpu only version.
conda install pytorch==1.4 cpuonly -c pytorch --yes

# For boringssl in grpc.
conda install go --yes

pip install -r requirements.txt --progress-bar off
conda install protobuf --yes

if ! ls /postman/postman*.whl; then
    echo "Need full postman install"
    git submodule update --recursive
    pushd thirdparty/github/fairinternal/postman/
    make compile_slow
    make build_wheel
    rm -rf /postman
    mkdir /postman
    cp -v postman/dist/*whl /postman/
    cp -v postman/python/postman/rpc*so /postman/
    popd
fi
pip install /postman/postman*.whl
# Due to a bug postman wheel doesn't contain .so. So installing it manually.
cp /postman/*.so $CONDA_PREFIX/lib/python3.*/site-packages/postman
N_DIPCC_JOBS=8 SKIP_TESTS=1 make deps all
pip install -U protobuf

# Hello world
source activate diplomacy
python run.py --help

# Check test game cache is up-to-date
source activate diplomacy
# Enable once the cache is deterministic
# python tests/build_test_cache.py
git status
if ! git diff-index --quiet HEAD --; then
    echo "ERROR: tests/build_test_cache.py produced new cache! Re-build and commit cache if it's expected."
    exit 1
fi

# Make
make
