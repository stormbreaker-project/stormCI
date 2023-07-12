#!/usr/bin/env bash

#
# Copyright (C) 2019 Saalim Quadri (danascape)
#
# SPDX-License-Identifier: Apache-2.0 license
#

# Set Variables
# Scripts Path
CI_PATH="$HOME/stormCI"

jq -s '.' $(cat $CI_PATH/json-files) > $CI_PATH/json/devices.json
