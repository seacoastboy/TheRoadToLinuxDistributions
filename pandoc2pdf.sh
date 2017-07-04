#!/bin/bash
pandoc -N -s --toc --smart --latex-engine=xelatex -V CJKmainfont='文泉驿微米黑' -V mainfont='Noto Sans' -V geometry:margin=1in system/*.md -o output.pdf


