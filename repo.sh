#!/bin/bash

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 package.deb /path/to/git/repository" >&2
  exit 1
fi

DEB="${1}"
DIR="${2}"

set -ex

# remove old files
FILES=$(find "${DIR}" -mindepth 1 -maxdepth 1 | grep -v .git || true)
if [[ -n "$FILES" ]]; then
for I in ${FILES}; do
  echo "removing ${I}"
  rm -rf "${I}"
done
fi

# get version
VERSION=$(dpkg-deb --show "${DEB}" | tr '\t' ' ')
VER=$(echo "${VERSION}" | cut -d' ' -f2 | cut -d':' -f2)
echo "extracting ${DEB}: version ${VERSION}, short ${VER}"

# extract new version
dpkg-deb -R "${DEB}" "${DIR}"

# extract timestamp and author
CONTROL_DATE=$(stat -c '%y' "${DIR}/DEBIAN/control")
AUTHOR=$(cat "${DIR}/DEBIAN/control" | grep -oP 'Maintainer: \K.+')
# build author name from email if only email is entered
if [[ $AUTHOR != *"<"* ]]; then
  U=$(echo "${AUTHOR}" | cut -d'@' -f 1)
  AUTHOR="${U} <${AUTHOR}>"
fi
# broken author name
if [[ $AUTHOR == "<@b412b81cde18>" ]]; then
  AUTHOR="@b412b81cde18 <b412b81cde18@example.com>"
fi
echo "created on ${CONTROL_DATE} by ${AUTHOR}"

# read -rsp $'Press any key to continue...\n' -n1 key

# commit
(
  cd "${DIR}";
  git add -A;
  GIT_AUTHOR_DATE="${CONTROL_DATE}" git commit --author "${AUTHOR}" -m "${VERSION}";
  COMMIT=$(git rev-parse HEAD)
  git tag "${VER}" "${COMMIT}"
)

