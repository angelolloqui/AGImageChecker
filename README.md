AGImageChecker
==============


[AGImageChecker](https://github.com/angelolloqui/AGImageChecker) is a lightweight iOS library that helps developers to find problems in their used images. It detects when images are smaller or different sized than their container views, producing resized or blurry images. Wrong images will have a colorfull border that helps you to detect them. Additionally, it adds a long press gesture to open an image detail and check useful information about the problem, such as the image size, the view size, the contentMode, the presence of retina version, the associated view controlller,… All of it out of the box, without changing your code (device and simulator).

![AGImageChecker screenshot](http://angelolloqui.com/images/projects/AGImageChecker_Screenshot1.png)
&nbsp; ![AGImageChecker detail view](http://angelolloqui.com/images/projects/AGImageChecker_Detail2.png)

Its plugin architecture allows developers to easily add funcionality to the library. For example, the Dropbox plugin, which provides Dropbox synchronization capabilities to export and import images into your project on runtime and speed up communication with designers. 


Installation
------------

1. Add the `AGImageChecker/src` files to your project
2. Remove unwanted plugins into the plugin folder. The `base` plugin should be there if you want the basic AGImageChecker functionality.

Plugins may have additional installation instructions. Check out the plugin details at the bottom of the document.

Note: AGImageChecker by default works if your `DEBUG` environment variable is set. If you want to use AGImageChecker in a Release enviroment (not recommended) define `AGIMAGECHECKER` environment variable into the "Preprocessor Macros" in your project build settings. Because AGImageChecker makes heavy use of Method Swizzling and adds some overhead to your app, its use in a distribution environment is completely discouraged. 


Usage
-----

To activate the AGImageChecker, add something like the following into your code (normally in your AppDelegate):

``` objective-c    
    #import "AGImageChecker.h"
```

``` objective-c    
	#if DEBUG
    	[[AGImageChecker sharedInstance] setRootViewController:self.tabRootController];
	    [[AGImageChecker sharedInstance] start];
	#endif
```

The `#if` to target only Debug releases is not required but is a good practice because it will save some unuseful calls in release mode. The root view controller should be set to your main view controller in the app, usually a tabbar.

Once setup, you will see borders of different colors on images with issues. The main colors are:

* Yellow: Images that are resized, blurry or partially hidden
* Orange: Images that are stretched
* Red: Missing images

Long-pressing on an image view will open an image detail screen.

Other plugins may need addittional settings to work. Check out the plugin details at the bottom of the document.


Design
------

AGImageChecker's core relies on Method Swizzling to hook code for:
- Adding information about the loaded `UIImage` setting a `name` property 
- Checking `UIImageView` when the frame, contentMode or image is changed
It was initially thought to use `drawRect`, but `UIImageView` is very particular and do not call this method. All this checking logic, as well as the method swizzling can be found on the categories `UIImageView+AGImageChecker` and `UIImage+AGImageChecker` distributed within the lib.

Apart from Method Swizzling, one interesting thing to note is that the library is designed with a plugin architecture. `AGImageCheker` class will query plugins by using `AGImageCheckerPluginProtocol`. Plugins can be added or removed into the AGImageChecker on runtime.
`AGImageChecker` class follows a Singleton pattern, and it needs the RootViewController to be set before the start method is called. You should first stop the checker before changing the root controller. If no root controller is set, it tries to use the main window root view controller (if set).


Plugins
-------

### Base plugin


Performs the checking logic and displays the image information in the image detail view. 

- Installation notes

Needs `QuartzCore` framework


### Dropbox plugin


Provides an easy way to share the app images with external teams such as designers. Images can be uploaded and downloaded from your Dropbox account on runtime by clicking a button on the image detail view.

- Installation notes

Needs Dropbox SDK. Dropbox framework is provided inside the plugin `external` folder and needs `Security` and `QuartzCore` frameworks to run.

- Usage notes

In order to run the plugin, add the following code before starting your AGImageChecker library:

``` objective-c    
#import "AGImageCheckerDropboxPlugin.h"
```

``` objective-c    
[AGImageCheckerDropboxPlugin addPluginWithAppKey:@"your app key" appSecret:@"your app secret"];
```

- Other notes

Some changes have been added on top of the Dropbox SDK to provide an easier integration without the need of adding a URL scheme to your app or handling the open url action. If you already have Dropbox in your project for other uses, there is no guarantee that everything will continue working if you use this plugin.


Special considerations
----------------------

* In order to display the image name, it uses the `accessibilityLabel` of the `UIImageView`. The lib will activate Accessibility in your app to allow automatic accessibility labels to be set, even in your Interface Builder, without changing your code. However, if you want your remote images or programatically loaded images to work properly, please ensure the `accessibilityLabel` is correctly set.

* In order to display the associated controller of an image view, it checks the `nextResponder` chain until it finds an object which is not the superview. This means that it could display information that is not fully accurate, but still should be helpful.

* The lib has been developed using TDD from the very begining (SenTest + OCMock). Please, if you plan to add funcionality take extra time to add the correct tests to it. 


License
-------

Made available under the MIT License.


Collaboration
-------------

Forks, patches and other feedback are always welcome.


Credits
-------

AGImageChecker is brought to you by [Angel Garcia Olloqui](http://angelolloqui.com). You can contact me on:

Project Page: [AGImageChecker](https://github.com/angelolloqui/AGImageChecker)

Personal webpage: [angelolloqui.com](http://angelolloqui.com)

Twitter: [@angelolloqui](http://twitter.com/angelolloqui)

LinkedIn: [angelolloqui](http://www.linkedin.com/in/angelolloqui)
