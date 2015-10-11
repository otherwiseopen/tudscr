#!/bin/bash
# @echo off
ORIGINALDIR=`pwd`     # save original dir for later
cd `dirname $0`     # change to directory of batch file
MYDIR=`pwd`

echo
echo "========================================================================="
echo " Festlegen der Version, welche erstellt werden soll                      "
echo "========================================================================="
echo

# grep for the version in source\tudscr-version.dtx
# 
VERSION=`egrep -o "\\@TUDVersion{([0-9]{4}/[0-9][0-9]/[0-9][0-9])" source/tudscr-version.dtx | egrep -o [0-9].*`

echo -n "$VERSION"
read SUPPLEMENT
VERSION="$VERSION$SUPPLEMENT"
VERSION=`echo $VERSION | sed 's|/|-|g'`
if [ -d temp ]; then
  rm -r temp
fi
if [ -d release-$VERSION ]; then
  rm -r release-$VERSION
fi

echo
echo "========================================================================="
echo " Erzeugen der Klassen und der inline-Dokumentation fuer $VERSION"
echo "========================================================================="
echo

./update_classes.sh > log.log
cp -r source temp
cd temp
./clearsource.sh
if [ -d release-$VERSION/test ]
then
  rm -rf release-$VERSION/test
fi
mkdir -p tex/latex/tudscr
mkdir -p source/latex/tudscr
mkdir -p doc/latex/tudscr/tutorials
echo '\BaseDirectory{.}' > docstrip.cfg
echo '\UseTDS'          >> docstrip.cfg
tex tudscr.ins > log.log
pdflatex '\def\tudfinalflag{}\input{tudscrsource.tex}' > log.log
pdflatex '\def\tudfinalflag{}\input{tudscrsource.tex}' > log.log
makeindex -s gglo.ist -o tudscrsource.gls tudscrsource.glo > log.log
makeindex -s gind.ist -o tudscrsource.ind tudscrsource.idx > log.log
pdflatex '\def\tudfinalflag{}\input{tudscrsource.tex}' > log.log
pdflatex '\def\tudfinalflag{}\input{tudscrsource.tex}' > log.log
mv    *.dtx            source/latex/tudscr/
mv    tudscr.ins       source/latex/tudscr/
mv    tudscrsource.tex source/latex/tudscr/
cp -r doc              source/latex/tudscr/doc/
# rm    source/latex/tudscr/test.tex # this can't be here because we did not copy it!
for file in ../*.md
do
  cp $file doc/latex/tudscr
done
mv    tudscrsource.pdf doc/latex/tudscr/
mv    logo             tex/latex/tudscr/
rm *?.?* 

# echo
# echo "========================================================================="
# echo " Erzeugen des Benutzerhandbuchs"
# echo "========================================================================="
# echo
# 
# cd doc
# pdflatex -shell-escape '\def\tudfinalflag{}\input{tudscr.tex}' > log.log
# pdflatex '\def\tudfinalflag{}\input{tudscr.tex}' > log.log
# pdflatex '\def\tudfinalflag{}\input{tudscr.tex}' > log.log
# pdflatex '\def\tudfinalflag{}\input{tudscr.tex}' > log.log
# pdflatex -shell-escape '\def\tudfinalflag{}\input{tudscr.tex}' > log.log
# pdflatex '\def\tudfinalflag{}\input{tudscr.tex}' > log.log
# pdflatex '\def\tudfinalflag{}\def\tudprintflag{}\input{tudscr.tex}' > log.log
# cp tudscr.pdf tudscr_print.pdf
# pdflatex '\def\tudfinalflag{}\input{tudscr.tex}' > log.log
# rm tutorials\*autopp*.*
# 
# find tutorials/*.pdf | grep -v '\-temp.pdf' | grep -v '\-pics.pdf' | xargs -I X mv X latex\tudscr
# 
# for i in tutorials/*-temp.pdf
# do
#   j=`basename $i`
#   cp $i ../source/latex/tudscr/doc/examples/${j/-temp}
# done
# 
# rm *?.?*
# rm -r examples
# rm -r tutorials
# cd ..

# echo
# echo "========================================================================="
# echo "Erzeugen der Installationdateien"
# echo "========================================================================="
# echo
# 
# cd install
# cp ../source/latex/tudscr/tudscr-version.dtx ..
# tex tud-install.ins
# tex tudscr-install.ins
# for i in *.bxt
# do
#   mv $i ${i/.bxt/.bat}
# done
# 
# for i in *_VER_*
# do
#   mv $i ${i/_VER_/_${VERSION}_}
# done
# 
# rm ../tudscr-version.dtx

# echo
# echo "========================================================================="
# echo " Release fuer GitHub"
# echo "========================================================================="
# echo
# 
# cd $MYDIR
# mkdir release-$VERSION/temp
# mkdir release-$VERSION/GitHub
# cp *.md                                   release-$VERSION/temp/
# cp addon                                  release-$VERSION/temp/
# cp development/fonts/*.*                  release-$VERSION/temp/
# cp development/tools/*.*                  release-$VERSION/temp/
# cp temp/doc/latex/tudscr/tudscr.pdf       release-$VERSION/temp/
# cp temp/doc/latex/tudscr/tudscr_print.pdf release-$VERSION/temp/
# mv temp\install\*.*                       release-$VERSION/temp/
# rm -r temp/install
# cd release-$VERSION/temp
# for /f %%f in ('dir /b *.bat') do unix2dos -k %%f
# 7za a -tzip tudscr_%version%_full.zip   .\..\..\temp\*
# 7za a -tzip tudscr_%version%_update.zip .\..\..\temp\* -xr!logo
# 7za a -tzip tudscr_fonts_install.zip                                              @7za_files_metrics.txt
# call tudscr_fonts_convert.bat
# 7za a -tzip tudscr_fonts_converted.zip                                            @7za_files_fonts.txt
# for /f %%f in ('dir /b *.md') do unix2dos -n -k %%f %%~nf.txt
# 7za a -tzip .\..\TUD-KOMA-Script_%version%_Windows_all.zip    -x!*.sh             @7za_files_full.txt @7za_files_postscript.txt
# 7za a -tzip .\..\TUD-KOMA-Script_%version%_Windows_full.zip   -x!*.sh             @7za_files_full.txt
# 7za a -tzip .\..\TUD-KOMA-Script_%version%_Windows_update.zip -x!*.sh             @7za_files_update.txt
# 7za a -tzip .\..\TUD-KOMA-Script_fonts_Windows.zip            -x!*.sh             @7za_files_fonts_install.txt
# 7za a -tzip .\..\TUD-KOMA-Script_fonts_converted_Windows.zip  -x!*.sh             @7za_files_fonts_converted.txt
# for /f %%f in ('dir /b *.md') do copy %%f %%~nf.txt
# 7za a -tzip .\..\TUD-KOMA-Script_%version%_Unix_all.zip       -x!*.bat -x!7za.exe @7za_files_full.txt @7za_files_postscript.txt
# 7za a -tzip .\..\TUD-KOMA-Script_%version%_Unix_full.zip      -x!*.bat -x!7za.exe @7za_files_full.txt
# 7za a -tzip .\..\TUD-KOMA-Script_%version%_Unix_update.zip    -x!*.bat -x!7za.exe @7za_files_update.txt
# 7za a -tzip .\..\TUD-KOMA-Script_fonts_Unix.zip               -x!*.bat -x!7za.exe @7za_files_fonts_install.txt
# 7za a -tzip .\..\TUD-KOMA-Script_fonts_converted_Unix.zip     -x!*.bat -x!7za.exe @7za_files_fonts_converted.txt
# 7za a -tzip .\..\tudscr4lyx.zip       .\tudscr4lyx\*
# 7za a -tzip .\..\tudscr4texstudio.zip .\tudscr4texstudio\*
# cd..
# attrib +h *_all.zip
# attrib +h *_converted*.zip
# move *.zip GitHub\
# attrib -h *_converted*.zip
# attrib -h *_all.zip
# move temp\tudscr_%version%_full.zip  GitHub\tudscr_%version%.zip
# copy temp\tudscr_uninstall.*         GitHub\

# echo
# echo =========================================================================
# echo  Release fuer CTAN
# echo =========================================================================
# echo
# 
# mkdir CTAN\tudscr\doc
# mkdir CTAN\tudscr\source
# mkdir CTAN\tudscr\logo
# xcopy ..\temp\doc\latex\tudscr\*.*      CTAN\tudscr\doc\    /s
# xcopy ..\temp\source\latex\tudscr\*.*   CTAN\tudscr\source\ /s
# xcopy ..\temp\tex\latex\tudscr\logo\*.* CTAN\tudscr\logo\   /s
# move  CTAN\tudscr\doc\README            CTAN\tudscr\README
# cd temp
# (
#   echo With WScript
#   echo   ZipFile = .Arguments^(0^) 
#   echo   Folder = .Arguments^(1^) 
#   echo End With
#   echo CreateObject^("Scripting.FileSystemObject"^).CreateTextFile^(ZipFile, True^).Write "PK" ^& Chr^(5^) ^& Chr^(6^) ^& String^(18, vbNullChar^) 
#   echo With CreateObject^("Shell.Application"^) 
#   echo   .NameSpace^(ZipFile^).CopyHere .NameSpace^(Folder^).Items
#   echo End With
#   echo wScript.Sleep 2000 
# ) > winzip.vbs
# cd ..
# CScript  temp\winzip.vbs %cd%\tudscr.zip %cd%\CTAN
# move %cd%\tudscr.zip %cd%\CTAN\

# echo
# echo =========================================================================
# echo  Aktualisierung des Releases der Version v1.0 fuer GitHub
# echo =========================================================================
# echo
# 
# cd %~dp0
# mkdir release-%version%\GitHub-tudscrold
# mkdir release-%version%\temp\tudscrold\doc\latex\tudscrold
# mkdir release-%version%\temp\tudscrold\source\latex\tudscrold
# mkdir release-%version%\temp\tudscrold\tex\latex\tudscrold
# xcopy ..\tudscrold\bundle\doc\*.*    release-%version%\temp\tudscrold\doc\latex\tudscrold\ /s
# xcopy ..\tudscrold\bundle\source\*.* release-%version%\temp\tudscrold\source\latex\tudscrold\ /s
# xcopy ..\tudscrold\bundle\tex\*.*    release-%version%\temp\tudscrold\tex\latex\tudscrold\ /s
# cd release-%version%\temp
# copy tudscrold\doc\latex\tudscrold\tudscrold.pdf .
# 7za a -tzip tudscr_v1.0old.zip   .\tudscrold\*
# 7za a -tzip .\..\TUD-KOMA-Script_v1.0old.zip @7za_files_old.txt
# cd..
# move TUD-KOMA-Script_v1.0old.zip     GitHub-tudscrold\
# move temp\tudscr_v1.0old.zip         GitHub-tudscrold\
# move temp\tud_fonts_install.*        GitHub-tudscrold\

echo
echo =========================================================================
echo  Delete all temporary files
echo =========================================================================
echo

read -rsp $'Press any key to continue... (or Ctrl-C to exit)\n' -n1 key

cd $MYDIR     # change to directory of batch file
if [ -d release-%version%/temp ]
then
  rm -rf release-%version%/temp
fi
if [ -d release-%version%/CTAN/tudscr ]
then
  rm -rf release-%version%/CTAN/tudscr
fi
if [ -d temp ]
then rm -rf temp
fi
cd $ORIGINALDIR
