#!/bin/bash
# don't build ldmx-sw tests by commenting out the build_test call
sed -i 's|build_test()|#build_test()|' ldmx-sw/CMakeLists.txt
