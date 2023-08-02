#!/bin/bash
set -e
set -x

if [ $# -lt 1 ]; then
  echo usage: $0 osx  [osx, linux, windows]
  exit 1
fi
if [ $1 == 'osx' ]; then
  platform='darwin-x86_64'
elif [ $1 == 'linux' ]; then
  platform='linux-x86_64'
elif [ $1 == 'windows' ]; then
  platform='windows-x86_64'
else
  echo usage: $0 osx  [osx, linux, windows]
  exit 1
fi

version='1.3.1'
plugin='/usr/local/bin/protoc-gen-grpc-web'
rm -f $plugin
curl -L https://github.com/grpc/grpc-web/releases/download/$version/protoc-gen-grpc-web-$version-$platform -o $plugin
chmod +x $plugin

out=./src
rm -rf $out
mkdir $out

# Is your protoc a broken release?
# brew install protobuf@3
# brew link --overwrite protobuf@3
# https://github.com/protocolbuffers/protobuf-javascript/issues/127#issuecomment-1204202844

# The `--js_out` plugin will generate JavaScript code (`echo_pb.js`), and the
# `-grpc-web_out` plugin will generate a TypeScript definition file for it
# (`echo_pb.d.ts`). This is a temporary hack until the `--js_out` supports
# TypeScript itself. See https://github.com/grpc/grpc-web/blob/7c528784576abbbfd05eb6085abb8c319d76ab05/README.md?plain=1#L246

# Ramya: Changed js mode to strict. The web SDK will build but unit tests and integ tests fail with 
# ```
# Test suite failed to run
#    TypeError: Cannot read properties of undefined (reading 'Never')
#
#       7 | } from '@gomomento/generated-types-webtext/dist/auth_pb';
#       8 | import {cacheServiceErrorMapper} from '../errors/cache-service-error-mapper';
#    >  9 | import Never = _GenerateApiTokenRequest.Never;
#         |                                         ^
#      10 | import Expires = _GenerateApiTokenRequest.Expires;
#      11 | import {
#      12 |   CredentialProvider,

#      at Object.<anonymous> (src/internal/auth-client.ts:9:41)
#      at Object.<anonymous> (src/auth-client.ts:5:1)
#      at Object.<anonymous> (src/index.ts:2:1)
#      at Object.<anonymous> (test/integration/integration-setup.ts:13:1)
#      at Object.<anonymous> (test/integration/shared/auth-client.test.ts:2:1)
# ```

# Ramya: Tried with latest protoc-gen-js plugin from the new google repository for protobuf-javascript with same results.
# protoc --plugin=protoc-gen-js=/Users/Ramya/Work/protobuf-javascript/bazel-bin/generator/protoc-gen-js -I=../proto -I=/usr/local/include \
#  --js_out=import_style=commonjs_strict:$out \
#  extensions.proto cacheclient.proto controlclient.proto auth.proto cacheping.proto cachepubsub.proto

protoc --plugin=protoc-gen-js=/Users/Ramya/Work/protobuf-javascript/bazel-bin/generator/protoc-gen-js -I=../proto -I=/usr/local/include \
  --js_out=import_style=commonjs_strict:$out \
  extensions.proto cacheclient.proto controlclient.proto auth.proto cacheping.proto cachepubsub.proto

protoc -I=../proto -I=/usr/local/include \
  --grpc-web_out=import_style=typescript,mode=grpcwebtext:$out \
  extensions.proto cacheclient.proto controlclient.proto auth.proto cacheping.proto cachepubsub.proto
