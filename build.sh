#!/bin/bash
rm -rf public || exit 0;
mkdir public;
#instead of using general `hexo generate` method, use the following one to get compressed and combined files for publishing
hexo optimize;
if [ "$1" = "false" ]
# not a pull request, deploy to github pages
then
  DEPLOY_REF=$GH_REF
else
  DEPLOY_REF=$PREVIEW_GH_REF
fi

cd public
 git init
 git config user.name "tbfe"
 git config user.email "tbfe-ci@baidu.com"
 git add .
 git commit -m "Deployed to Github Pages [skip ci]"
 git push --force --quiet "https://${GH_TOKEN}@${GH_REF}" master:gh-pages
