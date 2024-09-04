This tutorial will allow you to use a Raspberry Pi as a headless UPS server using the Network UPS Tools suite. NUT ([http://networkupstools.org](http://networkupstools.org)) is an extensible and highly configurable client/server application for monitoring and managing power sources. It includes a set of hardware-specific drivers, a server daemon (upsd), and clients like upsmon and upsc.

Why would you need a UPS server? I have a mixed environment with Linux, FreeBSD and Windows clients all hooked up to a single UPS. I want to shut down all services gracefully when the UPS battery is running empty. Setting up a NUT server allows you to do this quite easily. This is also a fun project that may put any RPi you may have laying around to good use in your rack.

The tutorial will take you thru the steps of preparing the SD card, Configure Raspbian, installing and testing the NUT server and deploying the NUT web UI. I have also covered how to configure Proxmox (any Debian/Ubuntu server really), pfSense and Synology DSM as NUT clients to control the graceful shutdown when the UPS battery runs out of power. A bonus step will allow you to get stats from your UPS to InfluxDB/Grafana and monitor your UPS via SNMP.

**Install NUT**

ssh as root to the RPi and install the NUT-server and NUT-client:

```
apt install nut
```

Verify that the UPS is visible on the USB interface using the command:

```
lsusb
```

You should see the UPS listed:

```
Bus 001 Device 004: ID 0764:0601 Cyber Power System, Inc. PR1500LCDRT2U UPS
```

**Configure NUT**

The first file to edit is /etc/nut/ups.conf Add the following section to the bottom:

```
[ups]
 driver = usbhid-ups
 port = auto
 desc = "Main UPS"
```

Within the bracket, you can set your UPS name (no space allowed) but keep the name "ups" for easier usage with Synology DSM.

Test the UPS driver by running:

```
upsdrvctl start
```

This will return something similar to the below depending on your UPS model and if not, a reboot usually does the trick to get the UPS to play along:

```
Network UPS Tools - UPS driver controller 2.7.2
Network UPS Tools - Generic HID driver 0.38 (2.7.2)
USB communication driver 0.32
Using subdriver: APC HID 0.95
```

**Upsmon and upsd**

The next step is to configure upsmon and upsd of which the later communicates with the UPS driver configured while upsmon monitors and communicates shutdown procedures to upsd. NUT allows multiple instances of upsmon to run on different machines while communicating with the same physical UPS.

For upsd to be accessible via the network we edit /etc/nut/upsd.conf

Uncomment the LISTEN directive for localhost (127.0.0.1) and add another LISTEN directive for the static IP we assigned to the RPi earlier.

```
LISTEN 127.0.0.1 3493
LISTEN 192.168.0.13 3493
```

We will also need to add some users to manage access to upsd by editing the upsd users config file /etc/nut/upsd.users and adding the following:

```
[admin]
 password = hunter2
 actions = SET
 instcmds = ALL
[upsmon_local]
 password = hunter2
 upsmon master
[upsmon_remote]
 password = hunter2
 upsmon slave
[monuser]#This is what Synology DSM expects
 password = secret #Leave this here.
 upsmon slave
```

Then we edit /etc/nut/upsmon.conf and add the UPS to be monitored and user credentials for upsd in the MONITOR section:

```
MONITOR ups@localhost 1 upsmon_local hunter2 master
```

And finally edit /etc/nut/nut.conf and set the value for MODE equal to 'netserver' without any spaces before and after the = sign:

```
MODE=netserver
```

**Verify the configuration**

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
MONITOR ups@192.168.0.13 1 upsmon_remote hunter2 slave
```

Congratulations. Your NUT server is now officially running!

**Web monitoring**

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

**Configuring Proxmox/Ubuntu/Debian node as client for remote NUT server**

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
MONITOR ups@192.168.0.13 1 upsmon_remote hunter2 slave
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

**ESXi**

René Margar has ported a NUT client to ESXi. This is is a well maintained client that works on ESXi 5.0, 5.1, 5.5, 6.0 and 6.5. It is available from his blog here: [http://rene.margar.fr/2012/05/client-nut-pour-esxi-5-0/](http://rene.margar.fr/2012/05/client-nut-pour-esxi-5-0/) (in French)

We need to enable SSH access first. Connect to the ESXi 6.5 Server using the Web Client. Go to the "default hypervisor home page", click the Host icon, and select Actions (the gear icon). Click Services in the drop-down menu and select Enable Secure Shell (SSH). Then enable console shell from the same menu.

Ssh to the ESXi server and set the hypervisor to the community acceptance level to accept unsigned (community-supported) VIBs. Change the acceptance level of the host by running the following command.

```
esxcli software acceptance set --level CommunitySupported
```

Go to the /tmp directory

```
cd /tmp
```

And download the NUT ESXi client:

```
wget http://rene.margar.fr/downloads/NutClient-ESXi-2.0.0.tar.gz
```

Extract the archive

```
tar -xzf NutClient-ESXi-2.0.0.tar.gz
```

Run the installer:

```
sh upsmon-install.sh
```

the result should be something like this:

```
Installation Result
 Message: Operation finished successfully.
 Reboot Required: false
 VIBs Installed: Margar_bootbank_upsmon_2.7.4-2.0.0
 VIBs Removed:
 VIBs Skipped:
```

You can delete the files that were downloaded and extracted in /tmp directory and disable the SSH service again if you want to.

You must configure NUT before launching for the first time and I found that I needed to reboot the machine for the config vars to appear in the web GUI.

Reboot and log in to the web GUI again. Go to Manage in the Navigator pane. Select the System tab and then Advanced Settings. There are 6 variables to configure for NUT:

* UserVars.NutUpsName : The name of the UPS on the NUT server (as upsname@server_name or server_ip) (ups@192.168.0.13). Several UPSes can be entered separated by a space. There will be no system shutdown until the last UPS has issued the stop command.
* UserVars.NutUser : The account to the NUT server (upsmon_remote)
* UserVars.NutPassword : Password for the NUT server login account (hunter2)
* UserVars.NutFinalDelay : Seconds to wait after receiving the low battery event to shut down the system
* UserVars.NutSendMail : Set to 1 so that the NUT client sends an e-mail for each UPS event
* UserVars.NutMailTo : The e-mail address to send the UPS events to

Configure the variables and go to the Services tab. Select the NutClient service. Press Start and verify that the service is started.

Configure the NutClient to start automatically by clicking "Conffigure" on the service in the Services tab. Then select the Policy "Start and stop with host".

That's it. you're done! You can use the configuration tab of the ESXi host in the web GUI to configure the order to start and stop (or suspend) virtual machines. This order will be respected by the shutdown procedure on NUT alerts. Clean OS shutdown in virtual machines is only possible if vmware tools are installed on each VM.

To uninstall the NUT client, use the upsmon-remove script in the file that you downloaded earlier:

```
/tmp # sh upsmon-remove
```

To test the installation, type the command "upsmon -c fsd" on the ESXi host (via ssh or on the console). The shutdown procedure is started immediately.

**pfSense NUT package**

pfSense has a package for NUT so it is trivial to hook it up to the NUT server. In pfSense, go to System/Package Manager/Available Packages and install the nut package. Then go to Services/UPS and the Ups tab and configure the following:

* UPS Type: Remote Nut Server
* UPS Name: ups
* Remote IP adress or hostname: 192.168.0.13
* Remote Port: 3493
* Remote Username: upsmon_remote
* Remote Password: hunter2

Click Save and switch to the UPS status tab to verify that the UPS status is displayed properly.

**Synology Diskstation UPS configuration**

Synology DSM uses NUT to manage and share UPSes. The NUT UPS name and the username/password for the NUT client in DSM can't be set in the GUI, but the config we created earlier is set to match what DMS expects, so there is no need to modify anything over SSH unles you want to.

In DSM, go to Control Panel/Hardware and Power and switch to the UPS tab. Configure the following:

* Enable UPS support: true
* Network UPS type: Synology UPS server
* Network UPS server IP: 192.168.0.13

DSM looks for the "ups" UPS entry in /etc/nut/ups.conf on the RPi by default and uses the monuser/secret username/password pair that we created in the /etc/nut/upsd.users file on the RPi

Click save and then the Device Information button to verify that the connection to the RPi works as expected.

**Test the NUT server**

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

**NUT and InfluxDB/Grafana**

Here's a method to push the NUT server UPS status over to InfluxDB/Grafana for monitoring. It uses a Python script from [https://github.com/lf-/influx_nut](https://github.com/lf-/influx_nut). On the RPi:

```
apt install python3
apt install python3-pip
apt install git
pip3 install typing
cd /etc/nut/
git clone https://github.com/lf-/influx_nut
```

Edit /etc/nut/influx_nut/influx_nut.py and configure the settings for your NUT host, your InfluxDB host and what stats to send to InfluxDB. The var names you can use in the "nut_vars" entry can be seen using the command "upsc ups"

```
DEFAULT_CONFIG = {
 'interval': 20,
 'nut_host': '127.0.0.1',
 'nut_port': 3493,
 'nut_ups': 'ups',
 # variables from NUT to send to influxdb
 "nut_vars": {
 "battery.charge": {
 "type": "int",
 "measurement_name": "ups_charge"
 },
 "battery.runtime": {
 "type": "int",
 "measurement_name": "ups_runtime"
 },
 "battery.voltage": {
 "type": "float",
 "measurement_name": "ups_voltage"
 }
 },
 'influx_host': 'http://192.168.0.37:8086',
 'influx_db': 'telegraf',
 'influx_tags': {"ups": "apc"},
 'influx_creds': ["telegraf", &#x201C;hunter2&#x201D;]
}
```

Test the script:

```
python3 /etc/nut/influx_nut/influx_nut.py
```

The result should be something like this:

```
http://192.168.0.37:8086 {'db': 'telegraf', 'p': &#x2018;hunter2&#x2019;, 'u': 'telegraf'} b'ups_charge,ups=apc value=100\nups_runtime,ups=apc value=33046\nups_voltage,ups=apc value=52.2'
```

This should also produce a bunch of entries in your InfluxDB that you can graph using Grafana.

Now make the script run automatically after a reboot by adding the following line to /etc/rc.local:

```
/usr/bin/python3 /etc/nut/influx_nut/influx_nut.py &
```

Reboot the RPi to verify that the script starts.

**Add SNMP support**

You can also enable support for SNMP to the RPI to make it possible to monitor the UPS over the network using SNMP-based tools. This also provides an alternative way to get the stats into InfluxDB using Telegraf and the SNMP plugin if you prefer that over the Python script above. On the RPi:

```
apt install snmp
apt install snmpd
apt install snmp-mibs-downloader
```

Create the file /usr/local/bin/ups-status.sh and add the following script:

```
#!/bin/bash
# read value
VALUE=$(/bin/upsc UPS@localhost $1 2>&1 | /bin/grep -v '^Init SSL')
# return vaue
echo ${VALUE}
```

Make the script executable:

```
chmod +x /usr/local/bin/ups-status.sh
```

Execute the following command to add UPS MIB extensions for all variables reported by upsc to /etc/snmp/snmpd.conf:

```
upsc ups@localhost | sed 's/^\(.*\): .*$/extend \1 \/usr\/local\/bin\/ups-status.sh \1/' >> /etc/snmp/snmpd.conf
```

Edit /etc/snmp/snmpd.conf and add the following string to enable connections via the network interface in addition to localhost.

```
agentAddress udp:192.168.0.13:161 #change this to the static ip of the RPi
```

Also add the following line to provide snmp access to other machines in the network (You may narrow this down to specific machines if you want to):

```
rocommunity public
```

Restart the snmpd daemon:

```
service snmpd restart
```

You may get an error like "pcilib: pci_init failed" when the daemon is started due to a bug in Raspbian, but it should work regardless.

You should now be able to get the UPS status values using snmpwalk or snmpget like so:

```
snmpget -v 1 -c public localhost NET-SNMP-EXTEND-MIB::nsExtendOutputFull.\"battery.charge.low\"
snmpget -v 1 -One -c public localhost .1.3.6.1.4.1.8072.1.3.2.3.1.2.10.100.101.118.105.99.101.46.109.102.114
snmpwalk -v 1 -c public 192.168.0.13 NET-SNMP-EXTEND-MIB::nsExtendOutputFull
snmpwalk -v 1 -One -c public localhost .1.3.6.1.4.1.8072.1.3.2.3.1.2
```

Example output:

```
.1.3.6.1.4.1.8072.1.3.2.3.1.2.7.117.112.115.46.109.102.114 = STRING: "American Power Conversion"
.1.3.6.1.4.1.8072.1.3.2.3.1.2.9.117.112.115.46.109.111.100.101.108 = STRING: "Smart-UPS X 750"
.1.3.6.1.4.1.8072.1.3.2.3.1.2.10.100.101.118.105.99.101.46.109.102.114 = STRING: "American Power Conversion"
.1.3.6.1.4.1.8072.1.3.2.3.1.2.10.117.112.115.46.115.101.114.105.97.108 = STRING: "AS1035120444"
.1.3.6.1.4.1.8072.1.3.2.3.1.2.10.117.112.115.46.115.116.97.116.117.115 = STRING: "OL"
.1.3.6.1.4.1.8072.1.3.2.3.1.2.11.100.114.105.118.101.114.46.110.97.109.101 = STRING: "usbhid-ups"
.1.3.6.1.4.1.8072.1.3.2.3.1.2.12.98.97.116.116.101.114.121.46.116.121.112.101 = STRING: "PbAc"
.1.3.6.1.4.1.8072.1.3.2.3.1.2.12.100.101.118.105.99.101.46.109.111.100.101.108 = STRING: "Smart-UPS X 750"
.1.3.6.1.4.1.8072.1.3.2.3.1.2.12.117.112.115.46.102.105.114.109.119.97.114.101 = STRING: "COM 03.6 / UPS 03.6"
.1.3.6.1.4.1.8072.1.3.2.3.1.2.12.117.112.115.46.109.102.114.46.100.97.116.101 = STRING: "2010/08/24"
.1.3.6.1.4.1.8072.1.3.2.3.1.2.12.117.112.115.46.118.101.110.100.111.114.105.100 = STRING: "051d"
.1.3.6.1.4.1.8072.1.3.2.3.1.2.13.100.101.118.105.99.101.46.115.101.114.105.97.108 = STRING: "AS1035120444"
.1.3.6.1.4.1.8072.1.3.2.3.1.2.13.117.112.115.46.112.114.111.100.117.99.116.105.100 = STRING: "0003"
.1.3.6.1.4.1.8072.1.3.2.3.1.2.14.98.97.116.116.101.114.121.46.99.104.97.114.103.101 = STRING: "100"
.1.3.6.1.4.1.8072.1.3.2.3.1.2.14.100.114.105.118.101.114.46.118.101.114.115.105.111.110 = STRING: "2.7.2"
.1.3.6.1.4.1.8072.1.3.2.3.1.2.15.98.97.116.116.101.114.121.46.114.117.110.116.105.109.101 = STRING: "45000"
.1.3.6.1.4.1.8072.1.3.2.3.1.2.15.98.97.116.116.101.114.121.46.118.111.108.116.97.103.101 = STRING: "54.4"
.1.3.6.1.4.1.8072.1.3.2.3.1.2.16.117.112.115.46.116.105.109.101.114.46.114.101.98.111.111.116 = STRING: "-1"
.1.3.6.1.4.1.8072.1.3.2.3.1.2.17.117.112.115.46.98.101.101.112.101.114.46.115.116.97.116.117.115 = STRING: "enabled"
.1.3.6.1.4.1.8072.1.3.2.3.1.2.18.98.97.116.116.101.114.121.46.99.104.97.114.103.101.46.108.111.119 = STRING: "10"
.1.3.6.1.4.1.8072.1.3.2.3.1.2.18.117.112.115.46.100.101.108.97.121.46.115.104.117.116.100.111.119.110 = STRING: "20"
.1.3.6.1.4.1.8072.1.3.2.3.1.2.18.117.112.115.46.116.105.109.101.114.46.115.104.117.116.100.111.119.110 = STRING: "-1"
.1.3.6.1.4.1.8072.1.3.2.3.1.2.19.98.97.116.116.101.114.121.46.114.117.110.116.105.109.101.46.108.111.119 = STRING: "150"
.1.3.6.1.4.1.8072.1.3.2.3.1.2.19.100.114.105.118.101.114.46.118.101.114.115.105.111.110.46.100.97.116.97 = STRING: "APC HID 0.95"
.1.3.6.1.4.1.8072.1.3.2.3.1.2.20.100.114.105.118.101.114.46.102.108.97.103.46.112.111.108.108.111.110.108.121 = STRING: "enabled"
.1.3.6.1.4.1.8072.1.3.2.3.1.2.21.100.114.105.118.101.114.46.112.97.114.97.109.101.116.101.114.46.112.111.114.116 = STRING: "auto"
.1.3.6.1.4.1.8072.1.3.2.3.1.2.22.98.97.116.116.101.114.121.46.99.104.97.114.103.101.46.119.97.114.110.105.110.103 = STRING: "50"
.1.3.6.1.4.1.8072.1.3.2.3.1.2.23.98.97.116.116.101.114.121.46.118.111.108.116.97.103.101.46.110.111.109.105.110.97.108 = STRING: "48.0"
.1.3.6.1.4.1.8072.1.3.2.3.1.2.23.100.114.105.118.101.114.46.118.101.114.115.105.111.110.46.105.110.116.101.114.110.97.108 = STRING: "0.38"
.1.3.6.1.4.1.8072.1.3.2.3.1.2.25.100.114.105.118.101.114.46.112.97.114.97.109.101.116.101.114.46.112.111.108.108.102.114.101.113 = STRING: "30"
.1.3.6.1.4.1.8072.1.3.2.3.1.2.29.100.114.105.118.101.114.46.112.97.114.97.109.101.116.101.114.46.112.111.108.108.105.110.116.101.114.118.97.108 = STRING: "2"
```
