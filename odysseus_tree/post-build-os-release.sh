#!/bin/bash

FILE="$TARGET_DIR/etc/os-release-ody"

# if file exists, clear it
if test -f "$FILE";
then
   rm "$FILE" 
fi

# ensure file exists
touch "$FILE" || exit

# push a param to FILE, first arg is name second is value
push_param() {
    cat <<< "$1=$2" >> "$FILE"
}

# change dirs for fetching git info
cd "$BR2_EXTERNAL_ODY_TREE_PATH"/../githistory/ || exit
# hacky way to allow portable git file to work
git config --global --add safe.directory $PWD

# https://www.freedesktop.org/software/systemd/man/latest/os-release.html#General%20information%20identifying%20the%20operating%20system
push_param "NAME" "NER Odysseus"
push_param "ID" "odysseus"
push_param "ID_LIKE" "buildroot"
push_param "PRETTY_NAME" "NER Odysseus v$(git describe --tags $(git rev-list --tags --max-count=1))"
# 2nd argument into this file is the name of the defconfig
if [[ "$2" == "TPU" ]]; 
then
    variant="Built for Telemetry Processing Unit"
    variantid="tpu"
elif [[ "$2" == "AP" ]]; 
then
    variant="Built for HaLow Access Point"
    variantid="ap"

elif [[ "$2" == "IROH" ]]; 
then
    variant="Built for Iroh Charging Scraper"
    variant="iroh"
else
    variant="UK"
    variantid="uk"
fi

push_param "VARIANT" "$variant"
push_param "VARIANT_ID" "$variantid"

# https://www.freedesktop.org/software/systemd/man/latest/os-release.html#Information%20about%20the%20version%20of%20the%20operating%20system
push_param "VERSION" "$(git describe --tags $(git rev-list --tags --max-count=1))" # latest tag
push_param "VERSION_ID" "$(git describe --tags $(git rev-list --tags --max-count=1))"
# VERSION_CODENAME unimplemented

push_param "BUILD_ID" "$(date +"%Y-%m-%dT%H:%M:%S%z")" # time of build finish
push_param "IMAGE_ID" "$(git rev-parse --abbrev-ref HEAD)" # branch name
push_param "IMAGE_VERSION" "$(git rev-parse HEAD)" # current sha

# https://www.freedesktop.org/software/systemd/man/latest/os-release.html#Presentation%20information%20and%20links
push_param "HOME_URL" "https://github.com/Northeastern-Electric-Racing/Odysseus"
push_param "VENDOR_NAME" "Northeastern Electric Racing"
