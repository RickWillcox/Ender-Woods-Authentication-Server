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
  `item_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=LATIN1;

INSERT INTO items (item_id, item_name,consumable,attack,defence,file_name,item_category) VALUES
     (1, 'silver_helmet',0,0,5,'1_silver_helmet.png', 1),
     (2, 'silver_chest',0,0,10,'2_silver_chest.png',2),
     (3, 'silver_gloves',0,4,2,'3_silver_gloves.png', 3),
     (4, 'Silver_leggings',0,0,8,'4_silver_leggings.png',4),
     (5, 'silver_boots',0,2,2,'5_silver_boots.png',5),
     (6, 'silver_sword',0,10,0,'6_silver_sword.png',6),
     (7, 'silver_shield',0,0,10,'7_silver_shield.png',7),
     (8, 'gold_ring',0,4,4,'8_gold_ring.png',8),
     (9, 'diamond_ring',0,6,6,'9_diamond_ring.png',8),
     (10, 'gold_amulet',0,5,5,'10_gold_amulet.png',9);