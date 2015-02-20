#!/bin/bash

# by default use fsc, or fsharpc
if [ -z "$FSC" ]; then
    if command -v fsc >/dev/null 2>&1; then
        FSC=fsc
    elif command -v fsharpc >/dev/null 2>&1; then
        FSC=fsharpc
    else
        echo "No FSharp compiler found!"
        exit 1
    fi
fi

# exit on error and don't allow the use of unset variables
set -o errexit
set -o nounset
set -x

# build and run special purpose tool for generating LLVM C bindings
fslex --unicode bindinggen/Lexer.fsl
fsyacc --module FSExternHelper.Parser bindinggen/Parser.fsy
${FSC} --nologo \
    bindinggen/Lexing.fs \
    bindinggen/Parsing.fs \
    bindinggen/HeaderSyntax.fs \
    bindinggen/Parser.fs \
    bindinggen/Lexer.fs \
    bindinggen/bindinggen.fs

# see if mono exists in the path. if not assume we're on windows and can
# run bindinggen.exe directly
if hash mono &> /dev/null; then
    #mono bindinggen.exe ~/bin/llvm-3.1 src/LLVM/Generated.fs
    mono bindinggen.exe ~/projects/third-party/llvm-git src/LLVM/Generated.fs
else
    bindinggen.exe LLVM-3.1.dll C:\\Users\\keith\\Desktop\\projects\\llvm-3.1 src\\LLVM\\Generated.fs
fi

