#!/usr/bin/env sh

reset

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
TARGET_BRANCH='develop'

checkHasUnmmergedFiles() {
    UNCOMMITED_CHANGES=$(git status -s | wc -l)

    if [ "$UNCOMMITED_CHANGES" -gt 0 ]; then
        echo ""
        echo "Working directory not clean. Aborting"
        exit 1
    fi
}

defineReleaseVersion() {
    echo ""
    echo "Insert the release version"
    read RELEASE_VERSION
    echo ""
    read -p "Are you sure you wish to continue the release $RELEASE_VERSION? [y/n] " CONFIRM
    if [ "$CONFIRM" != "y" ]; then
       exit 1
    fi
}

initMasterBranch() {
    echo ""
    echo "Checkout to master branch"
    git checkout master -q
    git pull origin master -q
}

initTargeBranch() {
    echo ""
    echo "Checkout to target branch: $TARGET_BRANCH"
    git checkout $TARGET_BRANCH -q
    git pull origin $TARGET_BRANCH -q
}

createReleaseBranch() {
    echo ""
    echo "Creating release branch"
    git checkout $TARGET_BRANCH -q
    git checkout -b release/$RELEASE_VERSION -q
}

mergeMasterInRelease() {
    echo ""
    echo "Merging master into release"
    git checkout release/$RELEASE_VERSION -q
    git merge master --no-ff -q
}

checkMergeConflicts() {
    CONFLICTS=$(git ls-files -u | wc -l)

    if [ "$CONFLICTS" -gt 0 ] ; then
        echo ""
        echo "There is a merge conflict. Aborting"
        git merge --abort -q
        exit 1
    fi
}

openMergeRequest() {
    echo ""
    echo "Opening merge request for release $RELEASE_VERSION"

    git push -u -q

    # xdg-open "https://gitlab.superlogica.com/pjbank---mensageiro/mensageiro/merge_requests/new?utf8=%E2%9C%93
    # &merge_request%5Bsource_project_id%5D=19
    # &merge_request%5Bsource_branch%5D=release/$RELEASE_VERSION
    # &merge_request%5Btarget_project_id%5D=19
    # &merge_request%5Btarget_branch%5D=$TARGET_BRANCH"

    xdg-open "https://github.com/marceloaas/teste/compare/$TARGET_BRANCH...release/$RELEASE_VERSION"
}

updatePackageVersion() {
    PACKAGE=$(node -p "JSON.stringify({...require('./package.json'), 'version': '$RELEASE_VERSION'}, null, 4)")
    echo $PACKAGE | python -m json.tool > package.json
}

createTag() {
    echo ""
    echo "Creating tag for new release"

    git checkout master

    PACKAGE_VERSION=$(cat package.json \
    | grep version \
    | head -1 \
    | awk -F: '{ print $2 }' \
    | sed 's/[",]//g' \
    | tr -d '[[:space:]]')
    echo $PACKAGE_VERSION

    git tag -a v$PACKAGE_VERSION -m "Bump version $PACKAGE_VERSION" -q
    git push --tags -q
    git push -q
}


# echo ""
# echo "Current branch: $CURRENT_BRANCH"
# echo ""
# echo "Updating from origin...x"
# git fetch origin -q

# checkHasUnmmergedFiles
defineReleaseVersion
packageVersion
# initMasterBranch
# initTargeBranch
# createReleaseBranch
# mergeMasterInRelease
# checkMergeConflicts
# openMergeRequest


exit;

