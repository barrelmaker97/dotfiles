#!/bin/bash
/mnt/c/Windows/System32/cmd.exe /cWMIC Path Win32_Battery Get EstimatedChargeRemaining | tail -2 | head -1
