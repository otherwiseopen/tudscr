#!/bin/sh
TOPDIR=`dirname $0`
cd "$TOPDIR"
if [ -d temp ]
then
    rm -rf temp 
fi
cp -r source temp
mkdir -p temp/tex/latex/tudscr
cp -r source/logo temp/tex/latex/tudscr
cd temp
cat > docstrip.cfg <<EOF
\BaseDirectory{.}
\UseTDS
EOF
tex tudscr.ins
TEXMFPATH=`kpsewhich --var-value=TEXMFHOME`
cp -r tex "$TEXMFPATH" 
cd "$TOPDIR"
if [ -d temp ]
then
    rm -rf temp 
fi
