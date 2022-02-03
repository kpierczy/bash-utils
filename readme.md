# Welcome to the bash-utils library!
This project provides a set of simple yet useful tools for developers working in the Linux environment on a regular basis. It consists of two main parts:
  - a library of functions and aliases designed to speed up process of creating bash scripts; there are also some tools aimed to be used directy from the command line - these are mainly related to software used by the author
  - a set of scripts performing tasks that have popped out suprisingly often in the author's work over past few years
The project has been developed on the Ubuntu 20.04LTS syste with bash in version 5.0.17, bu as far as the author knows it should play well with bash in versions not lower than 4.3.

# Content                                                                                 

<pre>
├── `.vscode`            bash-utils is developed using Visual Studio Code. This directory is not a core <br/>
│                        part of the library but provides my current configuration of the environment. <br/>
│                        I leav it here with hope that some of extensions that I use will turn out to  <br/>
│                        be helpful also in your daily routine!                                        <br/>
│                                                                                                      <br/>
├── `bin`                bash script implementing simple configuration/installation routines           <br/>
│   │                                                                                                  <br/>
│   └── `install`        scripts automating installation of various software                           <br/>
│       │                                                                                              <br/>
│       ├── `buildtools` first of all you will find there a script (or maybe better call it            <br/>
│       │                'micro framework') automating installation of the GCC toolchain               <br/>
│       │                including bashutils, GCC compiler, glibc/newlib library and GDB               <br/>
│       │                debugger from source. Enjoy! (Although if you are used to generate            <br/>
│       │                from-soruce toolchains regularly explore Buildroot :) )                       <br/>
│       │                                                                                              <br/>
│       ├── `libraries`  from-soruce installation scripts for some popular libraries. At the           <br/>
│       │                moment Boost library is supported                                             <br/>
│       │                                                                                              <br/>
│       └── `ros`        installation scripts for ROS in the lates versions                            <br/>
│                                                                                                      <br/>
├── `dep`                project's dependencies                                                        <br/>
│                                                                                                      <br/>
├── `doc`                mainly authore's notes containing set of Internet sources that turned         <br/>
│                        out to be usefull during development of the project                           <br/>
│                                                                                                      <br/>
├── `lib`                library of usefull bash functions and aliases                                 <br/>
│   │                                                                                                  <br/>
│   ├── `debug`          tools related to debugging bash scripts                                       <br/>
│   │                                                                                                  <br/>
│   ├── `files`          general file-manipulation tools                                               <br/>
│   │                                                                                                  <br/>
│   ├── `logging`        small logging framework (with colours!)                                       <br/>
│   │                                                                                                  <br/>
│   ├── `processing`     my little attempt to make bash language more programmers-friendly :)          <br/>
│   │                                                                                                  <br/>
│   ├── `programs`       set of tools related to installation and inspection of external software      <br/>
│   │                                                                                                  <br/>
│   ├── `scripting`      aliases and functions aimed to speed up process of creation of bash scripts   <br/>
│   │                                                                                                  <br/>
│   ├── `shell`          miscellaneous functions inteded to be used from the command line that speed   <br/>
│   │                    up my daily work                                                              <br/>
│   │                                                                                                  <br/>
│   └── `test`           simple helpers for writting more flexible test suites                         <br/>
│                                                                                                      <br/>
├── `scripts`            when some goals cannot be achieved using standard Linux tools it is a hight   <br/>
│                        time to write your own, of course in Python (really, try to extract a ZIP     <br/>
│                        archieve while displaying a nice - i.e. not dot-based - progress bar using    <br/>
│                        Linux toolset, I dare you!)                                                   <br/>
│                                                                                                      <br/>
└── `test`               a set of unit tests that (in theory) should elminate most of bugs from the    <br/>
                         library; I have always been better at fixing stuff than breaking them, so     <br/>
                         the testsuite is far from being exhaustive; if you feel like having gift for  <br/>
                         making creative test scenarios don't hesitate to add your own!                <br/>
</pre>

# Usage
To use the project, just download it and source `source_ma.bash` file every time you need some of it's tools (or add `source <BASH_UTILS_INSTALLATION_PATH>/source_me.bash` into your scripts). Definitions provided by the library will be automatically sourced and path to the bin/ folder will be appended to the PATH

# Dependencies
bash-utils uses [shpec](https://github.com/rylnd/shpec) (version 0.3.1) to implement unit tests for the library. Unit tests for bash scripts? Yeah, I have never expected that I would every write something like that too .-. 

# Plan

1. Finish "parseargs" module
2. Rewrite options' parsing usage in the library
3. Rewrite /bin scripts to follow the new library scheme
