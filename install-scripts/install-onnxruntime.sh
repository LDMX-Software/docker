
set -e

# make working directory
mkdir -p $ONNX_DIR

# download pre-compiled binaries
wget https://github.com/microsoft/onnxruntime/releases/download/v1.3.0/onnxruntime-linux-x64-1.3.0.tgz

# unpack the pre-compiled binaries
#   the arguments after the archive basically rename
#   the root directory in the archive to the simpler '$ONNX_DIR'
tar -zxvf onnxruntime-linux-x64-1.3.0.tgz -C $ONNX_DIR --strip-components 1

# delete tar ball
rm onnxruntime-linux-x64-1.3.0.tgz
