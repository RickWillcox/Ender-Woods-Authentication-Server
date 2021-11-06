# Ender Woods Authentication Server

## Installation

### MariaDB

1. Download and Install [MariaDB](https://mariadb.org/download/?rel=10.6.4&prod=mariadb&os=windows&cpu=x86_64&pkg=msi&mirror=digital-pacific)

When you run it for the first time it will be run as a service on start up in the background. You should not need to do anything with this after completing this step once.

### Database

[![Visual Instructions Here](https://imgur.com/a/SqrwlLB "Instructions")](https://imgur.com/a/SqrwlLB "Instructions")
1. Download and install [HeidiSQL](https://www.heidisql.com/download.php "HeidiSQL")
2. Open HeidiSQL
3. Click "New"
4. Rename to "EnderWoodsAuth"
5. Hostname / IP: 127.0.0.1
6. User: "root"
7. Password: "root"
8. Port: "3306
9. Press Open
10. File > Load SQL File (ctrl + o)
11. Load playerdata.sql found here  [playerdata.sql](https://github.com/RickWillcox/Ender-Woods-Authentication-Server/blob/master/playerdata.sql "playerdata.sql") (This file is also in this repo)

### Godot

You must run the Authentication Server Project using the compile binary for either windows of linux that contains mariadb

1. Windows : https://drive.google.com/file/d/1mH3pn8u6pKX-WAhWdOSdqnqXhXDILuGj/view?usp=sharing
2. Linux Debian : https://drive.google.com/file/d/12_q6vZ-_GF9WUuYmMDx0bFVG4sxBeK4T/view?usp=sharing
3. Open the Godot project file for Authenticaion Server (project.godot) from this exe.

You will now be able to run the Authentication Server like normal (play), and then load up Gateway Server > World Server > Client and test the game.


### Compiling binary from scratch

1. Follow instructions on the [MariaDB plugin repo](https://github.com/sigrudds1/godot-mariadb)
2. Choose platform Linux or Windows
3. Run the following commands in the main godot folder cli (replace -j8, where 8 is how many cores your cpu has. eg: -j4 or -j16
4. You will find the compiled binaries in the /godot/bin folder 

#### Linux

1. Editor : `scons -j8 platform=x11 tools=yes target=release_debug bits=64 use_lto=yes`
2. Export Template debug: `scons -j8 platform=server tools=no target=release_debug bits=64 use_lto=yes`
3. Export Template release: `scons -j18 platform=server tools=no target=release bits=64 use_lto=yes`

#### Windows

1. Editor : `scons -j8 platform=windows tools=yes target=release_debug bits=64 use_lto=yes`
2. Export Template debug: `scons -j8 platform=windows tools=no target=release_debug bits=64 use_lto=yes`
3. Export Template release: `scons -j8 platform=windows tools=no target=release bits=64 use_lto=yes`


