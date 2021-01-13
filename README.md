# Work Around for Connecting to UCL VPN on MacOS Big Sur
Sophos Anti-Virus 9.10.0 and Cisco AnyConnect 4.8 do not support Big Sur. This is a work around to connect to the UCL VPN on Big Sur.


 To connect to the UCL VPN on MacOS Big Sur.

- Install openconnect from homebrew:

  ```
  brew install openconnect
  ```

- Copy [this script](https://blogs.ucl.ac.uk/dh/2015/09/18/tutorial-ucl-vpn-linux/) and save it as csd-wrapper.sh and render it executable (chmod 775 csd-wrapper.sh).

  ```
  #!/bin/sh
  #set -x
  
  platform_version="x86x64"
  device_type="Linux-x86"
  device_uniqueid="AAAAAAA"
  
  # delete the csdXXXXXX temp files so they don't start piling up
  rm -f $1
  
  exec curl \
  --globoff \
  --insecure \
  --user-agent "AnyConnect Linux" \
  --header "X-Transcend-Version: 1" \
  --header "X-Aggregate-Auth: 1" \
  --header "X-AnyConnect-Identifier-Platform: linux" \
  --header "X-AnyConnect-Identifier-PlatformVersion: $platform_version" \
  --header "X-AnyConnect-Identifier-DeviceType: $device_type" \
  --header "X-AnyConnect-Identifier-Device-UniqueID: $uniqueid" \
  --cookie "sdesktop=$CSD_TOKEN" \
  --data-ascii @- "https://$CSD_HOSTNAME/+CSCOE+/sdesktop/scan.xml" <<END
  endpoint.feature="failure";
  endpoint.os.version="Linux";
  END
  ```

- To connect to the VPN use:

  ```
  sudo openconnect vpn.ucl.ac.uk --csd-wrapper csd-wrapper.sh --authgroup=RemoteAccess
  
  ```

  For convenience we can have the username pretyped using --user eg.

  ```
  sudo openconnect vpn.ucl.ac.uk --csd-wrapper csd-wrapper.sh --authgroup=RemoteAccess --user=ucapXXX
  ```

- Disconnecting from the VPN should be as simple as  **CTRL**+**C**. However this **often** goes wrong. This can be fixed using this script or alternatively  a restart.

  ```
  #!/bin/bash
  # From https://gist.github.com/moklett/3170636#gistcomment-827700
  PATTERN="State:/Network/Service/utun[0-9]+/DNS"
  REMOVE_RECORD_CMD=""
  REMOVE_RECORD_MSG="RECORDS TO REMOVE:\n"
  
  sudo pkill openconnect
  
  RECORDS=`scutil <<EOF
  list $PATTERN
  quit
  EOF`
  for RECORD in `echo $RECORDS`; do
      if [[ "$RECORD" =~ "State" ]]; then
          REMOVE_RECORD_CMD="${REMOVE_RECORD_CMD}remove $RECORD \n"
          REMOVE_RECORD_MSG="${REMOVE_RECORD_MSG}$RECORD \n"
      fi
  done
  if [ "x$REMOVE_RECORD_CMD" != "x" ]; then
  printf "$REMOVE_RECORD_MSG"
      sudo scutil <<EOF
  `printf "$REMOVE_RECORD_CMD"`
  quit
  EOF
  fi
  ```

  I have the script saved as vpnreset.sh in the same directory as the csd-wrapper. So on disconnect I run:

  ```
  ./vpnreset.sh
  ```

  (Remember to make vpnreset.sh executable using chmod 775)

  I usually do all this in the root environment.

  ```
  sudo su
  ```

  This way the openconnect command is always in recent history.
