#!/bin/bash

## disable mac internal keyboard
sudo -S kextunload -b com.apple.driver.AppleHIDKeyboard > /dev/null

## disable bluetooth --> cause crash
# sudo launchctl unload /System/Library/LaunchDaemons/com.apple.bluetoothd.plist
