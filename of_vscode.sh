#!/bin/bash

# ---------------- SETTINGS ------------------------------------

# put the absolute path of the script here
scriptpath="/home/$USER/apps/of_vscode"

# put the absolute path of openFrameworks here
rootpath="/home/$USER/oF"

# choose the name of your distro includes for oF
distrofile="of_debian.paths"

#choose your compiler
#compiler="gcc-x64"
compiler="clang-x64"


# ---------------- SCRIPT -------------------------------------

destpath=${1%/}

if [ -z "$destpath" ]; then 
        echo "creating project in current path"
        destpath=$(pwd)
fi

appname=$(basename $destpath)
echo "generating visual studio oF project named $appname for path $destpath"

echo "generating .vscode/c_cpp_properties.json"


rm -rf $destpath/.vscode
mkdir $destpath/.vscode
rm -rf $destpath/*.code-workspace

cat $scriptpath/base/c_cpp_properties_pt1.json >> $destpath/.vscode/c_cpp_properties.json

echo -e "    adding oF includes"
while read -r path
do 
        echo -e "\t\t\t\t\"$path\"," >> $destpath/.vscode/c_cpp_properties.json
done < $scriptpath/paths/$distrofile

inputlist="$destpath/addons.make"
if [ -f $inputlist ]; then
        while read -r addon
        do
                filename=$scriptpath/paths/$addon.paths
                if [ -f $filename ]; then
                        echo -e "    adding includes for $addon"
                        while read -r path 
                        do

                                echo -e "\t\t\t\t\"$path\"," >> $destpath/.vscode/c_cpp_properties.json

                        done < $filename
                else
                        echo -e "    file $addon.paths not present, attempting automatic paths finding"
                        addonpath="$rootpath/addons/$addon"
                        echo -e "        presuming path $addonpath"
                        if [ -d $addonpath/src ]; then
                                echo -e "        adding all the paths in $addonpath/src"
                                for i in $(find $addonpath/src -type d); do
                                        echo -e "\t\t\t\t\"$i\"," >> $destpath/.vscode/c_cpp_properties.json
                                done
                        fi
                        if [ -d $addonpath/libs ]; then
                                echo -e "        adding all the paths in $addonpath/libs"
                                for i in $(find $addonpath/libs -type d); do
                                        echo -e "\t\t\t\t\"$i\"," >> $destpath/.vscode/c_cpp_properties.json
                                done
                        fi

                fi
        done < $inputlist
fi

cat $scriptpath/base/c_cpp_properties_pt2.json >> $destpath/.vscode/c_cpp_properties.json

sed -i -e "s|OFDIRECTORY|$rootpath|g" $destpath/.vscode/c_cpp_properties.json
sed -i -e "s|COMPILERMODE|$compiler|g" $destpath/.vscode/c_cpp_properties.json

echo "editing other json files"

cp  $scriptpath/base/launch.json $destpath/.vscode/launch.json
sed -i -e "s|APPNAME|$appname|g" $destpath/.vscode/launch.json

cp  $scriptpath/base/settings.json $destpath/.vscode/settings.json
sed -i -e "s|COMPILERMODE|$compiler|g" $destpath/.vscode/settings.json

cp  $scriptpath/base/tasks.json $destpath/.vscode/tasks.json

echo "copying other files"
cp $scriptpath/base/appname.code-workspace $destpath/$appname.code-workspace

if [ ! -f $destpath/Makefile ]; then
        cp $scriptpath/base/Makefile $destpath/Makefile
fi


exit
