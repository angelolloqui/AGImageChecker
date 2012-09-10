AGImageChecker
==============


[AGImageChecker](https://github.com/angelolloqui/AGImageChecker) is lightweight iOS library that helps developers to find problems in their used images. It detects when images are smaller or different sized than their container views, producing resized or blurry images. Wrong images will have a colorfull border that helps you to detect them. Additionally, it adds a long press gesture to open an image detail and check useful information about the problem, such as the image size, the view size, the contentMode, the presence of retina version, the associated view controlller,… All of it out of the box, without changing your code (device and simulator).

![AGImageChecker screenshot](http://angelolloqui.com/images/projects/AGImageChecker_Screenshot1.png)
&nbsp; ![AGImageChecker detail view](http://angelolloqui.com/images/projects/AGImageChecker_Detail2.png)


Usage
-----

Before you start make sure the `DEBUG` environment variable is set.  AGImageChecker will not work without it to prevent undesired release use.

Add the `AGImageChecker/src` files to your project and add the QuartzCore framework (if not present).  

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

Long press on an image view to open the image detail.


Design
------

AGImageChecker relies on Method Swizzling to hook the checking code into UIImageView when the frame, contentMode or image is changed. It was initilly thought to use `drawRect`, but UIImageView is very particular and do not call this method. All this checking logic, as well as the method swizzling can be found on the category `UIImageView+AGImageChecker` distributed within the lib.

Nevertheless, developers that only want to use the lib should only use the AGImageChecker class, which is responsable of connecting all the piceses together (checking, drawing, and interaction). This class follows a Singleton pattern, and it needs the RootViewController to be set before the start method is called. You should first stop the checker before changing the root controller. If no root controller is set, it tries to use the main window root view controller (if set).

Future versions will add a plugin architecture to be able to present issues in very different ways as well as export them easily by email or similar ways.


Special considerations
----------------------

* In order to display the image name, it uses the `accessibilityLabel` of the `UIImageView`, which is automatically set on images using Interface Builder. If you want your remote images or programatically loaded images to work properly, please ensure the `accessibilityLabel` is correctly set.

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
