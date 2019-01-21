# field-inspection-app-ios
Field Inspection App for iOS

## Prerequisites

A machine with up to date MacOSX
A modern iPhone with up to date iOS
Xcode

## Setup


### Apple dev account

Create an apple dev account with your itunes credentials at https://developer.apple.com/account/#/welcome.

Make a provisional profile such that you can deploy to other devices.

### Development

Navigate to the project folder, open EAO.xcworkspace with Xcode.

We want to sign in with our own account

Xcode, preferences, accounts, appleid
your.itunes.account@gov.bc.ca

In Xcode click on the EAO folder, the EAO settings, check automatically manage signing
Change to my personal team
Change bundle idenfier to anything other than what's there, for example
eao.apps.gov.bc.ca

Then do the same for the test build.

Obtain parse-config files from this repo maintainer and extract the contents to the EAO/EAO/Resources/Test folder and the EAO/EAO/Resources/Prod folder.

On your developer Mac, cd into your project root directory via the terminal and run the following commands to set up your environment:

```

sudo gem install cocoapods
sudo gem update
pod install

```

## Deploy the app onto a phone

Connect the device you want to push onto, up at the very top, change the emulated devices to your actual phone (scroll to the top of the list of devices).

Select the build you wish to deploy to your phone (test or prod).  Use Test if you're not sure.

Hit the play button top left.  The app will appear on your phone.

To log in you will require a user from the parse server.

On the phone, you may need to give permissions to the app prior to running it.  Try to run the app, if it gives an error about permissions, go grant permissions via

Settings, General, Device Management.


## Release the app

For your changes to be deployed out to users automatically, get your application updated in BC Gov AirWatch.
