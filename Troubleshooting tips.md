## My app will not start on my device when installed from Labs

One particular office iPhone 5 had too many provisioning profiles installed
for iOS to parse through within the 20 second launch window, so Springboard
would prematurely terminate the app.

You may have too many provisioning profiles installed for iOS to handle.

Delete all of the profiles by going to

* Xcode
* Window
* Devices
* Select device
* Tap gear icon at bottom left
* Select 'Show Provisioning Profiles'
* Delete each profile one by one by alternately pressing the delete key and down repeatedly

Alternatively use UI Automation to delete the profiles from this preference pane
while you make & enjoy a nice cup of joe.

This is only an issue for Enterprise-signed apps.

Then re-download the app from labs to reinstall its provisioning profile.

[Credit](http://stackoverflow.com/a/33045154)
