DROP DATABASE IF EXISTS `playerdata`;
CREATE DATABASE IF NOT EXISTS `playerdata` /*!40100 DEFAULT CHARACTER SET latin1 */;

USE `playerdata`;

-- playerdata.items definition
DROP TABLE IF EXISTS `items`;
CREATE TABLE `items` (
  `item_id` int(11) NOT NULL,
  `item_name` varchar(100) NOT NULL,
  `consumable` tinyint(4) NOT NULL,
  `attack` int(11) DEFAULT NULL,
  `defence` int(11) DEFAULT NULL,
  `file_name` varchar(100) DEFAULT NULL,
  `item_category` INT(11) NOT NULL,
  `stack_size` INT(11) DEFAULT 1,
  PRIMARY KEY (`item_id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=LATIN1;


-- playerdata.playeraccounts definition
DROP TABLE IF EXISTS `playeraccounts`;
CREATE TABLE `playeraccounts` (
  `account_id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(25) NOT NULL DEFAULT '',
  `password` varchar(64) NOT NULL DEFAULT '',
  `salt` varchar(64) NOT NULL DEFAULT '0',
  `session_token` varchar(10) DEFAULT NULL,
  `auth_token` varchar(74) DEFAULT NULL,
  `can_login` tinyint(1) DEFAULT 1,
  `world_server_id` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`account_id`) USING BTREE,
  UNIQUE KEY `ID` (`account_id`) USING BTREE,
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=270 DEFAULT CHARSET=latin1;


-- playerdata.playerinventories definition
DROP TABLE IF EXISTS `playerinventories`;
CREATE TABLE `playerinventories` (
  `account_id` int(11) NOT NULL,
  `item_slot` int(11) NOT NULL,
  `item_id` int(11) DEFAULT NULL,
  `amount` int(11) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=LATIN1;


-- playerdata.reciepes definition
DROP TABLE IF EXISTS `recipes`;
CREATE TABLE `recipes` (
  `recipe_id` INT(11) NOT NULL,
  `recipe_type` INT(11) NOT NULL,
  `required_level` INT(11) NOT NULL,
  `materials` TEXT NOT NULL,
  `result_item_id` INT(11) NOT NULL
) ENGINE=INNODB DEFAULT CHARSET=LATIN1;