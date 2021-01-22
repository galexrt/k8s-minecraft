#!/bin/bash

MC_VERSION="${MC_VERSION:-1.16}"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd "${DIR}" || exit 1

set -x

# Paper
PAPER_MC_VERSION=$(curl -sS --fail "https://papermc.io/api/v2/projects/paper/" | \
    jq -r '.versions | reverse | .[] | select(startswith("'"${MC_VERSION}"'"))' | head -n1)

PAPER_VERSION=$(curl -sS --fail "https://papermc.io/api/v2/projects/paper/versions/${PAPER_MC_VERSION}/" | \
    jq -r '.builds[-1]')

sed -i -r 's~^VERSION \?=.+$~VERSION ?= '"${PAPER_MC_VERSION}"'/'"${PAPER_VERSION}"'~' ../container/paper/Makefile

# Waterfall
WATERFALL_VERSION=$(curl -sS --fail "https://papermc.io/api/v2/projects/waterfall/versions/${MC_VERSION}/" | \
    jq -r '.builds[-1]')

sed -i -r 's~^VERSION \?=.+$~VERSION ?= '"${MC_VERSION}"'/'"${WATERFALL_VERSION}"'~' ../container/waterfall/Makefile
