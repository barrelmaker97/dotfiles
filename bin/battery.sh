/mnt/c/Windows/System32/cmd.exe /cWMIC Path Win32_Battery Get EstimatedChargeRemaining | sed -n '2 p' | cut -c1-2
