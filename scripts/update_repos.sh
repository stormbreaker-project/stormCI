#!/usr/bin/env bash

#
# Copyright (C) 2019 Saalim Quadri (danascape)
#
# SPDX-License-Identifier: Apache-2.0 license
#

# Set Variables
# Workspace Path
WORKSPACE_PATH="$HOME/workspace/artemis"

# Organization URL
ORG_URL="https://github.com/stormbreaker-project"

# Repositories
REPOS="
	linux-asus-x00p-3.18
	linux-asus-x01ad
	"

# Clone repositories
for repo in $REPOS; do
	cd $WORKSPACE_PATH/$repo
	git pull origin master
done
