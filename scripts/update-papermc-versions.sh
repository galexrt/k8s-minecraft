#!/bin/bash

export IS_CI="${IS_CI:-false}"

MC_VERSION="${MC_VERSION:-1.18}"

VERSION_CHANGED="false"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd "${DIR}" || exit 1

# Paper
PAPER_MC_VERSION=$(curl -sS --fail "https://papermc.io/api/v2/projects/paper/" | \
    jq -r '.versions | reverse | .[] | select(startswith("'"${MC_VERSION}"'"))' | head -n1)

PAPER_VERSION=$(curl -sS --fail "https://papermc.io/api/v2/projects/paper/versions/${PAPER_MC_VERSION}/" | \
    jq -r '.builds[-1]')

if ! grep -q "${PAPER_MC_VERSION}/${PAPER_VERSION}" ../container/paper/Makefile; then
    VERSION_CHANGED="true"
    echo "Updating Paper MC version to ${PAPER_MC_VERSION}/${PAPER_VERSION}"
    sed -i -r 's~^VERSION \?=.+$~VERSION ?= '"${PAPER_MC_VERSION}"'/'"${PAPER_VERSION}"'~' ../container/paper/Makefile
    git add ../container/paper/Makefile
    git commit -m "container: update paper to ${PAPER_MC_VERSION}/${PAPER_VERSION}"
fi

# Waterfall
WATERFALL_VERSION=$(curl -sS --fail "https://papermc.io/api/v2/projects/waterfall/versions/${MC_VERSION}/" | \
    jq -r '.builds[-1]')

if ! grep -q "${MC_VERSION}/${WATERFALL_VERSION}" ../container/waterfall/Makefile; then
    VERSION_CHANGED="true"
    echo "Updating Waterfall version to ${MC_VERSION}/${WATERFALL_VERSION}"
    sed -i -r 's~^VERSION \?=.+$~VERSION ?= '"${MC_VERSION}"'/'"${WATERFALL_VERSION}"'~' ../container/waterfall/Makefile
    git add ../container/waterfall/Makefile
    git commit -m "container: update waterfall to ${MC_VERSION}/${WATERFALL_VERSION}"
fi

git push

# Start an image build and push, when "need to build images" because a version has been changed
if [ "${VERSION_CHANGED}" = "true" ] && [ "${IS_CI}" = "true" ]; then
    echo "Starting image build and push because we need to build images"
    make -C ../container/ build push BUILDAH_LAYERS=false
fi
