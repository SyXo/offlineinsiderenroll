OfflineInsiderEnroll
--------------------

### Description
OfflineInsiderEnroll is a simple Windows Command Prompt script to enable access
to the Windows Insider Program on machines not signed in with Microsoft Account.

This script is compatible only with Windows 10 RS5 and later.

### Usage
This script requires administrative priviliges to run. You can simply execute it
by right clicking it > `Run as Administrator`.

#### Installation and configuration changes
After starting the script offers selection of *Windows Insider Program* rings.
To make a selection, press a letter coresponding to option you choose and press
ENTER.

If the machine was not enrolled to the Insider Program, you will get prompted to
restart your machine to enable *Microsoft Flight Signing* which is required by
*Windows Insider Program*.

**Notice:** Windows Insider Program requires telemetry to be set to *Full*.
This script changes your telemetry settings to reflect this during the process
of enabling *Windows Insider Program* access. If you have used any "privacy"
scripts or changed *Allow telemetry* via Group Policy, changes made by this
script may not get reflected and you may not be able to receive *Insider
Preview* builds using Windows Update.

#### Restoring Windows Insider Program to default options
To restore *Windows Insider Program* to default settings simply choose `Stop
receiving Insider Preview builds` in OfflineInsiderEnroll. You will get prompted
to reboot, because this option will disable *Microsoft Flight Signing*.

### How does this work?
This script takes advantage of undocumented `TestFlags` registry value.
If this value is set to `0x20`, all access to online *Windows Insider* services
gets disabled. Because of this, we can set our own *Windows Insider Preview*
configuration without being overriden by the contact to the service. Since
Windows Update does not check if machine is actually enrolled to the program,
you will get offered *Insider Preview* builds by just setting correct values in
the registry.

### License
This project is licensed under the MIT License. See `LICENSE` for details.
