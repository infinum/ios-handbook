## Certificates

Certificates are part of the app development process called Code Signing.

When you registered as a developer for the iOS Developer Program you received an option to create a personal development certificate.

If you haven't created it, the process is pretty straightforward.

1. Open up the Keychain Access app
2. Under menu select Keychain Access -> Certificate Assistant -> Request a Certificate from the Certificate Authority
3. In the Certificate Assistant dialog populate the neccesary fields and choose to save the request to disk
4. Open up your favorite browser and go to the [developer.apple.com][1]
5. Log in to the Member Center  
6. Go to the Certificates, Identifiers & Profiles -> Certificates
7. Under Certificates - Development choose to add a new development profile (hint: the magical plus sign [+])
8. In the certificate creation dialog choose iOS app development for the certificate type, and click continue until "Generate" section in which you upload the "certificate signing request" file which you have generated in the step #3
9. The last step is downloading and opening the generated certificate file
10. Check your Keychain app for your personal ADP certificate!

It can be seen in the Keychain app under "My Certificates" section.

![Personal certificate][image-1]

The main part of the certificate is your public/private key pair with which you guarantee that the apps are truly developed/distributed by you.

This is of key importance when distributing the apps, no matter whether the distribution target is App store or In-House distribution.

We at Infinum have two different Apple Developers Program accounts, one for App store distribution (Infinum d.o.o) and the other one, enterprise account (Infinum D.O.O.), for In-House distribution.

## Provisioning profiles

To understand the provisioning profiles there are few more things to knowhow.

### App ID

The app id uniquely identifies the app among all other apps. The App ID string contains two parts separated by a period (.)—an App ID Prefix that is defined as your Team ID by default and an App ID Suffix that is defined as a Bundle ID search string.

Bundle ID is created following the reversed URI convention. For app named "My App" the bundle id could be defined as com.infinum.my-app

### Device UDID

To run the development app on the device, the device should be addded to the developer's portal also. Device UDID is the identifier which, like App ID for apps, uniquely identifies the device.

### Provisioning profile sumup

The provisiong profile binds the App ID to the device UDID(s) and Code Signing identity and enables us to run or install the apps on the devices with UDIDs that are added to the developers portal.

When you create a provisioning profile, you're basically associating the iOS devices you have listed in the Provisioning Portal with the certificate signed by Apple in the previous step. The result of that is a .mobileprovision file, that is used during the compilation process of an iOS app, and also needs to be deployed to the device. To install this provisioning profile, simply download it and double-click it: XCode will automatically add it to the list of provisioning profiles in the Organizer.

### Provisioning profile types

When describing the provisioning profiles types there are a few things that should be kept in mind. There is a difference between a regular ADP and the enterprise one (ADEP). As the enterprise one is used for In-House development only the provisioning profiles types which can be generated are iOS development, Ad Hoc and In House.

#### In House distribution

In House distribution is a way of distributing the apps apart from the App Store. As we have both the ADP and ADEP, this kind of distribution is commonly used for sending test builds to the clients. Prerequisites in the developer's portal are:

1. generated App ID
2. generated Distribution provisioning profile (select In House distribution when prompted)
3. provisioning profile downloaded, opened in XCode
4. In the Build Settings under Code Signing select the created provisioning profile under Release section

#### Ad Hoc

For the regular ADP the provisioning profile types which can be chosen are Development, Ad Hoc and App Store.

Ad Hoc profiles are used to distribute the app for the devices which are chosen while generating the certificate. So the devices on which the app should run are predetermined and should be pre-added to the developers portal.

Another common way of sending the builds directly to clients can be TestFlight for which the App Store provisioning profile type is used, and the build is directly uploaded to the app store.

## APNS

For the iOS platform push notifications are available through the APNS server. To communicate with the APNS server the SSL certificates are also needed. They can be generated using the developer's portal under the section "Certificates". You will probably need both the development and the production APNS certificates.


![APNS Dev certificate][image-2]


The attached image displays the generation of an APNS development certificate. After continuing the App ID for the target app should be selected and the certificate signing request should be uploaded; again the process is the same as with generating personal certificate:

1. Open up the Keychain Access app
2. Under menu select Keychain Access -> Certificate Assistant -> Request a Certificate from the Certificate Authority
3. In the Certificate Assistant dialog populate necessary fields and choose to save the request to disk
4. Upload the CSR to developers portal

After completing the CSR upload save the APNS SSL certificate to disk (it can be seen in the Keychain App).

Generating APNS Production certificates is very similar, all you have to do is choose "Production" under "Certificates" and in the "Select type" step choose Apple Push Notification service SSL (Production). The following steps are same as for the Sandbox SSL certificate generation.

The certificates will be used by the API which will be responsible for initiating push notification messages.

[1]:	https://developer.apple.com

[image-1]:	/img/iOS-certificates-keychain.png
[image-2]:	/img/iOS-certificates-apns.png