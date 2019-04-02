# field-inspection-app-ios
Field Inspection App for iOS

## Prerequisites

A machine with up to date MacOSX
A modern iPhone with up to date iOS
Xcode

## Setup

### Development

Install the Cocoapods dependency management system:

```console
sudo gem install cocoapods
```

Use Cocoapods to install the project dependencies:

```console
sudo gem update
pod install
```

## Distribution

The app is distributed via the AirWatch Enterprise App Store; this is a private internal app store available to all BC Government mobile devices.

Each Ministry has delegate personnel who have the permissions to create, update and deploy apps to AirWatch. If you don't know who the delegate is please contact the MDSM (device management team).

In order to distribute via AirWatch the app must be signed with the BC Government Enterprise Certificate. The following steps will guide you through the build, signing, and deployment of your application.

__Build__

Create an `Archive` built in Xcode. When done the `Organizer` appears right-click on the newly minted build and select `Show in Finder`. A new finder window will open; Option + Drag the `xcarchive` to your desktop.

__Options__

In this project there is an `options.plist` file; this contains the enterprise options you normally select when, in the Organizer, you choose to to do an enterprise distribution.
There is a `Parse.plist` file which also must be configured to point to the specific parse server that you wish this particular build to point to (located at ./parse-config/prod/Parse.plist).  eg: 

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>ParseAppId</key>
	<string>xxxxxxx</string>
	<key>ParseClientKey</key>
	<string>xxxxxx</string>
	<key>ParseServer</key>
	<string>https://projects.eao.gov.bc.ca/parse</string>
</dict>
</plist>
```
Also make sure that the Copy Bundle Resources step in the Build Phases points to this particular Parse.plist file.

Copy the `options.plist` to your desktop.

__Packaging__

Create a folder on your desktop with a name similar to `eao-field-build-142`; the name itself is not important but is descriptive enough to debug if needed.

Copy both the `xcarchive` and `options.plist` into the newly created folder and compress / zip the folder. You should now have an archive called something like `eao-field-build-142.zip` on your desktop.

__Signing__

To sign your application with the BC Government certificate navigate to the Mobile Signing Tool from the BC Government's [DevHub](https://developer.gov.bc.ca/?q=mobile). Follow the instructions provided on the Mobile Signing Tool website.

Before yo can use the tool you must:
1. Get a BC Gov IDIR account;
2. Contact the Mobile Signing Tool admin(s) and have your IDIR granted permission to use the tool.
3. Your apple ID must be registered with the enterprise team @ BCGov
4. You must select the enterprise team: "Govt. of The PRonvice of BC - Ministry of Labour & Citizen's Services & Open Govt"
5. Make sure your build version has been increased since the last time you submitted a build.

__Deploy__

The final step is to take the signed `IPA` provided by the Mobile Signing Tool and give it to your Ministry delegate to upload to AirWatch. If you don't know how this process works contact the MDMS team (the people who provision mobile devices and operate AirWatch) to find out who this person is.

## Project Status / Goals / Roadmap

This project is **active**.

Progress to date, known issues, or new features will be documented on our publicly available Trello board [here](https://trello.com/b/HGJpxQdS/mobile-pathfinder).

## Getting Help or Reporting an Issue

This is an internal app intended for s specific team to use. If you're using this app please contact the internal representative for assistance.

## How to Contribute

_If you are including a Code of Conduct, make sure that you have a [CODE_OF_CONDUCT.md](SAMPLE-CODE_OF_CONDUCT.md) file, and include the following text in here in the README:_
"Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms."

## License

Detailed guidance around licenses is available
[here](/BC-Open-Source-Development-Employee-Guide/Licenses.md)

Attach the appropriate LICENSE file directly into your repository before you do anything else!

The default license For code repositories is: Apache 2.0

Here is the boiler-plate you should put into the comments header of every source code file as well as the bottom of your README.md:

    Copyright 2019 Province of British Columbia

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

For repos that are made up of docs, wikis and non-code stuff it's Creative Commons Attribution 4.0 International, and should look like this at the bottom of your README.md:

<a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons Licence" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/80x15.png" /></a><br /><span xmlns:dct="http://purl.org/dc/terms/" property="dct:title">YOUR REPO NAME HERE</span> by <span xmlns:cc="http://creativecommons.org/ns#" property="cc:attributionName">the Province of Britich Columbia</span> is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by/4.0/">Creative Commons Attribution 4.0 International License</a>.

and the code for the cc 4.0 footer looks like this:

    <a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons Licence"
    style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/80x15.png" /></a><br /><span
    xmlns:dct="http://purl.org/dc/terms/" property="dct:title">field-inspection-app-ios</span> by <span
    xmlns:cc="http://creativecommons.org/ns#" property="cc:attributionName">the Province of Britich Columbia
    </span> is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by/4.0/">
    Creative Commons Attribution 4.0 International License</a>.

[export-xcarchive]: https://github.com/bcdevops/mobile-cicd-api/raw/develop/doc/images/export-xcarchive.gif 'Prepare & Export xcarchive'

