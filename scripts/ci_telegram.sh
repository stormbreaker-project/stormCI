#!/usr/bin/env bash

#
# Copyright (C) 2019 Saalim Quadri (danascape)
#
# SPDX-License-Identifier: Apache-2.0 license
#

# Set Variables
# Scripts Path
CI_PATH="$HOME/stormCI"

# Call telegram config
. "$CI_PATH"/telegram.config --source-only

# Set tg var.
function sendTG() {
	curl -s "https://api.telegram.org/bot$API_KEY/sendmessage" --data "text=${*}&chat_id="$CHAT_ID"&parse_mode=HTML" >/dev/null
}

sendTG "Hello"
