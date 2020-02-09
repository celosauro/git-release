# Release flow

- `develop` branches from `master`
- `release/*` should branches from `develop`
- `release/*` branch should merged in `master`, backwards `develop`

- check staged files to continue
- check if is in develop branch

- create realease 
    CHANGELOG alterado para a versão da release

- merge master in release
    `git merge --no-ff master`

- Open merge request release to merge in master


- tag version on master
    Tags 

- merge request release in develop