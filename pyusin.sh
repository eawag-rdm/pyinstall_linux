#!/bin/bash

INSTALLPREFIX="$HOME/.local"

version="$1"
if [[ $version != "2" && $version != "3" ]]; then
    echo "Argument must be either \"2\" (Python 2) or \"3\" (Python 3)"
    exit 1
fi

if [[ "$version" == "2" ]]; then
    EXECNAME="python"
else
    EXECNAME="python3"
fi

baseurl="https://www.python.org/ftp/python/"

find_latest() {
    wget --quiet -O dirlist.tmp $baseurl
    sed  -n 's|<a href=[^>]\{1,\}>\([0-9]\)\.\([0-9]\)\.\([0-9]\{1,\}\)/</a>.*$|\1 \2 \3|p' dirlist.tmp > versions.tmp
    # find latest version
    v2max=0
    v3max=0
    while read v1 v2 v3; do
	#echo $v1 $v2 $v3
	if [[ "$v1" -ne "$version" ]]; then
	    continue
	elif [[ "$v2" -lt "$v2max" ]]; then
	    continue
	elif [[ "$v3" -lt "$v3max" ]]; then
	    continue
	else
	    v2max="$v2"
	    v3max="$v3"
	fi
    done <versions.tmp
    echo "${version}.${v2max}.${v3max}"
}
mkdir python_install_tempdir
cd  python_install_tempdir
fullversion=$(find_latest)
dlurl="${baseurl}${fullversion}/Python-${fullversion}.tgz"
echo "downloading Python-${fullversion}.tgz ..."
wget $dlurl
echo "unpacking ..."
tar zxvf "Python-${fullversion}.tgz"
cd "Python-${fullversion}"
./configure --prefix=$INSTALLPREFIX
make && make install

echo "installing pip"
wget https://bootstrap.pypa.io/get-pip.py
${INSTALLPREFIX}/bin/${EXECNAME} ./get-pip.py --user

echo "export PATH=\"$INSTALLPREFIX/bin:$PATH\"" >> $HOME/.bashrc
cd ../..
rm -rf python_install_tempdir
echo "Finished"
echo "Please source your .bashrc to set the necessary environment variables like so:"
echo ". $HOME/.bashrc"
