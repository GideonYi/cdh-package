#!/bin/sh
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -ex

usage() {
  echo "
usage: $0 <options>
  Required not-so-options:
     --build-dir=DIR             path to flumedist.dir
     --prefix=PREFIX             path to install into

  Optional options:
     --doc-dir=DIR               path to install docs into [/usr/share/doc/flume]
     --flume-dir=DIR             path to install flume home [/usr/lib/flume]
     --installed-lib-dir=DIR     path where lib-dir will end up on target system
     ... [ see source for more similar options ]
  "
  exit 1
}

OPTS=$(getopt \
  -n $0 \
  -o '' \
  -l 'prefix:' \
  -l 'doc-dir:' \
  -l 'doc-dir-prefix:' \
  -l 'flume-dir:' \
  -l 'installed-lib-dir:' \
  -l 'build-dir:' -- "$@")

if [ $? != 0 ] ; then
    usage
fi

eval set -- "$OPTS"

while true ; do
    case "$1" in
        --prefix)
        PREFIX=$2 ; shift 2
        ;;
        --build-dir)
        BUILD_DIR=$2 ; shift 2
        ;;
        --doc-dir)
        DOC_DIR=$2 ; shift 2
        ;;
        --doc-dir-prefix)
        DOC_DIR_PREFIX=$2 ; shift 2
        ;;
        --flume-dir)
        FLUME_DIR=$2 ; shift 2
        ;;
        --installed-lib-dir)
        INSTALLED_LIB_DIR=$2 ; shift 2
        ;;
        --)
        shift ; break
        ;;
        *)
        echo "Unknown option: $1"
        usage
        exit 1
        ;;
    esac
done

for var in PREFIX BUILD_DIR ; do
  if [ -z "$(eval "echo \$$var")" ]; then
    echo Missing param: $var
    usage
  fi
done

MAN_DIR=${MAN_DIR:-/usr/share/man/man1}
DOC_DIR=${DOC_DIR:-/usr/share/doc/flume-ng}
DOC_DIR_PREFIX=${DOC_DIR_PREFIX:-$PREFIX}
FLUME_DIR=${FLUME_DIR:-/usr/lib/flume-ng}
CONF_DIR=/etc/flume-ng/
CONF_DIST_DIR=/etc/flume-ng/conf.dist/
ETC_DIR=${ETC_DIR:-/etc/flume-ng}

# Plugin jars
install -d -m 0755 ${PREFIX}/${FLUME_DIR}/lib
cp ${BUILD_DIR}/flume-indexer/target/flume-ng-solr-*.jar ${PREFIX}/${FLUME_DIR}/lib
cp ${BUILD_DIR}/flume-indexer/target/lib/*.jar ${PREFIX}/${FLUME_DIR}/lib
(cd ${PREFIX}/${FLUME_DIR}/lib ; rm -f *-tests.jar `ls flume-ng-*jar | grep -v flume-ng-solr`)

# Sample (twitter) configs
install -d -m 0755 ${PREFIX}/${CONF_DIST_DIR}
cp ${BUILD_DIR}/examples/src/test/resources/twitter-flume.conf       ${PREFIX}/${CONF_DIST_DIR}
cp ${BUILD_DIR}/core-indexer/src/test/resources/tika-config.xml     ${PREFIX}/${CONF_DIST_DIR} 
cp -r ${BUILD_DIR}/core-indexer/src/test/resources/solr/collection1 ${PREFIX}/${CONF_DIST_DIR}
# FIXME: get org/apache/tika/mime/custom-mimetypes.xml onto classpath
cp -r ${BUILD_DIR}/core-indexer/src/test/resources/org              ${PREFIX}/${CONF_DIST_DIR}

# Cloudera specific
#install -d -m 0755 $PREFIX/$FLUME_DIR/cloudera
#cp cloudera/cdh_version.properties $PREFIX/$FLUME_DIR/cloudera/