#!/usr/bin/env bash

#
# Copyright (C) 2019 Saalim Quadri (danascape)
#
# SPDX-License-Identifier: Apache-2.0 license
#

# Set Variables
# Compile Time
KBUILD_BUILD_HOST="Stormbot"
KBUILD_BUILD_USER="StormCI"

# Device List
DEVICE="X00P X01AD"

# Workspace Path
WORKSPACE_PATH="$HOME/workspace/artemis"

fetch-commit-id() {
    echo "Checking commit-id of $DEVICE"
    echo "Fetching remote information of the device"
    COMMIT_ID_FETCH=$(git ls-remote https://github.com/stormbreaker-project/$DEVICE | head -1 | cut -f -1)
    if [[ $COMMIT_ID_FETCH == "" ]]; then
        echo "Warning: Fetched commit id is empty!"
        echo "Did you enter the correct device name?"
    else
        compare-commit-id
    fi
}

compare-commit-id() {
    if [[ -f commit-id/$DEVICE-id ]]; then
		PREVIOUS_COMMIT_ID=$(cat commit-id/$DEVICE-id)
        rm commit-id/$DEVICE-id
        if [[ $PREVIOUS_COMMIT_ID == "" ]]; then
            echo ""
            echo "Warning: The cached commit-id is empty"
            echo "Did something went wrong?"
            echo "Removing the saved commit-id"
            echo ""
            rm commit-id/$DEVICE-id
        elif [ $COMMIT_ID_FETCH = $PREVIOUS_COMMIT_ID ]; then
            echo ""
            echo "No need to trigger the build"
            echo "If this is your first time triggering for a device"
            echo "Kindly push a commit to your kernel source."
            echo ""
        else
            echo ""
            echo "Triggering the build for $DEVICE"
            echo "$COMMIT_ID_FETCH" >> commit-id/$DEVICE-id
            set_build_variables
	    fi
    else
        echo ""
        echo "Warning: No previous configuration Found!"
        echo "Kindly push a commit to your kernel source."
        echo "Re-trigger the script after this step."
        echo "This is added to ensure no issues in script arguments."
        echo ""
        echo "$COMMIT_ID_FETCH" >> commit-id/$DEVICE-id
	fi
}

# Set repository variables
# This is done to ensure the above functions are executed.
set_build_variables() {
    CURRENT_DIR=$(pwd)
    DEVICE_DIR=$CURRENT_DIR/$DEVICE
    BUILD_DIR=$DEVICE_DIR
    clone_device
}

kernelVersion() {
    KERNEL_VERSION="$( cat $DEVICE/Makefile | grep VERSION | head -n 1 | sed "s|.*=||1" | sed "s| ||g" )"
    KERNEL_PATCHLEVEL="$( cat $DEVICE/Makefile | grep PATCHLEVEL | head -n 1 | sed "s|.*=||1" | sed "s| ||g" )"
    VERSION="${KERNEL_VERSION}.${KERNEL_PATCHLEVEL}"
    echo $VERSION
}

buildFail() {
    BUILD_FAIL=true
    setStatus
    genJSON
}

buildPass() {
    BUILD_PASS=true
    setStatus
    genJSON
}

setStatus() {
    if [[ "$BUILD_FAIL" == "true" ]]; then
        STATUS="Failed"
    elif [[ "$BUILD_PASS" == "true" ]]; then
        STATUS="Passing"
    else
        STATUS="Undefined"
    fi
}

genJSON() {
    END=$(date +"%s")
    DIFF=$(($END - $START))
    echo $DIFF
    echo "Generating JSON"
    BRANCH="main" # Default branch of the repositories
    # TIME="$((SECONDS / 60)) minute(s) and $((SECONDS % 60)) second(s)"
    TIME="$DIFF seconds"
    COMMIT_ID=$(git log --oneline -1 | cut -f 1 -d " ")
    MESSAGE=$(git log --format=%B -n 1 HEAD)
    COMPILER_VERSION=$(${TC_DIR}/clang/bin/clang --version | head -n 1 | cut -f6,8 -d " ")
    GEN_JSON_BODY=$(jq --null-input \
                    --arg device "$DEVICE" \
                    --arg branch "$BRANCH" \
                    --arg status "$STATUS" \
                    --arg build "$TIME" \
                    --arg commit "$COMMIT_ID" \
                    --arg message "$MESSAGE" \
                    --arg compiler "$COMPILER_VERSION" \
                    "{"device": \"$DEVICE\", "branch": \"$BRANCH\", "status": \"$STATUS\", "time": \"$TIME\", "commit": \"$COMMIT_ID\", "messsage": \"$MESSAGE\", "compiler": \"$COMPILER_VERSION\"}")
    echo $GEN_JSON_BODY
    cd $CURRENT_DIR
    if [[ -f json/$DEVICE.json ]]; then
        rm json/$DEVICE.json
    fi
    echo "$GEN_JSON_BODY" >> json/$DEVICE.json
    exit 0
}

triggerBuild() {
    echo "Starting Build"
    START=$(date +"%s")
    for device in $DEVICE; do
	    cd $WORKSPACE_PATH/linux*$device*
	    sw b $device
    done
}

triggerBuild
