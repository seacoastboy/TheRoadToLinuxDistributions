#!/bin/bash

case `uname` in
	Darwin)
		export PATH=/Applications/calibre.app/Contents/MacOS:$PATH
		gitbook pdf .
		;;
	Linux)
		gitbook pdf .
		;;
	*)
		echo "Unkown OS type"
		;;
esac
