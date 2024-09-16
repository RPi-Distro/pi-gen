#!/bin/bash -e

REQUEST_BUMP="$1"

setup_version() {
    if [ -f "/tmp/semver" ]; then
        return 0
    fi

    wget -q -O /tmp/semver \
    https://raw.githubusercontent.com/fsaintjacques/semver-tool/master/src/semver
    chmod +x /tmp/semver
}

update_version() {
    setup_version

    LAST_VERSION=${LAST_VERSION:-"$(git describe --tags --abbrev=0 --match="v[0-9].[0-9].[0-9]*")"}
    LAST_VERSION_HASH=${LAST_VERSION_HASH:-"$(git rev-parse "${LAST_VERSION}")"}$

    last_version="${LAST_VERSION}"
    # if hash of previous version matches current git hash, we don't update!
    if [ "${GIT_HASH}" == "${LAST_VERSION_HASH}" ]; then
        echo "Hash of previous version matches the current. So, we're not bumping. Create a new empty commit with the appropriate tag"
        echo "${last_version}"
        exit 0
    fi

    REQUEST_BUMP="$(echo "${REQUEST_BUMP}" | tr '[:upper:]' '[:lower:]')"
    case "${REQUEST_BUMP}" in
        break|major) is_breaking=1 ;;
        feat|minor) is_feature=1 ;;
        rc) is_rc=1 ;;
        patch) is_patch=1 ;;
        release) is_release=1 ;;
        dev) is_dev=1 ;;
    *)
        # Guess the bump from commit history
        commits="${COMMITS_FROM_LAST}"

        is_breaking="$(echo "${commits}" | awk '{ print $2; }' | { grep "BREAK:" || :; })"
        is_feature="$(echo "${commits}" | awk '{ print $2; }' | { grep "feat:" || :; })"
        is_rc="$(echo "${last_version}" | { grep -- "-rc" || :; })"
        is_dev="$(echo "${last_version}" | { grep -- "-dev" || :; })"
        ;;
    esac

    if [ -n "${is_breaking}" ]; then
        ver_bump="major"
    elif [ -n "${is_feature}" ]; then
        ver_bump="minor"
    elif [ -n "${is_rc}" ]; then
        ver_bump="prerel rc."
    elif [ -n "${is_dev}" ]; then
        ver_bump="prerel dev."
    elif [ -n "${is_release}" ]; then
        ver_bump="release"
    else
        ver_bump="patch"
    fi

    if [ -n "${is_release}" ]; then
        # removes pre-release versioning
        # e.g. v3.0.0-rc1 to v3.0.0 or v3.0.0-dev1 to v3.0.0
        new_version=$(/tmp/semver get release "${last_version}")
    else
        # Update version according to commit history
        new_version=$(/tmp/semver bump ${ver_bump} "${last_version}")

        # Add -rc to the new version code
        if [ -n "${is_rc}" ] && [ "${ver_bump}" != "prerel rc." ]; then
            new_version=$(/tmp/semver bump ${ver_bump} "${new_version}")
        fi

        # Add -dev to the new version code
        if [ -n "${is_dev}" ] && [ "${ver_bump}" != "prerel dev." ]; then
            new_version=$(/tmp/semver bump ${ver_bump} "${new_version}")
        fi
    fi

    echo "v${new_version}"
}

update_version
