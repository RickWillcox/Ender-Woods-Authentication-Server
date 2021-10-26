# Ender Woods Authentication Server

## Installation

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

You must run the Authentication Server Project using 3.3.4MariaDB.exe

1. Clone this repo
2. Open 3.3.4MariaDB.exe
3. Open the Godot project file for Authenticaion Server (project.godot) from this exe.

You will now be able to run the Authentication Server like normal (play), and then load up Gateway Server > World Server > Client and test the game.

