
# download.sh

# Copyright 2022 Timothy Oliver. All rights reserved.

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
# IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

VERSION="v1.2.1"
FRAMEWORK="WebP.xcframework"
URL="https://github.com/TimOliver/WebP-Cocoa/releases/download/${VERSION}/libwebp-${VERSION}-framework-ios-webp.zip"
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
CURRENT_DIR=$(pwd)

# Jump to where the script is located
cd ${SCRIPT_DIR}

# If it doesn't exist, download and extract the precompiled libwebp XCFramework
if [ ! "$(ls $FRAMEWORK)" ]; then
    curl -L -sS ${URL} > framework.zip
    unzip framework.zip
    cp -a libwebp*/${FRAMEWORK}/. ${FRAMEWORK}/
    rm -r libwebp*/
    rm framework.zip
fi

# Return to the original execution place
cd ${CURRENT_DIR}