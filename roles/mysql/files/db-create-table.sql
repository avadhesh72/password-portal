CREATE TABLE `passwd_mgmt_table` (
	`id` int(11) NOT NULL auto_increment,
	`host_name` varchar(100) NOT NULL,
	`ip_addr` varchar(20) NOT NULL,
	`time` DATETIME(6) NOT NULL,
	`who_changed` varchar(20) NOT NULL,
	`root_passwd` varchar(20) NOT NULL,
	PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET= utf8;