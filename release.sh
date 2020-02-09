#!/usr/bin/env sh

reset

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
TARGET_BRANCH='develop'

checkHasUnmmergedFiles() {
    UNCOMMITED_CHANGES=$(git status -s | wc -l)

    if [ "$UNCOMMITED_CHANGES" -gt 0 ]; then
        echo "Working directory not clean. Aborting"
        exit 1
    fi
}

defineReleaseVersion() {
    echo "Insert the release version"
    read RELEASE_VERSION
    read -p "Are you sure you wish to continue the release $RELEASE_VERSION?" CONFIRM
    if [ "$CONFIRM" != "yes" || "$CONFIRM" != "y" ]; then
       exit 1
    fi
}

initMasterBranch() {
    echo "Checkout to master branch"
    git checkout master
    git pull origin master
}

initTargeBranch() {
    echo "Checkout to target branch: $TARGET_BRANCH"
    git checkout $TARGET_BRANCH
    git pull origin $TARGET_BRANCH
}

createReleaseBranch() {
    echo "Creating release branch"
    git checkout $TARGET_BRANCH
    git checkout -b release/$RELEASE_VERSION
}

mergeMasterInRelease() {
    echo "Merging master into release"
    git checkout release/$RELEASE_VERSION
    git merge master --no-ff
}

checkMergeConflicts() {
    CONFLICTS=$(git ls-files -u | wc -l)

    if [ "$CONFLICTS" -gt 0 ] ; then
        echo "There is a merge conflict. Aborting"
        git merge --abort
        exit 1
    fi
}

createTag() {
    # git tag -a v1.0.3 -m "My version 1.0.3"
    # echo "committing"
    # git push --tags
    # git push
    echo "createTag"
}

openMergeRequest() {
    echo "Opening merge request for release $RELEASE_VERSION"
    # xdg-open "https://gitlab.superlogica.com/pjbank---mensageiro/mensageiro/merge_requests/new?utf8=%E2%9C%93
    # &merge_request%5Bsource_project_id%5D=19
    # &merge_request%5Bsource_branch%5D=$RELEASE_BRANCH
    # &merge_request%5Btarget_project_id%5D=19
    # &merge_request%5Btarget_branch%5D=$TARGET_BRANCH"

    xdg-open "https://github.com/marceloaas/teste/compare/$TARGET_BRANCH...$RELEASE_BRANCH"

}

packageVersion() {

    PACKAGE_VERSION=$(cat package.json \
    | grep version \
    | head -1 \
    | awk -F: '{ print $2 }' \
    | sed 's/[",]//g' \
    | tr -d '[[:space:]]')

    echo $PACKAGE_VERSION

    # CURRENT_VERSION=$(node -p "require('./package.json').version")

    echo $CURRENT_VERSION

    PACKAGE=$(node -p "JSON.stringify({...require('./package.json'), 'version': 'value41'}, null, 4)")

    echo $PACKAGE | python -m json.tool > package.json
    # echo $PACKAGE > package.json
    #  && git tag $PACKAGE_VERSION && git push --tags
    # git branch -u origin/<branch-name>


}


echo "Current branch: $CURRENT_BRANCH"
echo "Updating from origin...x"
# git fetch origin

checkHasUnmmergedFiles
defineReleaseVersion
initMasterBranch
initTargeBranch
createReleaseBranch
checkMergeConflicts
openMergeRequest


exit;

