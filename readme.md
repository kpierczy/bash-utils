# Welcome to the bash-utils library!

This project provides a set of simple yet useful tools for developers working in the Linux environment on a regular basis. It consists of two main parts:
  - a library of functions and aliases designed to speed up process of creating bash scripts; there are also some tools aimed to be used directy from the command line - these are mainly related to software used by the author
  - a set of scripts performing tasks that have popped out suprisingly often in the author's work over past few years
The project has been developed on the Ubuntu 20.04LTS syste with bash in version 5.0.17, bu as far as the author knows it should play well with bash in versions not lower than 4.3.

# Content                                                                                 

`.vscode` - bash-utils is developed using Visual Studio Code. This directory is not a core part of the library but provides my current configuration of the environment. I leave it here with hope that some of extensions that I use will turn out to be helpful also in your daily routine!

`bin` - bash script implementing simple configuration/installation routines
 - `bin/install` - scripts automating installation of various software
 - `bin/install/buildtools` - first of all you will find there a script (or maybe better call it 'micro framework') automating installation of the GCC toolchain including bashutils, GCC compiler, glibc/newlib library and GDB debugger from source. Enjoy! (Although if you are used to generate from-soruce toolchains regularly explore Buildroot :) )
 - `bin/install/libraries` - from-soruce installation scripts for some popular libraries. At the moment Boost library is supported
 - `bin/install/ros` - installation scripts for ROS in the lates versions

`dep` - project's dependencies
`doc` - mainly authore's notes containing set of Internet sources that turned out to be usefull during development of the project

`lib` - library of usefull bash functions and aliases
 - `lib/debug` - tools related to debugging bash scripts
 - `lib/files` - general file-manipulation tools
 - `lib/logging` - small logging framework (with colours!)
 - `lib/processing` - my little attempt to make bash language more programmers-friendly
 - `lib/programs` - set of tools related to installation and inspection of external software
 - `lib/scripting` - aliases and functions aimed to speed up process of creation of bash scripts
 - `lib/shell` - miscellaneous functions inteded to be used from the command line that speed up my daily work
 - `lib/test` - simple helpers for writting more flexible test suites

`scripts` -when some goals cannot be achieved using standard Linux tools it is a hight time to write your own, of course in Python (really, try to extract a ZIP archieve while displaying a nice - i.e. not dot-based - progress bar using Linux toolset, I dare you!)

`test` - a set of unit tests that (in theory) should elminate most of bugs from the library; I have always been better at fixing stuff than breaking them, so the testsuite is far from being exhaustive; if you feel like having gift for making creative test scenarios don't hesitate to add your own!

# Usage
To use the project, just download it and source `source_ma.bash` file every time you need some of it's tools (or add `source <BASH_UTILS_INSTALLATION_PATH>/source_me.bash` into your scripts). Definitions provided by the library will be automatically sourced and path to the bin/ folder will be appended to the PATH

# Dependencies
bash-utils uses [shpec](https://github.com/rylnd/shpec) (version 0.3.1) to implement unit tests for the library. Unit tests for bash scripts? Yeah, I have never expected that I would ever write something like that too .-. 

# Furue works

## `Parseargs`

At the moment, the 'full' `parseargs` is implemented completely in `bash` utilizing a lot of name indirections. As so it performs purely in complex proejcts that require calling it very often. It is plan to bring it to the binary domain as a standalone application compiled automatically by the project. Such an approach would provide huge performance boost without loosing elasticity.
