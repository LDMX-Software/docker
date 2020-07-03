
set -e

# make working directory
mkdir -p $ONNX_DIR

# download pre-compiled binaries
wget https://github.com/microsoft/onnxruntime/releases/download/v${ONNX}/onnxruntime-linux-x64-${ONNX}.tgz

# unpack the pre-compiled binaries
#   the arguments after the archive basically rename
#   the root directory in the archive to the simpler '$ONNX_DIR'
tar -zxvf onnxruntime*.tgz -C $ONNX_DIR --strip-components 1

# clean up before saving this layer
rm onnxruntime*.tgz
