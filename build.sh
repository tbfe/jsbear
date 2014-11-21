#!/bin/bash
rm -rf public || exit 0;
mkdir public;
hexo generate;
if [ "$1" = "false" ] 
# not a pull request, deploy to github pages
then ( cd public
 git init
 git config user.name "tbfe"
 git config user.email "tbfe-ci@baidu.com"
 git add .
 git commit -m "Deployed to Github Pages [skip ci]"
 git push --force --quiet "https://${GH_TOKEN}@${GH_REF}" master:gh-pages
)
fi
