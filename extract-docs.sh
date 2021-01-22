#!/usr/bin/env bash

# Copyright 2019 British Broadcasting Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -o errexit
shopt -s extglob globstar nullglob

PATH=$PWD/.scripts:$PWD/node_modules/.bin:$PATH

. get-config.sh

function extract {
    checkout=$1
    target_dir=$2
    echo "Extracting $checkout into $target_dir"
    mkdir "$target_dir"

    (
        cd source-repo || exit 1
        git checkout "$checkout"

        for i in *.html; do
            cp "$i" "../$target_dir"
        done
        if [ -d include ] ; then
            cp -r include "../$target_dir" 
        fi
    )
}

mkdir branches
for branch in $(cd source-repo; git branch -r | sed 's:origin/::' | grep -v HEAD | grep -v gh-pages); do
    if [[ "$branch" =~ $SHOW_BRANCHES ]]; then
        extract "$branch" "branches/$branch"
    else
        echo "Skipping branch $branch"
    fi
done

# tag means git tag, release means NMOS/GitHub release
mkdir releases
for tag in $(cd source-repo; git tag); do
    if [[ "$tag" =~ $SHOW_RELEASES ]]; then
        extract "tags/$tag" "releases/$tag"
    else
        echo "Skipping tag/release $tag"
    fi
done
