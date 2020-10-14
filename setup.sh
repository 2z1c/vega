#!/usr/bin/env bash

# setup for docker compile
_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TOP=$(realpath ${_DIR}/../)

export DOWNLOAD_CACHE=$TOP/download_cache
export PREBUILD=$TOP/prebuild
export PATH=${TOP}/prebuild/cmake/bin/:$TOP/script/bin:${PATH}
export ZEPHYR_TOOLCHAIN_VARIANT=zephyr
export ZEPHYR_SDK_INSTALL_DIR=$PREBUILD/sdk

function prepare_build()
{
    # download sdk and cmake
    if [ ! -d $DOWNLOAD_CACHE ]; then
	mkdir -p $DOWNLOAD_CACHE
	aws s3 sync s3://syrius-chameleon-files/ $DOWNLOAD_CACHE
    fi
    # download cmake
    if [ ! -d $PREBUILD/cmake ]; then
	mkdir -p $PREBUILD/cmake
	tar -xzvf $DOWNLOAD_CACHE/cmake/cmake*.tar.gz -C $PREBUILD/cmake --strip-components 1
    fi
    # download sdk
    if [ ! -d $PREBUILD/sdk ]; then
	mkdir -p $PREBUILD/sdk
	chmod +x $DOWNLOAD_CACHE/sdk/*.run
	$DOWNLOAD_CACHE/sdk/zephyr-sdk*.run -- -d $PREBUILD/sdk -y
    fi
}

prepare_build
west config build.dir-fmt "$TOP/build_space/{app}/{board}"
