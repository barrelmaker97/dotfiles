# Network UPS Tools (NUT) Configuration Guide

This guide covers the steps to set up a headless UPS monitoring server using the Network UPS Tools (NUT) suite. NUT is an extensible and highly configurable client/server application for monitoring and managing power sources. It includes:

- **Hardware-specific drivers**
- **A server daemon (`upsd`)**
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

*Note: Keep the name "ups" for usage with Synology DSM.*

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

The `upsd` daemon is responsible for serving data from the drivers to the clients.
To configure it, add a `LISTEN` directive to the `/etc/nut/upsd.conf` file to bind `upsd` to port 3493:

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
systemctl status nut-server
systemctl status nut-client
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
battery.charge.warning: 20
battery.mfr.date: CPS
battery.runtime: 5900
battery.runtime.low: 300
battery.type: PbAcid
battery.voltage: 27.4
battery.voltage.nominal: 24
device.mfr: CPS
device.model: CP1500PFCLCDa
device.serial: CXXKT2000911
device.type: ups
driver.debug: 0
driver.flag.allow_killpower: 0
driver.name: usbhid-ups
driver.parameter.pollfreq: 30
driver.parameter.pollinterval: 2
driver.parameter.port: auto
driver.parameter.synchronous: auto
driver.state: quiet
driver.version: 2.8.1
driver.version.data: CyberPower HID 0.8
driver.version.internal: 0.52
driver.version.usb: libusb-1.0.27 (API: 0x100010a)
input.voltage: 120.0
input.voltage.nominal: 120
output.voltage: 120.0
ups.beeper.status: enabled
ups.delay.shutdown: 20
ups.delay.start: 30
ups.load: 5
ups.mfr: CPS
ups.model: CP1500PFCLCDa
ups.productid: 0601
ups.realpower.nominal: 1000
ups.serial: CXXKT2000911
ups.status: OL
ups.test.result: No test initiated
ups.timer.shutdown: -60
ups.timer.start: -60
ups.vendorid: 0764
```

---

## 9. Configure Remote Clients

### 9.1 Linux

To set up a Linux client:

1. Install the NUT client:

    ```bash
    sudo apt update
    sudo apt install nut-client
    ```

2. Edit `/etc/nut/nut.conf` to set the mode:

    ```ini
    MODE=netclient
    ```

3. Edit `/etc/nut/upsmon.conf` to monitor the UPS:

    ```ini
    MONITOR ups@192.168.0.13 1 upsmon_remote hunter2 secondary
    ```

4. Start the NUT client:

    ```bash
    sudo systemctl start nut-client
    ```

5. Verify the UPS status:

    ```bash
    upsc ups@192.168.0.13
    ```

### 9.2 Synology Diskstation

Synology DSM uses NUT to manage and share UPSes. The NUT UPS name and the username/password for the NUT client in DSM can't be set in the GUI, but the config we created earlier is set to match what DSM expects, so there is no need to modify anything over SSH unles you want to.
DSM looks for the "ups" UPS entry in /etc/nut/ups.conf and uses the monuser/secret username/password pair that we created in the /etc/nut/upsd.users file.

1. In DSM, go to **Control Panel > Hardware and Power > UPS**.
2. Configure the following:

    - **Enable UPS support**: Yes
    - **Network UPS type**: Synology UPS server
    - **Network UPS server IP**: `192.168.0.13`

3. Click **Save** and then **Device Information** to verify the connection.

---

## 10. Test the NUT Server

It's essential to test the server behavior in a power outage scenario:

1. To simulate a power outage, run:

    ```bash
    upsmon -c fsd
    ```
*Note: If the UPS is connected to mains, the server will stop and then restart (don't forget to set your BIOS power management to "Always on"). If the UPS is unplugged, the server will restart only after reconnection to mains.*

2. Monitor logs:

    ```bash
    tail -f /var/log/syslog
    ```

3. View UPS status messages:

    ```bash
    upslog -s ups -l -
    ```

---

Congratulations! Your NUT server is now fully configured and operational.
