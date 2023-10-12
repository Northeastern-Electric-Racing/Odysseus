#!/bin/bash

raspi-gpio set 13 op dh
java -jar "/home/$USER/nrc7292_sdk/package/standalone/tools/AT_CMD_Test_Tool/AT-CMD_Test_Tool.exe"
