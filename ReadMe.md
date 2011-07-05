XMGradientPanel
==============

A drop-in Gradient Panel for Mac apps.

![XMGradientPanel](http://www.machinecodex.com/media/XMGradientPanel.png)

Introduction
----------------

Cocoa has offered the very useful `NSGradient` class since Leopard - but we still have no standard way to present a picker UI so users can select a gradient. Ideally, a gradient picker should work similarly to an `NSColorPanel` to conform to Mac OS X conventions. 

Our goal is to fill this gap with a standard, open-source set of gradient control views, including a well, a panel and a picker. These controls use target-action based interfaces to pass an `NSGradient` back to your app.

The aim is to make a flexible panel that can support multiple picker views. At present, there is a linear picker view (pictured above).

`XMGradientWell` creates and manages an application's shared gradient panel. It also supports drag-and-drop of `NSGradient` objects between wells.

`XMGradientPanel`, a subclass of `NSPanel`, hosts the picker view. It also manages a set of preset gradients which are stored in a file in your app's Application Support folder.

`XMGradientPicker` is an abstract picker superclass that can be subclassed to create new pickers.

`XMGradientPickerLinear` is the concrete picker subclass currently used by XMGradientPanel.

Setup
-----

Simply add the XMUIKit classes to your project.

Usage
-----

You can configure an XMGradientPanel very simply by adding an `XMGradientWell` custom view to your interface in IB and connecting it to an outlet in your controller class. The gradient well will automatically create and manage the gradient panel.

Then, to configure the gradient well, you might add the following code to `awakeFromNib` or `applicationDidFinishLaunching:`:

    [gradientWell setGradient:someGradient];
    [gradientWell setTarget:self];
    [gradientWell setAction:@selector(setGradient:)];

To set a gradient value, you would implement the selector action something like this:

    - (IBAction) setGradient:(id)sender {

        [gradientView setGradient:[sender gradient]];
    }

Please refer to the example project for more detail on how to use XMGradientPanel in your app.

Example Project
---------------
A simple example project is included.

Status
--------

XMGradientPanel should be considered an alpha project. There are many aspects that need improving, but it works!

Attribution
-----------

`XMGradientPicker` is cribbed pretty much verbatim from `KTGradientPicker` from `KTUIKit`. Thanks to the KTUIKit developers for the fantastic framework.
http://code.google.com/p/ktuikit/

Copyright and License
-------------------------------

Copyright 2011 MachineCodex Software 

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this work except in compliance with the License. You may obtain a copy of the License in the LICENSE file, or at:

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.