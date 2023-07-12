#!/usr/bin/env bash

#
# Copyright (C) 2019 Saalim Quadri (danascape)
#
# SPDX-License-Identifier: Apache-2.0 license
#

# Set Variables
# Workspace Path
WORKSPACE_PATH="$HOME/builds"

# Organization URL
ORG_URL="https://github.com/stormbreaker-project"

# Repositories
REPOS="
	linux-asus-X00P-3.18
	linux-asus-X01AD
	linux-oneplus-billie
	"

# Clean up old repositories
rm -rf $WORKSPACE_PATH/*

# Clone repositories
for repo in $REPOS; do
    git clone --depth 1 -b master $ORG_URL/$repo $WORKSPACE_PATH/$repo
done
