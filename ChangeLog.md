V.1.0.1 - 18/04/2013
=======
Update with small bug fixes and custom colors
- Added option to use custom colors in Base Plugin
- Fixed problem with ARC retaining BOOL swizzled value
- Fixed problem stopping image checker in runtime
- Fixed problem with path in dropbox (iOS6)

V.1.0.0 - 27/09/2012
=======
Official first release of the AGImageChecker library. Includes the following changes:
- Changed precompilation flag used to AGIMAGECHECKER. It defaults to DEBUG if no defined
- Automatic Accesibility enabled on load for both Device and Simulator
- Refactored gestures to detect touches on window instead of root view controller
- Added Dropbox button to upload original image
- Small general improvements
- Added new tests and code coverage in Test target
- Uncrustified code

V.0.0.2 - 21/09/2012
=======
Refactored the library to add plugin funcionality. Added the following features:
- Added new missalignment issue that checks for incorrect parent alignment
- Dropbox plugin to connect, upload and download images to your Dropbox account
- Check already loaded images when starting AGImageChecker
- Added loaded image name to UIImage
- Log of missing images into console
- Performance improvements

V.0.0.1 - 11/09/2012
=======
Basic ImageChecker funcionality including:
 - Simple detail
 - Missing images, stretched images, resized images and blurry images
 - Unit testing of all the core funcionality
