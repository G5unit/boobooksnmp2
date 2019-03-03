# boobooksnmp2
___Mac OS X native cocoa UI for SNMP utilities and MIB browser___


## Pre-release 1.2.1
* Updated project to include MMTabBarViewController code and compile inside the project as target dependency.
* Update code & project to compile for macOS 10.13 and higher.
* Added Menu Items
* Added libnetsnmp version detection at startup.
* Added /usr/local/lib to LIBRARY SEARCH PATH so custom installations of libnetsnmp are used first (vs one that comes with macOS).


## Release 1.0
* First release


## About
Boobooksnmp2 is a OSX Graphical interface that uses libnetsnmp to display and query SNMP Objects. Main Features are:
- Ability to read in mass of MIB files and display Objects in Tree format
- Bookmarks of Objects, Agents, URLs
- Provides easy access to file Object was read from
- Simultaneous execution of multiple SNMP requests
- Fast, responsive, written in Cocoa Objective-C with some C code
- Uses libnetsnmp for SNMP operations
- Can set log level (Emergency,Critical,...,Debug) reported by libnetsnmp when parsing(reading in) MIB files

__Aims To Accomplish__

Boobooksnmp2 aims to provide a flexible interface to many tasks involved
with SNMP. A fast loading application that can handle thousands of MIB
files at a snap, be able to search for Objects by string,
provide bookmark functionality, and snmp functions such as get,
walk, set.

- [Binary Release available under Releases](https://github.com/G5unit/boobooksnmp2/releases)

- See wiki for [Getting started with the boobooksnmp2](https://github.com/G5unit/boobooksnmp2/wiki)

