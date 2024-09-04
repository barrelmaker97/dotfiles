# Network UPS Tools (NUT) Configuration Guide

This guide covers the steps to set up a headless UPS monitoring server using the Network UPS Tools (NUT) suite. NUT is an extensible and highly configurable client/server application for monitoring and managing power sources. It includes:

- **Hardware-specific drivers**
- **Server daemon (`upsd`)**
- **Client tools like `upsmon` and `upsc`**

More information on NUT can be found on the [official website](http://networkupstools.org) and the [user manual](https://networkupstools.org/docs/user-manual.chunked/ar01s06.html).

---

## 1. Check UPS Connection

First, verify that the UPS is visible on the USB interface:

```bash
lsusb
```

You should see the UPS listed in the output:

```bash
Bus 001 Device 004: ID 0764:0601 Cyber Power System, Inc. PR1500LCDRT2U UPS
```

---

## 2. Install NUT

Install the NUT server and client packages:

```bash
sudo apt install nut
```

---

## 3. Create UPS Entry

Edit the `/etc/nut/ups.conf` file and add the following section at the bottom:

```ini
[ups]
  driver = usbhid-ups
  port = auto
  desc = "Main UPS"
```

Within the bracket, set the UPS name (no space allowed) but keep the name "ups" for easier usage with Synology DSM.

Test the UPS driver by running:

```bash
sudo upsdrvctl start
```

Expected output might include:

```bash
Network UPS Tools - UPS driver controller 2.8.1
Network UPS Tools - Generic HID driver 0.52 (2.8.1)
USB communication driver (libusb 1.0) 0.46
Duplicate driver instance detected (PID file /run/nut/usbhid-ups-ups.pid exists)! Terminating other driver!
Using subdriver: CyberPower HID 0.8
```

*Note: If you don't see this output, a reboot might resolve the issue.*

---

## 4. Configure `upsd`

The `upsd` daemon is responsible for serving data from the drivers to the clients. To configure it:

1. Edit the `/etc/nut/upsd.conf` file.
2. Add a `LISTEN` directive at the end to bind `upsd` to port 3493:

    ```bash
    LISTEN 0.0.0.0 3493
    ```

---

## 5. Configure Users

To manage access to `upsd`, edit the `/etc/nut/upsd.users` file and add the following:

```ini
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

---

## 6. Configure `upsmon`

Next, configure the `upsmon` client by editing the `/etc/nut/upsmon.conf` file. Add the UPS to be monitored and the user credentials for `upsd`:

```ini
MONITOR ups@localhost 1 localuser hunter2 primary
```

---

## 7. Start NUT Services

Edit `/etc/nut/nut.conf` and set the mode:

```ini
MODE=netserver
```

Restart the NUT services:

```bash
sudo systemctl restart nut-server
sudo systemctl restart nut-monitor
```

---

## 8. Verify Configuration

Check the status of the NUT server and client services:

```bash
service nut-server status
service nut-client status
```

Test the configuration with:

```bash
upsc ups
```

Expected output might include details like:

```bash
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

---

## 9. Configure Remote Clients


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

DSM looks for the "ups" UPS entry in /etc/nut/ups.conf and uses the monuser/secret username/password pair that we created in the /etc/nut/upsd.users file.

Click save and then the Device Information button to verify that the connection works as expected.

---

## 10. Test the NUT Server


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
