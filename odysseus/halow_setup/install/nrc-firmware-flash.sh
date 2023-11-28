#!/bin/bash

raspi-gpio set 13 op dh
java -jar "/home/$USER/nrc7292_sdk/package/standalone/tools/external/FirmwareFlashTool.exe"
