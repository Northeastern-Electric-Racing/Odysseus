#!/bin/bash

time make -j`nproc` --output-sync=target 2>&1 | tee output.log
