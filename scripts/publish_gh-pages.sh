#!/bin/bash

echo "start publish gh-pages"

cd ./_site

echo "nim-cn.com" > CNAME


# copy docs
mkdir docs

cp ../../rst/*.html ./docs


# publish to gh-pages
git init

git config user.name "DongyunLee"
git config user.email "dongyunli619@gmail.com"

git add .
git commit -m "Update"

git push --force --quiet "https://${GH_TOKEN}@github.com/nim-lang-cn/website.git" master:gh-pages