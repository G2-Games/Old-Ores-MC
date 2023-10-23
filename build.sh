version="2.1.2"
currentdir=$(pwd)

mkdir -p build/

cd build/ || exit 1

rm *
exa -lh

7z a -tzip "Old.Ores.$version-Java.zip" ../Java/*
7z a -tzip "Old.Ores.$version-Bedrock.mcpack" ../Bedrock/*

cd "$currentdir" || exit 1
