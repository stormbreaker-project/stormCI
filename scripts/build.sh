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

# Scripts Path
CI_PATH="$HOME/stormCI"

# Workspace Path
WORKSPACE_PATH="$HOME/builds"

# Organization URL
ORG_URL="https://github.com/stormbreaker-project"

# Repositories
REPOS="
	linux-asus-X00P-3.18
	linux-asus-X01AD
	"

compare_commit_id() {
    echo "Checking commit-id of $DEVICE"
    echo "Fetching remote information of the device"
    for repo in $REPOS; do
	    COMMIT_ID=$(git ls-remote $ORG_URL/$repo | head -1 | cut -f -1)
	    if [[ $COMMIT_ID == "" ]]; then
		    echo "Warning: Fetched commit id is empty!"
		    echo "Did you enter the correct device name?"
	    else
		    PREVIOUS_COMMIT_ID=$(cat $CI_PATH/commit-id/$repo-id)
		    if [[ $PREVIOUS_COMMIT_ID == "" ]]; then
			    echo ""
			    echo "Warning: The cached commit-id is empty"
			    echo "Warning: Contact admin to generate the id"
		    elif [[ $COMMIT_ID = $PREVIOUS_COMMIT_ID ]]; then
			    echo ""
			    echo "Warning: No need to trigger the build"
			    echo "Warning: Check CI page to find builds"
			    echo ""
		    else
			    DEVICE=$(echo $repo | cut -d'-' -f3)
			    echo "Triggering build for $DEVICE"
			    triggerBuild $DEVICE
		    fi
		    
	    fi
    done
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
	local device=$1
    echo "Starting Build"
    START=$(date +"%s")
	    cd $WORKSPACE_PATH/linux*$device*
	    sw b $device
}

compare_commit_id
