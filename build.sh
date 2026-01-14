#!/bin/bash
version="2.1.4"

# Inputs:
#   1: Base layer
#   2: Output Prefix
#   3: Output Suffix
#   4: Skip file match
#   5: Remove from original name
#   6: Output Folder
overlay_on() {
    for file in ../textures/ore_overlays/*; do
        file_basename=$(basename "$file")

        if [[ "$4" != "" ]] && [[ $file_basename == *"$4"* ]]; then
            continue
        fi

        file_basename=${file_basename//"$5"/}
        magick "$1" "$file" -strip -gravity center -composite\
            -define png:compression-filter=4\
            -define png:compression-level=9\
            -define png:compression-strategy=2 PNG8:"$6/$2${file_basename%.*}_ore$3.png"

        pngquant --force --strip --speed 1 --skip-if-larger\
            --output "$6/$2${file_basename%.*}_ore$3.png"\
            "$6/$2${file_basename%.*}_ore$3.png"
    done
}

# Inputs:
#   1: Input file path
#   2: Output directory
compress_json() {
    file_basename=$(basename "$1")
    jq -c < "$1" > "$2$file_basename"
}

currentdir=$(pwd)

mkdir -p ./build/
cd ./build/ || exit 1

echo -e "---\nBuilding Java"

# Create Java directory structure
mkdir -p ./java/assets/minecraft/models/block/
mkdir -p ./java/assets/minecraft/textures/block/

echo "Copying Java metafiles"
cp "../src/pack.mcmeta" "./java/pack.mcmeta"
cp "../src/pack.png" "./java/pack.png"

echo "Copying block models"
for file in ../src/models/*; do
    compress_json "$file" "./java/assets/minecraft/models/block/"
done

echo "Overlaying textures"
overlay_on "../textures/stones/ore_stone.png" "" "" "coal_deepslate.png" "" "./java/assets/minecraft/textures/block/"
overlay_on "../textures/stones/deepslate.png" "deepslate_" "" "coal.png" "_deepslate" "./java/assets/minecraft/textures/block/"
overlay_on "../textures/stones/deepslate_top.png" "deepslate_" "_top" "coal.png" "_deepslate" "./java/assets/minecraft/textures/block/"

echo "Packaging to \"Old.Ores.$version-Java.zip\""
rm "Old.Ores.$version-Java.zip" 2> /dev/null
7z a -mx9 -tzip "Old.Ores.$version-Java.zip" -w ./java/* > /dev/null

echo -e "\n---\nBuilding Bedrock"

# Create Bedrock directory structure
mkdir -p ./bedrock/textures/blocks/deepslate/

echo "Copying Bedrock metafiles"
cp "../src/manifest.json" "./bedrock/manifest.json"
cp "../src/pack_icon.png" "./bedrock/pack_icon.png"

echo "Overlaying textures"
overlay_on "../textures/stones/ore_stone.png" "" "" "coal_deepslate.png" "" "./bedrock/textures/blocks/"
overlay_on "../textures/stones/deepslate.png" "deepslate_" "" "coal.png" "_deepslate" "./bedrock/textures/blocks/deepslate/"

echo "Packaging to \"Old.Ores.$version-Bedrock.mcpack\""
rm "Old.Ores.$version-Bedrock.mcpack" 2> /dev/null
7z a -tzip "Old.Ores.$version-Bedrock.mcpack" -w ./bedrock/* > /dev/null

cd "$currentdir" || exit 1
