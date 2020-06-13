#!/bin/bash
SOURCE_REPO=~/workspaces/VVCSoftware_VTM/
GIT_DIR=$SOURCE_REPO/.git
GIT_WORKTREE="$(cd $GIT_DIR/.. && git rev-parse --show-toplevel)"
GIT_COMMAND="git --work-tree=$GIT_WORKTREE --git-dir=$GIT_DIR"
VERSION=$( ( $GIT_COMMAND describe --tags --long --always ; $GIT_COMMAND describe --all --dirty=+dirty) | sed -e '1N; s/\n/-/' -e  's/\//-/g')

if [ "$1" = "clean" ]; then
        rm -rf CMakeCache.txt ./CMakeFiles/ ./Makefile ./bin/ ./cmake_install.cmake ./lib/ ./source/
fi

cmake $SOURCE_REPO -DCMAKE_BUILD_TYPE=Release

make -j25

chmod -Rf g+w $SOURCE_REPO/bin/*Static

cp -rf --remove-destination $SOURCE_REPO/{bin,lib} .

mv ./bin/EncoderAppStatic ./bin/EncoderAppStatic-$VERSION
mv ./bin/DecoderAppStatic ./bin/DecoderAppStatic-$VERSION

cd bin

ln -sf ./EncoderAppStatic-$VERSION ./EncoderAppStatic
ln -sf ./DecoderAppStatic-$VERSION ./DecoderAppStatic
