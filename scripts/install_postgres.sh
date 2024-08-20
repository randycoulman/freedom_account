#!/usr/bin/env bash

set -euo pipefail

if [ $# -eq 0 ]; then
    echo "Usage: $0 <postgres_version>"
fi

export OPENSSL_PATH=$(brew --prefix openssl)
export CMAKE_PREFIX_PATH=$(brew --prefix icu4c)
export PATH="$OPENSSL_PATH/bin:$CMAKE_PREFIX_PATH/bin:$PATH"
export LDFLAGS="-L$OPENSSL_PATH/lib"
export CPPFLAGS="-I$OPENSSL_PATH/include"
export PKG_CONFIG_PATH="$CMAKE_PREFIX_PATH/lib/pkgconfig"

asdf install postgres $1
