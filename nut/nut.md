# NUT Configuration
This tutorial will allow you to use a Raspberry Pi as a headless UPS server using the Network UPS Tools suite. NUT ([http://networkupstools.org](http://networkupstools.org)) is an extensible and highly configurable client/server application for monitoring and managing power sources. It includes a set of hardware-specific drivers, a server daemon (upsd), and clients like upsmon and upsc.

Why would you need a UPS server? I have a mixed environment with Linux, FreeBSD and Windows clients all hooked up to a single UPS. I want to shut down all services gracefully when the UPS battery is running empty. Setting up a NUT server allows you to do this quite easily. This is also a fun project that may put any RPi you may have laying around to good use in your rack.

The tutorial will take you thru the steps of preparing the SD card, Configure Raspbian, installing and testing the NUT server and deploying the NUT web UI. I have also covered how to configure Proxmox (any Debian/Ubuntu server really), pfSense and Synology DSM as NUT clients to control the graceful shutdown when the UPS battery runs out of power. A bonus step will allow you to get stats from your UPS to InfluxDB/Grafana and monitor your UPS via SNMP.

More information about how to configure NUT can be found here: https://networkupstools.org/docs/user-manual.chunked/ar01s06.html

## Check UPS Connection

Verify that the UPS is visible on the USB interface using the command:

```
lsusb
```

You should see the UPS listed:

```
Bus 001 Device 004: ID 0764:0601 Cyber Power System, Inc. PR1500LCDRT2U UPS
```

## Install NUT

Run the following to install the nut-server and nut-client packages:

```
sudo apt install nut
```

## Create UPS Entry

The first file to edit is /etc/nut/ups.conf Add the following section to the bottom:

```
[ups]
 driver = usbhid-ups
 port = auto
 desc = "Main UPS"
```

Within the bracket, set the UPS name (no space allowed) but keep the name "ups" for easier usage with Synology DSM.

Test the UPS driver by running:

```
sudo upsdrvctl start
```

This will return something similar to the below depending on your UPS model and if not, a reboot usually does the trick to get the UPS to play along:

```
Network UPS Tools - UPS driver controller 2.8.1
Network UPS Tools - Generic HID driver 0.52 (2.8.1)
USB communication driver (libusb 1.0) 0.46
Duplicate driver instance detected (PID file /run/nut/usbhid-ups-ups.pid exists)! Terminating other driver!
Using subdriver: CyberPower HID 0.8
```

## Configure upsd
upsd is responsible for serving the data from the drivers to the clients.

It connects to each driver and maintains a local cache of the current state.

It also conveys administrative messages from the clients back to the drivers, such as starting tests, or setting values.

Communication between upsd and clients is handled on a TCP port.

Add a LISTEN directive to the end of the `/etc/nut/upsd.conf` file to bind the upsd server to listen on port 3493:

```
LISTEN 0.0.0.0 3493
```

## Configure Users
We will also need to add some users to manage access to upsd by editing the upsd users config file /etc/nut/upsd.users and adding the following:

```
[admin]
  password = hunter2
  actions = set
  actions = fsd
  instcmds = ALL

[localuser]
  password = hunter2
  upsmon primary

[remoteuser]
  password = hunter2
  upsmon secondary

[monuser] # This is what Synology DSM expects
  password = secret # Leave this here.
  upsmon secondary
```

## Configure upsmon
Then we edit /etc/nut/upsmon.conf and add the UPS to be monitored and user credentials for upsd in the MONITOR section:

```
MONITOR ups@localhost 1 localuser hunter2 primary
```

## Start NUT
Edit /etc/nut/nut.conf and set the value for MODE equal to 'netserver' without any spaces before and after the = sign:

```
MODE=netserver
```

Then restart the nut-server and nut-monitor services:

```
sudo systemctl restart nut-server
sudo systemctl restart nut-monitor
```

## Verify the configuration

reboot the RPi and verify that the nut-server and local nut-client services are up

```
service nut-server status
service nut-client status
```

test the configuration using the following command:

```
upsc ups
```

This should produce something like this:

```
root@raspberrypi:~ # upsc ups
Init SSL without certificate database
battery.charge: 100
battery.charge.low: 10
battery.charge.warning: 50
battery.runtime: 33046
battery.runtime.low: 150
battery.type: PbAc
battery.voltage: 52.4
battery.voltage.nominal: 48.0
device.mfr: American Power Conversion
device.model: Smart-UPS X 750
device.serial: AS1035120444
device.type: ups
driver.flag.pollonly: enabled
driver.name: usbhid-ups
driver.parameter.pollfreq: 30
driver.parameter.pollinterval: 2
driver.parameter.port: auto
driver.version: 2.7.2
driver.version.data: APC HID 0.95
driver.version.internal: 0.38
ups.beeper.status: enabled
ups.delay.shutdown: 20
ups.firmware: COM 03.6 / UPS 03.6
ups.mfr: American Power Conversion
ups.mfr.date: 2010/08/24
ups.model: Smart-UPS X 750
ups.productid: 0003
ups.serial: AS1035120666
ups.status: OL
ups.timer.reboot: -1
ups.timer.shutdown: -1
ups.vendorid: 051d
```

Now you can continue adding NUT-clients on your network, and on the clients set nut.conf MODE=netclient and upsmon.conf to:

```
MONITOR ups@192.168.0.13 1 remoteuser hunter2 secondary
```

Congratulations. Your NUT server is now officially running!

## Web monitoring

You can optionally install a simple web GUI to monitor and control the UPS. This will require a web server on the RPi so we will begin by installing Apache but you can really use whatever cgi-capable web server you want. On the RPi:

```
apt install apache2
```

Install the nut-cgi package:

```
apt install nut-cgi
```

To monitor the UPS via the web CGI script, add the following line to /etc/nut/hosts.conf:

```
MONITOR ups@localhost "Local UPS"
```

Enable CGI support in apache:

```
a2enmod cgi
```

Restart Apache:

```
service apache2 restart
```

You can now access the web UI via: ([http://192.168.0.13/cgi-bin/nut/upsstats.cgi](http://192.168.0.13/cgi-bin/nut/upsstats.cgi))

Upsset will not run until you convince it that your CGI directory has been secured. You should therefore secure this directory according to the instructions in upsset.conf (outside of the scope of this tutorial) and when you're done, uncomment the following line in /etc/nut/upsset.conf:

```
### I_HAVE_SECURED_MY_CGI_DIRECTORY
```

This will allow you to log in to [http://192.168.0.13/cgi-bin/nut/upsset.cgi](http://192.168.0.13/cgi-bin/nut/upsset.cgi) using the admin user/password we configured in /etc/nut/upsd.users. You will be able to view and set options on your UPS if this is supported by your ups.

## Configuring Proxmox/Ubuntu/Debian node as client for remote NUT server

To shut down Proxmox including all VMs and containers gracefully, we need to install nut on the Proxmox server. SSH as root to your PVE host and:

```
apt update
apt install nut-client
```

Edit /etc/nut/nut.conf and tell it to act as a client:

```
MODE=netclient
```

Edit /etc/nut/upsmon.conf and add a MONITOR directive in the MONITOR section that tells it to listen to the NUT server:

```
MONITOR ups@192.168.0.13 1 upsmon_remote hunter2 secondary
```

Start monitoring:

```
service nut-client start
```

Verify the installation by checking the UPS status on the NUT server from Proxmox:

```
upsc ups@192.168.0.13
```

The default NUT shutdown command will let Proxmox shut down all VMs and Containers gracefully before Proxmox is shut down. This is of course depending on if the VMs and Containers allow that, so check your configs.

## Synology Diskstation UPS configuration

Synology DSM uses NUT to manage and share UPSes. The NUT UPS name and the username/password for the NUT client in DSM can't be set in the GUI, but the config we created earlier is set to match what DMS expects, so there is no need to modify anything over SSH unles you want to.

In DSM, go to Control Panel/Hardware and Power and switch to the UPS tab. Configure the following:

* Enable UPS support: true
* Network UPS type: Synology UPS server
* Network UPS server IP: 192.168.0.13

DSM looks for the "ups" UPS entry in /etc/nut/ups.conf on the RPi by default and uses the monuser/secret username/password pair that we created in the /etc/nut/upsd.users file on the RPi

Click save and then the Device Information button to verify that the connection to the RPi works as expected.

## Test the NUT server

It is a good idea to test behaviour of the NUT server and connected clients in case of a power outage before it happens. One way to do it is to keep your devices connected to mains during the testing and then move them to the UPS once everything is verified.

To test the server behavior in case of power outage, use the following command on the NUT server:

```
upsmon -c fsd
```

If the UPS is connected to mains, the server will stop and then restart (don't forget to set your BIOS power management to "Always on"). If the UPS is unplugged, the server will restart only after reconnection to mains.

NUT writes to the syslog by default on most Linux systems. You can monitor the log as the shutdown events happen using the command:

```
tail -f /var/log/syslog
```

You can also view the upslog status messages using the command:

```
upslog -s ups -l -
```
