#!/bin/bash

# @echo off
set +v

find -name "?*.?*" -not -name "*.dtx" -not -name "*.bat" -not -name "*.ins" -not -name "*.sh" -not -name "tudscrsource.tex" -not -wholename "./install/*.bat" -not -wholename "./install/*.tex" -not -wholename "./doc/*" -not -wholename "./logo/*" | xargs rm
