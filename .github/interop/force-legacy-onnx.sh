#!/bin/bash
# don't have cmake even check for another onnx
sed -i '68,72 {s|^|#|}' ldmx-sw/cmake/FindONNXRuntime.cmake
