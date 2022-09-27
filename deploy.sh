#!/bin/bash

PM_FILE="Koha/Plugin/Fi/KohaSuomi/VisualLabelTool.pm"
VERSION=`grep -oE "\-?[0-9]+\.[0-9]+\.[0-9]" $PM_FILE | head -1`
MINVERSION=`grep -oE "\-?[0-9]+\.[0-9][0-9]" $PM_FILE | head -1`
RELEASE_FILE="koha-plugin-visual-label-tool-v${VERSION}.kpz"
VERSIONTAG=`git tag -l "v${VERSION}-koha-$MINVERSION"`

if [ $VERSIONTAG ]; then
    echo "Release version already exists!"
    exit 1
fi

rm $RELEASE_FILE

echo "Building release package ${RELEASE_FILE}"

zip -r $RELEASE_FILE ./Koha

echo "Creating tag v${VERSION}-koha-$MINVERSION"

git tag -a "v${VERSION}-koha-$MINVERSION" -m "Release ${VERSION}"