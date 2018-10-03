#!/usr/bin/env bash

if [ "$DEBUG" = true ]; 
	then
	  set -e
	  export DISPLAY=$RemoteDisplay
	  chromedriver --verbose --url-base=wd/hub &
    else
      export GEOMETRY="$SCREEN_WIDTH""x""$SCREEN_HEIGHT""x""$SCREEN_DEPTH"
      Xvfb :99 -screen 0 $GEOMETRY -ac +extension RANDR >>~/xvfb10.log 2>&1 &
      chromedriver --url-base=wd/hub &
  
fi

if [ "$UseSharedModule" = true ]; then
    if [ ! -d "${WORKSPACE}/node_modules" ]; then
      ln -s $SourceModuleFolder  ${WORKSPACE}
    else
      echo "symlink exists"
    fi
fi

sleep 3


