#!/bin/sh

CLDR_LAYOUTS_TARBALL="http://www.unicode.org/Public/cldr/latest/keyboards.zip"
CLDR2JSON_GIT="git://repo.or.cz/cldr2json.git"

WORKDIR=".osk-layout-workbench"
CLDR2JSON="$WORKDIR/cldr2json/cldr2json.py"
SRCDIR="$WORKDIR/keyboards/android"
DESTDIR="osk-layouts"
GRESOURCE_FILE="gnome-shell-osk-layouts.gresource.xml"
TMP_GRESOURCE_FILE=".$GRESOURCE_FILE.tmp"

# Ensure work/dest dirs
rm -rf $WORKDIR
mkdir -p $WORKDIR
mkdir -p "osk-layouts"

# Download stuff on the work dir
pushd $WORKDIR
gio copy $CLDR_LAYOUTS_TARBALL .
git clone $CLDR2JSON_GIT
unzip keyboards.zip
popd

# Transform to JSON files
$CLDR2JSON $SRCDIR $DESTDIR

# Modify gresources
cat >$TMP_GRESOURCE_FILE <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<gresources>
  <gresource prefix="/org/gnome/shell/osk-layouts">
EOF

for f in $DESTDIR/*.json
do
    echo "    <file>$(basename $f)</file>" >>$TMP_GRESOURCE_FILE
done

cat >>$TMP_GRESOURCE_FILE <<EOF
  </gresource>
</gresources>
EOF

# Rewrite gresources xml
mv $TMP_GRESOURCE_FILE $GRESOURCE_FILE
