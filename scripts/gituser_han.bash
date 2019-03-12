#!/bin/bash

# 10 hours keep my password
git config --global credential.helper 'cache --timeout=360000'

git config user.email "jeonghan.lee@gmail.com"
git config user.name "Jeong Han Lee"
