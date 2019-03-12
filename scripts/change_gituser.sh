#!/bin/bash


email="$1"
name="$2"

git config user.email "${email}"
git config user.name "${name}"
