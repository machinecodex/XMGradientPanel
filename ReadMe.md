XMGradientPanel
==============

A drop in Gradient Panel for Mac OS X

Introduction
----------------

Cocoa has offered the very useful NSGradient class since Leopard, but we still have no standard way to present a picker UI so users can choose a gradient in a standard way, analagous to NSColorPanel and NSColorWell.
Our aim is to fill this gap with a standard, open-source set of controls to fill this role.
Please feel free to fork or contribute!

Setup
--------

Simply add the XMUIKit classes to your project.

Usage
---------

The aim is to make a flexible panel that can support multiple picker views. There is some serious refactoring necessary before this can become a reality. At present, there is a single picker, which uses simple target-action methods to set values. 

XMGradientPanel stores a set of preset gradients as a file in the Application Support folder.

Please refer to the extremely simple example project for more information.

Example Project
-----------------------
A simple example project is included.

Status
--------

XMGradientPanel should be considered an alpha project.

Attribution
-----------

XMGradientPicker is cribbed pretty much verbatim from KTGradientPicker from KTUIKit. Thanks to the KTUIKit developers for the fantastic framework.
http://code.google.com/p/ktuikit/

Copyright and License
-------------------------------

Copyright 2011 MachineCodex Software 

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this work except in compliance with the License. You may obtain a copy of the License in the LICENSE file, or at:

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.