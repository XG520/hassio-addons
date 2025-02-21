/*
 Navicat Premium Data Transfer

 Source Server         : 192.168.31.41
 Source Server Type    : MySQL
 Source Server Version : 80404 (8.4.4)
 Source Host           : 192.168.31.41:3306
 Source Schema         : moneynote

 Target Server Type    : MySQL
 Target Server Version : 80404 (8.4.4)
 File Encoding         : 65001

 Date: 20/02/2025 14:49:10
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for t_flow_file
-- ----------------------------
DROP TABLE IF EXISTS `t_flow_file`;
CREATE TABLE `t_flow_file`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `content_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `create_time` bigint NOT NULL,
  `data` longblob NOT NULL,
  `original_name` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `size` bigint NOT NULL,
  `user_id` int NOT NULL,
  `flow_id` int NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `FKo9r24mqfdfa4s0obyk89ncbl5`(`user_id`) USING BTREE,
  INDEX `FKjg7o798g6lxk41c3m4pnn44et`(`flow_id`) USING BTREE
) ENGINE = MyISAM AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of t_flow_file
-- ----------------------------

-- ----------------------------
-- Table structure for t_user_account
-- ----------------------------
DROP TABLE IF EXISTS `t_user_account`;
CREATE TABLE `t_user_account`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `apr` decimal(8, 4) NULL DEFAULT NULL,
  `balance` decimal(20, 2) NULL DEFAULT NULL,
  `bill_day` int NULL DEFAULT NULL,
  `can_expense` bit(1) NOT NULL,
  `can_income` bit(1) NOT NULL,
  `can_transfer_from` bit(1) NOT NULL,
  `can_transfer_to` bit(1) NOT NULL,
  `credit_limit` decimal(20, 2) NULL DEFAULT NULL,
  `currency_code` varchar(5) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `enable` bit(1) NOT NULL,
  `include` bit(1) NOT NULL,
  `initial_balance` decimal(20, 2) NULL DEFAULT NULL,
  `no` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `notes` varchar(4096) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `ranking` int NULL DEFAULT NULL,
  `type` int NOT NULL,
  `group_id` int NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `FKkur8wwtmwt486vhiy4q9boec6`(`group_id`) USING BTREE
) ENGINE = MyISAM AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of t_user_account
-- ----------------------------

-- ----------------------------
-- Table structure for t_user_balance_flow
-- ----------------------------
DROP TABLE IF EXISTS `t_user_balance_flow`;
CREATE TABLE `t_user_balance_flow`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `amount` decimal(15, 2) NULL DEFAULT NULL,
  `confirm` bit(1) NOT NULL,
  `converted_amount` decimal(15, 2) NULL DEFAULT NULL,
  `create_time` bigint NOT NULL,
  `include` bit(1) NULL DEFAULT NULL,
  `insert_at` bigint NOT NULL,
  `notes` varchar(4096) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `title` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `type` int NOT NULL,
  `account_id` int NULL DEFAULT NULL,
  `book_id` int NOT NULL,
  `creator_id` int NOT NULL,
  `group_id` int NOT NULL,
  `payee_id` int NULL DEFAULT NULL,
  `to_id` int NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `FKen0bpvmu7tm6xg8qm1idlwj48`(`account_id`) USING BTREE,
  INDEX `FKtcdd396bqbj0yw1nfbudi7iow`(`book_id`) USING BTREE,
  INDEX `FKewt3a1j4c1ww6y5d184u9tbs8`(`creator_id`) USING BTREE,
  INDEX `FK7un5my1b0a3yyiom0l8pdicut`(`group_id`) USING BTREE,
  INDEX `FKr41ensdat6npd2dkeafjmflc6`(`payee_id`) USING BTREE,
  INDEX `FKaqtsdhctqjv5fvdvyf6jjsg5a`(`to_id`) USING BTREE
) ENGINE = MyISAM AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of t_user_balance_flow
-- ----------------------------

-- ----------------------------
-- Table structure for t_user_book
-- ----------------------------
DROP TABLE IF EXISTS `t_user_book`;
CREATE TABLE `t_user_book`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `default_currency_code` varchar(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `enable` bit(1) NOT NULL,
  `export_at` bigint NULL DEFAULT NULL,
  `notes` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `ranking` int NULL DEFAULT NULL,
  `default_expense_account_id` int NULL DEFAULT NULL,
  `default_expense_category_id` int NULL DEFAULT NULL,
  `default_income_account_id` int NULL DEFAULT NULL,
  `default_income_category_id` int NULL DEFAULT NULL,
  `default_transfer_from_account_id` int NULL DEFAULT NULL,
  `default_transfer_to_account_id` int NULL DEFAULT NULL,
  `group_id` int NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `UK_ivngjs8qdap5rvjd3vf1n3t7t`(`default_expense_category_id`) USING BTREE,
  UNIQUE INDEX `UK_f9ns5kb7dj5n1fioxut9w96ht`(`default_income_category_id`) USING BTREE,
  INDEX `FKrg0gejhur7j56kf66y5bemxv4`(`default_expense_account_id`) USING BTREE,
  INDEX `FKqm9p7ck7n3k3xu9e300iec4wx`(`default_income_account_id`) USING BTREE,
  INDEX `FK60plcw3envatirg494k37t9ms`(`default_transfer_from_account_id`) USING BTREE,
  INDEX `FKrd1g8xncq855rw4lmv4440o21`(`default_transfer_to_account_id`) USING BTREE,
  INDEX `FKjunl9lbftowsxeyoovoew1h5i`(`group_id`) USING BTREE
) ENGINE = MyISAM AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of t_user_book
-- ----------------------------
INSERT INTO `t_user_book` VALUES (1, '生活账本1', 'CNY', b'1', NULL, '用于个人生活记账。将支出分为维持类，消费类，提升类，社交类4个大类，收入分为主动收入，被动收入，社交收入3个大类。', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1);
INSERT INTO `t_user_book` VALUES (2, '生活账本1', 'CNY', b'1', NULL, '用于个人生活记账。将支出分为维持类，消费类，提升类，社交类4个大类，收入分为主动收入，被动收入，社交收入3个大类。', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 2);
INSERT INTO `t_user_book` VALUES (3, '生活账本1', 'CNY', b'1', NULL, '用于个人生活记账。将支出分为维持类，消费类，提升类，社交类4个大类，收入分为主动收入，被动收入，社交收入3个大类。', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 3);

-- ----------------------------
-- Table structure for t_user_category
-- ----------------------------
DROP TABLE IF EXISTS `t_user_category`;
CREATE TABLE `t_user_category`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `level` int NOT NULL,
  `enable` bit(1) NOT NULL,
  `notes` varchar(4096) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `ranking` int NULL DEFAULT NULL,
  `type` int NOT NULL,
  `parent_id` int NULL DEFAULT NULL,
  `book_id` int NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `FKee0w9yghv2lc2u6405p1mw1ps`(`parent_id`) USING BTREE,
  INDEX `FKpb2chmrgplojfbefvj0x6x569`(`book_id`) USING BTREE
) ENGINE = MyISAM AUTO_INCREMENT = 37 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of t_user_category
-- ----------------------------
INSERT INTO `t_user_category` VALUES (1, '维持类', 0, b'1', '维持生活的必须开支，是无法节省的开支。', 100, 100, NULL, 1);
INSERT INTO `t_user_category` VALUES (2, '消费类', 0, b'1', '可以节省的开支，比如娱乐，旅游等。', 200, 100, NULL, 1);
INSERT INTO `t_user_category` VALUES (3, '提升类', 0, b'1', '提升自己的生存能力，比如买书，保险等消费。', 300, 100, NULL, 1);
INSERT INTO `t_user_category` VALUES (4, '社交类', 0, b'1', '社交类型的支出，比如请朋友吃饭，送礼等。', 400, 100, NULL, 1);
INSERT INTO `t_user_category` VALUES (5, '主动收入', 0, b'1', '即劳动收入，指用时间来换取金钱，它最大的特点就是必须花费时间和精力去获得。', 100, 200, NULL, 1);
INSERT INTO `t_user_category` VALUES (6, '工资', 1, b'1', NULL, 100, 200, 5, 1);
INSERT INTO `t_user_category` VALUES (7, '兼职', 1, b'1', NULL, 200, 200, 5, 1);
INSERT INTO `t_user_category` VALUES (8, '薅羊毛', 1, b'1', '利用各种网络金融产品或红包活动推广下线抽成赚钱，比如外卖优惠券、减免优惠、送话费等。', 300, 200, 5, 1);
INSERT INTO `t_user_category` VALUES (9, '被动收入', 0, b'1', NULL, 200, 200, NULL, 1);
INSERT INTO `t_user_category` VALUES (10, '理财', 1, b'1', NULL, 100, 200, 9, 1);
INSERT INTO `t_user_category` VALUES (11, '租金', 1, b'1', NULL, 200, 200, 9, 1);
INSERT INTO `t_user_category` VALUES (12, '社交收入', 0, b'1', '比如收到的红包。', 300, 200, NULL, 1);
INSERT INTO `t_user_category` VALUES (13, '维持类', 0, b'1', '维持生活的必须开支，是无法节省的开支。', 100, 100, NULL, 2);
INSERT INTO `t_user_category` VALUES (14, '消费类', 0, b'1', '可以节省的开支，比如娱乐，旅游等。', 200, 100, NULL, 2);
INSERT INTO `t_user_category` VALUES (15, '提升类', 0, b'1', '提升自己的生存能力，比如买书，保险等消费。', 300, 100, NULL, 2);
INSERT INTO `t_user_category` VALUES (16, '社交类', 0, b'1', '社交类型的支出，比如请朋友吃饭，送礼等。', 400, 100, NULL, 2);
INSERT INTO `t_user_category` VALUES (17, '主动收入', 0, b'1', '即劳动收入，指用时间来换取金钱，它最大的特点就是必须花费时间和精力去获得。', 100, 200, NULL, 2);
INSERT INTO `t_user_category` VALUES (18, '工资', 1, b'1', NULL, 100, 200, 17, 2);
INSERT INTO `t_user_category` VALUES (19, '兼职', 1, b'1', NULL, 200, 200, 17, 2);
INSERT INTO `t_user_category` VALUES (20, '薅羊毛', 1, b'1', '利用各种网络金融产品或红包活动推广下线抽成赚钱，比如外卖优惠券、减免优惠、送话费等。', 300, 200, 17, 2);
INSERT INTO `t_user_category` VALUES (21, '被动收入', 0, b'1', NULL, 200, 200, NULL, 2);
INSERT INTO `t_user_category` VALUES (22, '理财', 1, b'1', NULL, 100, 200, 21, 2);
INSERT INTO `t_user_category` VALUES (23, '租金', 1, b'1', NULL, 200, 200, 21, 2);
INSERT INTO `t_user_category` VALUES (24, '社交收入', 0, b'1', '比如收到的红包。', 300, 200, NULL, 2);
INSERT INTO `t_user_category` VALUES (25, '维持类', 0, b'1', '维持生活的必须开支，是无法节省的开支。', 100, 100, NULL, 3);
INSERT INTO `t_user_category` VALUES (26, '消费类', 0, b'1', '可以节省的开支，比如娱乐，旅游等。', 200, 100, NULL, 3);
INSERT INTO `t_user_category` VALUES (27, '提升类', 0, b'1', '提升自己的生存能力，比如买书，保险等消费。', 300, 100, NULL, 3);
INSERT INTO `t_user_category` VALUES (28, '社交类', 0, b'1', '社交类型的支出，比如请朋友吃饭，送礼等。', 400, 100, NULL, 3);
INSERT INTO `t_user_category` VALUES (29, '主动收入', 0, b'1', '即劳动收入，指用时间来换取金钱，它最大的特点就是必须花费时间和精力去获得。', 100, 200, NULL, 3);
INSERT INTO `t_user_category` VALUES (30, '工资', 1, b'1', NULL, 100, 200, 29, 3);
INSERT INTO `t_user_category` VALUES (31, '兼职', 1, b'1', NULL, 200, 200, 29, 3);
INSERT INTO `t_user_category` VALUES (32, '薅羊毛', 1, b'1', '利用各种网络金融产品或红包活动推广下线抽成赚钱，比如外卖优惠券、减免优惠、送话费等。', 300, 200, 29, 3);
INSERT INTO `t_user_category` VALUES (33, '被动收入', 0, b'1', NULL, 200, 200, NULL, 3);
INSERT INTO `t_user_category` VALUES (34, '理财', 1, b'1', NULL, 100, 200, 33, 3);
INSERT INTO `t_user_category` VALUES (35, '租金', 1, b'1', NULL, 200, 200, 33, 3);
INSERT INTO `t_user_category` VALUES (36, '社交收入', 0, b'1', '比如收到的红包。', 300, 200, NULL, 3);

-- ----------------------------
-- Table structure for t_user_category_relation
-- ----------------------------
DROP TABLE IF EXISTS `t_user_category_relation`;
CREATE TABLE `t_user_category_relation`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `amount` decimal(15, 2) NULL DEFAULT NULL,
  `converted_amount` decimal(15, 2) NULL DEFAULT NULL,
  `balance_flow_id` int NOT NULL,
  `category_id` int NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `FKqs0r8impuwvxx2jgwjeoh3v0n`(`balance_flow_id`) USING BTREE,
  INDEX `FKc8hf57tw7gkyboxj87773c8wb`(`category_id`) USING BTREE
) ENGINE = MyISAM AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = FIXED;

-- ----------------------------
-- Records of t_user_category_relation
-- ----------------------------

-- ----------------------------
-- Table structure for t_user_group
-- ----------------------------
DROP TABLE IF EXISTS `t_user_group`;
CREATE TABLE `t_user_group`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `default_currency_code` varchar(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `enable` bit(1) NOT NULL,
  `notes` varchar(4096) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `creator_id` int NULL DEFAULT NULL,
  `default_book_id` int NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `FK48ou577pqbl95cne14j5dcomm`(`creator_id`) USING BTREE,
  INDEX `FK1cer3g2fde5x4dufbx6x265p3`(`default_book_id`) USING BTREE
) ENGINE = MyISAM AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of t_user_group
-- ----------------------------
INSERT INTO `t_user_group` VALUES (1, '默认组', 'CNY', b'1', NULL, 1, 1);
INSERT INTO `t_user_group` VALUES (2, '默认组', 'CNY', b'1', NULL, 2, 2);
INSERT INTO `t_user_group` VALUES (3, '默认组', 'CNY', b'1', NULL, 3, 3);

-- ----------------------------
-- Table structure for t_user_note_day
-- ----------------------------
DROP TABLE IF EXISTS `t_user_note_day`;
CREATE TABLE `t_user_note_day`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `end_date` bigint NOT NULL,
  `c_interval` int NULL DEFAULT NULL,
  `next_date` bigint NULL DEFAULT NULL,
  `notes` varchar(4096) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `repeat_type` int NOT NULL,
  `run_count` int NOT NULL,
  `start_date` bigint NOT NULL,
  `title` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `total_count` int NOT NULL,
  `user_id` int NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `FKrvhe5mux7n789humkp3aw3ocw`(`user_id`) USING BTREE
) ENGINE = MyISAM AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of t_user_note_day
-- ----------------------------

-- ----------------------------
-- Table structure for t_user_payee
-- ----------------------------
DROP TABLE IF EXISTS `t_user_payee`;
CREATE TABLE `t_user_payee`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `can_expense` bit(1) NOT NULL,
  `can_income` bit(1) NOT NULL,
  `enable` bit(1) NOT NULL,
  `notes` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `ranking` int NULL DEFAULT NULL,
  `book_id` int NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `FKajnpgcvkqbqy9vevd0ublljq9`(`book_id`) USING BTREE
) ENGINE = MyISAM AUTO_INCREMENT = 13 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of t_user_payee
-- ----------------------------
INSERT INTO `t_user_payee` VALUES (1, '美团外卖', b'1', b'0', b'1', NULL, 200, 1);
INSERT INTO `t_user_payee` VALUES (2, '京东商城', b'1', b'0', b'1', NULL, 100, 1);
INSERT INTO `t_user_payee` VALUES (3, '淘宝商城', b'1', b'0', b'1', NULL, 400, 1);
INSERT INTO `t_user_payee` VALUES (4, '拼多多', b'1', b'0', b'1', NULL, 300, 1);
INSERT INTO `t_user_payee` VALUES (5, '美团外卖', b'1', b'0', b'1', NULL, 200, 2);
INSERT INTO `t_user_payee` VALUES (6, '京东商城', b'1', b'0', b'1', NULL, 100, 2);
INSERT INTO `t_user_payee` VALUES (7, '淘宝商城', b'1', b'0', b'1', NULL, 400, 2);
INSERT INTO `t_user_payee` VALUES (8, '拼多多', b'1', b'0', b'1', NULL, 300, 2);
INSERT INTO `t_user_payee` VALUES (9, '美团外卖', b'1', b'0', b'1', NULL, 200, 3);
INSERT INTO `t_user_payee` VALUES (10, '京东商城', b'1', b'0', b'1', NULL, 100, 3);
INSERT INTO `t_user_payee` VALUES (11, '淘宝商城', b'1', b'0', b'1', NULL, 400, 3);
INSERT INTO `t_user_payee` VALUES (12, '拼多多', b'1', b'0', b'1', NULL, 300, 3);

-- ----------------------------
-- Table structure for t_user_tag
-- ----------------------------
DROP TABLE IF EXISTS `t_user_tag`;
CREATE TABLE `t_user_tag`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `level` int NOT NULL,
  `can_expense` bit(1) NOT NULL,
  `can_income` bit(1) NOT NULL,
  `can_transfer` bit(1) NOT NULL,
  `enable` bit(1) NOT NULL,
  `notes` varchar(4096) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `ranking` int NULL DEFAULT NULL,
  `parent_id` int NULL DEFAULT NULL,
  `book_id` int NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `FKig9ppldgr7mjdslg9v15xt6xa`(`parent_id`) USING BTREE,
  INDEX `FK1i2ydmflodkihrnet43fox1t6`(`book_id`) USING BTREE
) ENGINE = MyISAM AUTO_INCREMENT = 172 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of t_user_tag
-- ----------------------------
INSERT INTO `t_user_tag` VALUES (1, '饮食', 0, b'1', b'0', b'0', b'1', NULL, 100, NULL, 1);
INSERT INTO `t_user_tag` VALUES (2, '早餐', 1, b'1', b'0', b'0', b'1', NULL, 100, 1, 1);
INSERT INTO `t_user_tag` VALUES (3, '午餐', 1, b'1', b'0', b'0', b'1', NULL, 200, 1, 1);
INSERT INTO `t_user_tag` VALUES (4, '晚餐', 1, b'1', b'0', b'0', b'1', NULL, 300, 1, 1);
INSERT INTO `t_user_tag` VALUES (5, '零食', 1, b'1', b'0', b'0', b'1', NULL, 400, 1, 1);
INSERT INTO `t_user_tag` VALUES (6, '买菜', 1, b'1', b'0', b'0', b'1', NULL, 500, 1, 1);
INSERT INTO `t_user_tag` VALUES (7, '水果', 1, b'1', b'0', b'0', b'1', NULL, 600, 1, 1);
INSERT INTO `t_user_tag` VALUES (8, '烟', 1, b'1', b'0', b'0', b'1', NULL, 700, 1, 1);
INSERT INTO `t_user_tag` VALUES (9, '酒', 1, b'1', b'0', b'0', b'1', NULL, 800, 1, 1);
INSERT INTO `t_user_tag` VALUES (10, '饮用水', 1, b'1', b'0', b'0', b'1', NULL, 900, 1, 1);
INSERT INTO `t_user_tag` VALUES (11, '牛奶', 1, b'1', b'0', b'0', b'1', NULL, 1000, 1, 1);
INSERT INTO `t_user_tag` VALUES (12, '居住', 0, b'1', b'0', b'0', b'1', NULL, 200, NULL, 1);
INSERT INTO `t_user_tag` VALUES (13, '房租', 1, b'1', b'0', b'0', b'1', NULL, 100, 12, 1);
INSERT INTO `t_user_tag` VALUES (14, '水费', 1, b'1', b'0', b'0', b'1', NULL, 200, 12, 1);
INSERT INTO `t_user_tag` VALUES (15, '电费', 1, b'1', b'0', b'0', b'1', NULL, 300, 12, 1);
INSERT INTO `t_user_tag` VALUES (16, '天然气', 1, b'1', b'0', b'0', b'1', NULL, 400, 12, 1);
INSERT INTO `t_user_tag` VALUES (17, '物业费', 1, b'1', b'0', b'0', b'1', NULL, 500, 12, 1);
INSERT INTO `t_user_tag` VALUES (18, '话费', 1, b'1', b'0', b'0', b'1', NULL, 600, 12, 1);
INSERT INTO `t_user_tag` VALUES (19, '房贷', 1, b'1', b'0', b'0', b'1', NULL, 700, 12, 1);
INSERT INTO `t_user_tag` VALUES (20, '衣着', 0, b'1', b'0', b'0', b'1', '维护个人形象方面的支出，比如美容，美甲，衣服，首饰等。', 300, NULL, 1);
INSERT INTO `t_user_tag` VALUES (21, '衣服', 1, b'1', b'0', b'0', b'1', NULL, 100, 20, 1);
INSERT INTO `t_user_tag` VALUES (22, '理发', 1, b'1', b'0', b'0', b'1', NULL, 200, 20, 1);
INSERT INTO `t_user_tag` VALUES (23, '出行', 0, b'1', b'0', b'0', b'1', NULL, 400, NULL, 1);
INSERT INTO `t_user_tag` VALUES (24, '地铁', 1, b'1', b'0', b'0', b'1', NULL, 100, 23, 1);
INSERT INTO `t_user_tag` VALUES (25, '公交', 1, b'1', b'0', b'0', b'1', NULL, 200, 23, 1);
INSERT INTO `t_user_tag` VALUES (26, '打车', 1, b'1', b'0', b'0', b'1', NULL, 300, 23, 1);
INSERT INTO `t_user_tag` VALUES (27, '顺风车', 1, b'1', b'0', b'0', b'1', NULL, 400, 23, 1);
INSERT INTO `t_user_tag` VALUES (28, '高铁', 1, b'1', b'0', b'0', b'1', NULL, 500, 23, 1);
INSERT INTO `t_user_tag` VALUES (29, '飞机', 1, b'1', b'0', b'0', b'1', NULL, 600, 23, 1);
INSERT INTO `t_user_tag` VALUES (30, '数码', 0, b'1', b'0', b'0', b'1', NULL, 500, NULL, 1);
INSERT INTO `t_user_tag` VALUES (31, '手机', 1, b'1', b'0', b'0', b'1', NULL, 100, 30, 1);
INSERT INTO `t_user_tag` VALUES (32, '电脑', 1, b'1', b'0', b'0', b'1', NULL, 200, 30, 1);
INSERT INTO `t_user_tag` VALUES (33, '软件', 1, b'1', b'0', b'0', b'1', NULL, 300, 30, 1);
INSERT INTO `t_user_tag` VALUES (34, '配件', 1, b'1', b'0', b'0', b'1', NULL, 400, 30, 1);
INSERT INTO `t_user_tag` VALUES (35, '养车', 0, b'1', b'0', b'0', b'1', NULL, 600, NULL, 1);
INSERT INTO `t_user_tag` VALUES (36, '加油', 1, b'1', b'0', b'0', b'1', NULL, 100, 35, 1);
INSERT INTO `t_user_tag` VALUES (37, '停车', 1, b'1', b'0', b'0', b'1', NULL, 200, 35, 1);
INSERT INTO `t_user_tag` VALUES (38, '维修', 1, b'1', b'0', b'0', b'1', NULL, 300, 35, 1);
INSERT INTO `t_user_tag` VALUES (39, '洗车', 1, b'1', b'0', b'0', b'1', NULL, 400, 35, 1);
INSERT INTO `t_user_tag` VALUES (40, '过路费', 1, b'1', b'0', b'0', b'1', NULL, 500, 35, 1);
INSERT INTO `t_user_tag` VALUES (41, '违章罚款', 1, b'1', b'0', b'0', b'1', NULL, 600, 35, 1);
INSERT INTO `t_user_tag` VALUES (42, '车险', 1, b'1', b'0', b'0', b'1', NULL, 700, 35, 1);
INSERT INTO `t_user_tag` VALUES (43, '配饰', 1, b'1', b'0', b'0', b'1', NULL, 800, 35, 1);
INSERT INTO `t_user_tag` VALUES (44, '年检', 1, b'1', b'0', b'0', b'1', NULL, 900, 35, 1);
INSERT INTO `t_user_tag` VALUES (45, '医疗', 0, b'1', b'0', b'0', b'1', NULL, 700, NULL, 1);
INSERT INTO `t_user_tag` VALUES (46, '体检', 1, b'1', b'0', b'0', b'1', NULL, 100, 45, 1);
INSERT INTO `t_user_tag` VALUES (47, '保险', 1, b'1', b'0', b'0', b'1', NULL, 200, 45, 1);
INSERT INTO `t_user_tag` VALUES (48, '保健品', 1, b'1', b'0', b'0', b'1', NULL, 300, 45, 1);
INSERT INTO `t_user_tag` VALUES (49, '牙科', 1, b'1', b'0', b'0', b'1', NULL, 400, 45, 1);
INSERT INTO `t_user_tag` VALUES (50, '教育', 0, b'1', b'0', b'0', b'1', NULL, 800, NULL, 1);
INSERT INTO `t_user_tag` VALUES (51, '买书', 1, b'1', b'0', b'0', b'1', NULL, 100, 50, 1);
INSERT INTO `t_user_tag` VALUES (52, '培训', 1, b'1', b'0', b'0', b'1', NULL, 200, 50, 1);
INSERT INTO `t_user_tag` VALUES (53, '娱乐', 0, b'1', b'0', b'0', b'1', NULL, 900, NULL, 1);
INSERT INTO `t_user_tag` VALUES (54, '游戏', 1, b'1', b'0', b'0', b'1', NULL, 100, 53, 1);
INSERT INTO `t_user_tag` VALUES (55, '电影', 1, b'1', b'0', b'0', b'1', NULL, 200, 53, 1);
INSERT INTO `t_user_tag` VALUES (56, '健身', 1, b'1', b'0', b'0', b'1', NULL, 300, 53, 1);
INSERT INTO `t_user_tag` VALUES (57, '日用', 0, b'1', b'0', b'0', b'1', '日用消耗品。', 1000, NULL, 1);
INSERT INTO `t_user_tag` VALUES (58, '饮食', 0, b'1', b'0', b'0', b'1', NULL, 100, NULL, 2);
INSERT INTO `t_user_tag` VALUES (59, '早餐', 1, b'1', b'0', b'0', b'1', NULL, 100, 58, 2);
INSERT INTO `t_user_tag` VALUES (60, '午餐', 1, b'1', b'0', b'0', b'1', NULL, 200, 58, 2);
INSERT INTO `t_user_tag` VALUES (61, '晚餐', 1, b'1', b'0', b'0', b'1', NULL, 300, 58, 2);
INSERT INTO `t_user_tag` VALUES (62, '零食', 1, b'1', b'0', b'0', b'1', NULL, 400, 58, 2);
INSERT INTO `t_user_tag` VALUES (63, '买菜', 1, b'1', b'0', b'0', b'1', NULL, 500, 58, 2);
INSERT INTO `t_user_tag` VALUES (64, '水果', 1, b'1', b'0', b'0', b'1', NULL, 600, 58, 2);
INSERT INTO `t_user_tag` VALUES (65, '烟', 1, b'1', b'0', b'0', b'1', NULL, 700, 58, 2);
INSERT INTO `t_user_tag` VALUES (66, '酒', 1, b'1', b'0', b'0', b'1', NULL, 800, 58, 2);
INSERT INTO `t_user_tag` VALUES (67, '饮用水', 1, b'1', b'0', b'0', b'1', NULL, 900, 58, 2);
INSERT INTO `t_user_tag` VALUES (68, '牛奶', 1, b'1', b'0', b'0', b'1', NULL, 1000, 58, 2);
INSERT INTO `t_user_tag` VALUES (69, '居住', 0, b'1', b'0', b'0', b'1', NULL, 200, NULL, 2);
INSERT INTO `t_user_tag` VALUES (70, '房租', 1, b'1', b'0', b'0', b'1', NULL, 100, 69, 2);
INSERT INTO `t_user_tag` VALUES (71, '水费', 1, b'1', b'0', b'0', b'1', NULL, 200, 69, 2);
INSERT INTO `t_user_tag` VALUES (72, '电费', 1, b'1', b'0', b'0', b'1', NULL, 300, 69, 2);
INSERT INTO `t_user_tag` VALUES (73, '天然气', 1, b'1', b'0', b'0', b'1', NULL, 400, 69, 2);
INSERT INTO `t_user_tag` VALUES (74, '物业费', 1, b'1', b'0', b'0', b'1', NULL, 500, 69, 2);
INSERT INTO `t_user_tag` VALUES (75, '话费', 1, b'1', b'0', b'0', b'1', NULL, 600, 69, 2);
INSERT INTO `t_user_tag` VALUES (76, '房贷', 1, b'1', b'0', b'0', b'1', NULL, 700, 69, 2);
INSERT INTO `t_user_tag` VALUES (77, '衣着', 0, b'1', b'0', b'0', b'1', '维护个人形象方面的支出，比如美容，美甲，衣服，首饰等。', 300, NULL, 2);
INSERT INTO `t_user_tag` VALUES (78, '衣服', 1, b'1', b'0', b'0', b'1', NULL, 100, 77, 2);
INSERT INTO `t_user_tag` VALUES (79, '理发', 1, b'1', b'0', b'0', b'1', NULL, 200, 77, 2);
INSERT INTO `t_user_tag` VALUES (80, '出行', 0, b'1', b'0', b'0', b'1', NULL, 400, NULL, 2);
INSERT INTO `t_user_tag` VALUES (81, '地铁', 1, b'1', b'0', b'0', b'1', NULL, 100, 80, 2);
INSERT INTO `t_user_tag` VALUES (82, '公交', 1, b'1', b'0', b'0', b'1', NULL, 200, 80, 2);
INSERT INTO `t_user_tag` VALUES (83, '打车', 1, b'1', b'0', b'0', b'1', NULL, 300, 80, 2);
INSERT INTO `t_user_tag` VALUES (84, '顺风车', 1, b'1', b'0', b'0', b'1', NULL, 400, 80, 2);
INSERT INTO `t_user_tag` VALUES (85, '高铁', 1, b'1', b'0', b'0', b'1', NULL, 500, 80, 2);
INSERT INTO `t_user_tag` VALUES (86, '飞机', 1, b'1', b'0', b'0', b'1', NULL, 600, 80, 2);
INSERT INTO `t_user_tag` VALUES (87, '数码', 0, b'1', b'0', b'0', b'1', NULL, 500, NULL, 2);
INSERT INTO `t_user_tag` VALUES (88, '手机', 1, b'1', b'0', b'0', b'1', NULL, 100, 87, 2);
INSERT INTO `t_user_tag` VALUES (89, '电脑', 1, b'1', b'0', b'0', b'1', NULL, 200, 87, 2);
INSERT INTO `t_user_tag` VALUES (90, '软件', 1, b'1', b'0', b'0', b'1', NULL, 300, 87, 2);
INSERT INTO `t_user_tag` VALUES (91, '配件', 1, b'1', b'0', b'0', b'1', NULL, 400, 87, 2);
INSERT INTO `t_user_tag` VALUES (92, '养车', 0, b'1', b'0', b'0', b'1', NULL, 600, NULL, 2);
INSERT INTO `t_user_tag` VALUES (93, '加油', 1, b'1', b'0', b'0', b'1', NULL, 100, 92, 2);
INSERT INTO `t_user_tag` VALUES (94, '停车', 1, b'1', b'0', b'0', b'1', NULL, 200, 92, 2);
INSERT INTO `t_user_tag` VALUES (95, '维修', 1, b'1', b'0', b'0', b'1', NULL, 300, 92, 2);
INSERT INTO `t_user_tag` VALUES (96, '洗车', 1, b'1', b'0', b'0', b'1', NULL, 400, 92, 2);
INSERT INTO `t_user_tag` VALUES (97, '过路费', 1, b'1', b'0', b'0', b'1', NULL, 500, 92, 2);
INSERT INTO `t_user_tag` VALUES (98, '违章罚款', 1, b'1', b'0', b'0', b'1', NULL, 600, 92, 2);
INSERT INTO `t_user_tag` VALUES (99, '车险', 1, b'1', b'0', b'0', b'1', NULL, 700, 92, 2);
INSERT INTO `t_user_tag` VALUES (100, '配饰', 1, b'1', b'0', b'0', b'1', NULL, 800, 92, 2);
INSERT INTO `t_user_tag` VALUES (101, '年检', 1, b'1', b'0', b'0', b'1', NULL, 900, 92, 2);
INSERT INTO `t_user_tag` VALUES (102, '医疗', 0, b'1', b'0', b'0', b'1', NULL, 700, NULL, 2);
INSERT INTO `t_user_tag` VALUES (103, '体检', 1, b'1', b'0', b'0', b'1', NULL, 100, 102, 2);
INSERT INTO `t_user_tag` VALUES (104, '保险', 1, b'1', b'0', b'0', b'1', NULL, 200, 102, 2);
INSERT INTO `t_user_tag` VALUES (105, '保健品', 1, b'1', b'0', b'0', b'1', NULL, 300, 102, 2);
INSERT INTO `t_user_tag` VALUES (106, '牙科', 1, b'1', b'0', b'0', b'1', NULL, 400, 102, 2);
INSERT INTO `t_user_tag` VALUES (107, '教育', 0, b'1', b'0', b'0', b'1', NULL, 800, NULL, 2);
INSERT INTO `t_user_tag` VALUES (108, '买书', 1, b'1', b'0', b'0', b'1', NULL, 100, 107, 2);
INSERT INTO `t_user_tag` VALUES (109, '培训', 1, b'1', b'0', b'0', b'1', NULL, 200, 107, 2);
INSERT INTO `t_user_tag` VALUES (110, '娱乐', 0, b'1', b'0', b'0', b'1', NULL, 900, NULL, 2);
INSERT INTO `t_user_tag` VALUES (111, '游戏', 1, b'1', b'0', b'0', b'1', NULL, 100, 110, 2);
INSERT INTO `t_user_tag` VALUES (112, '电影', 1, b'1', b'0', b'0', b'1', NULL, 200, 110, 2);
INSERT INTO `t_user_tag` VALUES (113, '健身', 1, b'1', b'0', b'0', b'1', NULL, 300, 110, 2);
INSERT INTO `t_user_tag` VALUES (114, '日用', 0, b'1', b'0', b'0', b'1', '日用消耗品。', 1000, NULL, 2);
INSERT INTO `t_user_tag` VALUES (115, '饮食', 0, b'1', b'0', b'0', b'1', NULL, 100, NULL, 3);
INSERT INTO `t_user_tag` VALUES (116, '早餐', 1, b'1', b'0', b'0', b'1', NULL, 100, 115, 3);
INSERT INTO `t_user_tag` VALUES (117, '午餐', 1, b'1', b'0', b'0', b'1', NULL, 200, 115, 3);
INSERT INTO `t_user_tag` VALUES (118, '晚餐', 1, b'1', b'0', b'0', b'1', NULL, 300, 115, 3);
INSERT INTO `t_user_tag` VALUES (119, '零食', 1, b'1', b'0', b'0', b'1', NULL, 400, 115, 3);
INSERT INTO `t_user_tag` VALUES (120, '买菜', 1, b'1', b'0', b'0', b'1', NULL, 500, 115, 3);
INSERT INTO `t_user_tag` VALUES (121, '水果', 1, b'1', b'0', b'0', b'1', NULL, 600, 115, 3);
INSERT INTO `t_user_tag` VALUES (122, '烟', 1, b'1', b'0', b'0', b'1', NULL, 700, 115, 3);
INSERT INTO `t_user_tag` VALUES (123, '酒', 1, b'1', b'0', b'0', b'1', NULL, 800, 115, 3);
INSERT INTO `t_user_tag` VALUES (124, '饮用水', 1, b'1', b'0', b'0', b'1', NULL, 900, 115, 3);
INSERT INTO `t_user_tag` VALUES (125, '牛奶', 1, b'1', b'0', b'0', b'1', NULL, 1000, 115, 3);
INSERT INTO `t_user_tag` VALUES (126, '居住', 0, b'1', b'0', b'0', b'1', NULL, 200, NULL, 3);
INSERT INTO `t_user_tag` VALUES (127, '房租', 1, b'1', b'0', b'0', b'1', NULL, 100, 126, 3);
INSERT INTO `t_user_tag` VALUES (128, '水费', 1, b'1', b'0', b'0', b'1', NULL, 200, 126, 3);
INSERT INTO `t_user_tag` VALUES (129, '电费', 1, b'1', b'0', b'0', b'1', NULL, 300, 126, 3);
INSERT INTO `t_user_tag` VALUES (130, '天然气', 1, b'1', b'0', b'0', b'1', NULL, 400, 126, 3);
INSERT INTO `t_user_tag` VALUES (131, '物业费', 1, b'1', b'0', b'0', b'1', NULL, 500, 126, 3);
INSERT INTO `t_user_tag` VALUES (132, '话费', 1, b'1', b'0', b'0', b'1', NULL, 600, 126, 3);
INSERT INTO `t_user_tag` VALUES (133, '房贷', 1, b'1', b'0', b'0', b'1', NULL, 700, 126, 3);
INSERT INTO `t_user_tag` VALUES (134, '衣着', 0, b'1', b'0', b'0', b'1', '维护个人形象方面的支出，比如美容，美甲，衣服，首饰等。', 300, NULL, 3);
INSERT INTO `t_user_tag` VALUES (135, '衣服', 1, b'1', b'0', b'0', b'1', NULL, 100, 134, 3);
INSERT INTO `t_user_tag` VALUES (136, '理发', 1, b'1', b'0', b'0', b'1', NULL, 200, 134, 3);
INSERT INTO `t_user_tag` VALUES (137, '出行', 0, b'1', b'0', b'0', b'1', NULL, 400, NULL, 3);
INSERT INTO `t_user_tag` VALUES (138, '地铁', 1, b'1', b'0', b'0', b'1', NULL, 100, 137, 3);
INSERT INTO `t_user_tag` VALUES (139, '公交', 1, b'1', b'0', b'0', b'1', NULL, 200, 137, 3);
INSERT INTO `t_user_tag` VALUES (140, '打车', 1, b'1', b'0', b'0', b'1', NULL, 300, 137, 3);
INSERT INTO `t_user_tag` VALUES (141, '顺风车', 1, b'1', b'0', b'0', b'1', NULL, 400, 137, 3);
INSERT INTO `t_user_tag` VALUES (142, '高铁', 1, b'1', b'0', b'0', b'1', NULL, 500, 137, 3);
INSERT INTO `t_user_tag` VALUES (143, '飞机', 1, b'1', b'0', b'0', b'1', NULL, 600, 137, 3);
INSERT INTO `t_user_tag` VALUES (144, '数码', 0, b'1', b'0', b'0', b'1', NULL, 500, NULL, 3);
INSERT INTO `t_user_tag` VALUES (145, '手机', 1, b'1', b'0', b'0', b'1', NULL, 100, 144, 3);
INSERT INTO `t_user_tag` VALUES (146, '电脑', 1, b'1', b'0', b'0', b'1', NULL, 200, 144, 3);
INSERT INTO `t_user_tag` VALUES (147, '软件', 1, b'1', b'0', b'0', b'1', NULL, 300, 144, 3);
INSERT INTO `t_user_tag` VALUES (148, '配件', 1, b'1', b'0', b'0', b'1', NULL, 400, 144, 3);
INSERT INTO `t_user_tag` VALUES (149, '养车', 0, b'1', b'0', b'0', b'1', NULL, 600, NULL, 3);
INSERT INTO `t_user_tag` VALUES (150, '加油', 1, b'1', b'0', b'0', b'1', NULL, 100, 149, 3);
INSERT INTO `t_user_tag` VALUES (151, '停车', 1, b'1', b'0', b'0', b'1', NULL, 200, 149, 3);
INSERT INTO `t_user_tag` VALUES (152, '维修', 1, b'1', b'0', b'0', b'1', NULL, 300, 149, 3);
INSERT INTO `t_user_tag` VALUES (153, '洗车', 1, b'1', b'0', b'0', b'1', NULL, 400, 149, 3);
INSERT INTO `t_user_tag` VALUES (154, '过路费', 1, b'1', b'0', b'0', b'1', NULL, 500, 149, 3);
INSERT INTO `t_user_tag` VALUES (155, '违章罚款', 1, b'1', b'0', b'0', b'1', NULL, 600, 149, 3);
INSERT INTO `t_user_tag` VALUES (156, '车险', 1, b'1', b'0', b'0', b'1', NULL, 700, 149, 3);
INSERT INTO `t_user_tag` VALUES (157, '配饰', 1, b'1', b'0', b'0', b'1', NULL, 800, 149, 3);
INSERT INTO `t_user_tag` VALUES (158, '年检', 1, b'1', b'0', b'0', b'1', NULL, 900, 149, 3);
INSERT INTO `t_user_tag` VALUES (159, '医疗', 0, b'1', b'0', b'0', b'1', NULL, 700, NULL, 3);
INSERT INTO `t_user_tag` VALUES (160, '体检', 1, b'1', b'0', b'0', b'1', NULL, 100, 159, 3);
INSERT INTO `t_user_tag` VALUES (161, '保险', 1, b'1', b'0', b'0', b'1', NULL, 200, 159, 3);
INSERT INTO `t_user_tag` VALUES (162, '保健品', 1, b'1', b'0', b'0', b'1', NULL, 300, 159, 3);
INSERT INTO `t_user_tag` VALUES (163, '牙科', 1, b'1', b'0', b'0', b'1', NULL, 400, 159, 3);
INSERT INTO `t_user_tag` VALUES (164, '教育', 0, b'1', b'0', b'0', b'1', NULL, 800, NULL, 3);
INSERT INTO `t_user_tag` VALUES (165, '买书', 1, b'1', b'0', b'0', b'1', NULL, 100, 164, 3);
INSERT INTO `t_user_tag` VALUES (166, '培训', 1, b'1', b'0', b'0', b'1', NULL, 200, 164, 3);
INSERT INTO `t_user_tag` VALUES (167, '娱乐', 0, b'1', b'0', b'0', b'1', NULL, 900, NULL, 3);
INSERT INTO `t_user_tag` VALUES (168, '游戏', 1, b'1', b'0', b'0', b'1', NULL, 100, 167, 3);
INSERT INTO `t_user_tag` VALUES (169, '电影', 1, b'1', b'0', b'0', b'1', NULL, 200, 167, 3);
INSERT INTO `t_user_tag` VALUES (170, '健身', 1, b'1', b'0', b'0', b'1', NULL, 300, 167, 3);
INSERT INTO `t_user_tag` VALUES (171, '日用', 0, b'1', b'0', b'0', b'1', '日用消耗品。', 1000, NULL, 3);

-- ----------------------------
-- Table structure for t_user_tag_relation
-- ----------------------------
DROP TABLE IF EXISTS `t_user_tag_relation`;
CREATE TABLE `t_user_tag_relation`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `amount` decimal(15, 2) NULL DEFAULT NULL,
  `converted_amount` decimal(15, 2) NULL DEFAULT NULL,
  `balance_flow_id` int NOT NULL,
  `tag_id` int NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `FKovwto2qfa6xbbm4vesabt5q6k`(`balance_flow_id`) USING BTREE,
  INDEX `FK3h0934keqff9i1560no9vuktm`(`tag_id`) USING BTREE
) ENGINE = MyISAM AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = FIXED;

-- ----------------------------
-- Records of t_user_tag_relation
-- ----------------------------

-- ----------------------------
-- Table structure for t_user_user
-- ----------------------------
DROP TABLE IF EXISTS `t_user_user`;
CREATE TABLE `t_user_user`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `email` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `enable` bit(1) NOT NULL,
  `headimgurl` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `nick_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `password` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `register_ip` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `register_time` bigint NULL DEFAULT NULL,
  `telephone` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `username` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `default_book_id` int NULL DEFAULT NULL,
  `default_group_id` int NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `UK_sgbyeo4w1viacqr67n48838n0`(`username`) USING BTREE,
  INDEX `FK9iqq5yxwll4jcjli2eb350cfq`(`default_book_id`) USING BTREE,
  INDEX `FK6uoid5dsvmh2b7qmn4w22ofyb`(`default_group_id`) USING BTREE
) ENGINE = MyISAM AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of t_user_user
-- ----------------------------

-- ----------------------------
-- Table structure for t_user_user_group_relation
-- ----------------------------
DROP TABLE IF EXISTS `t_user_user_group_relation`;
CREATE TABLE `t_user_user_group_relation`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `role` int NOT NULL,
  `group_id` int NOT NULL,
  `user_id` int NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `UK2r1ke7bbeidfwcl712wq3t1cl`(`user_id`, `group_id`) USING BTREE,
  INDEX `FK2ovl3fila18baesf8obl1nna5`(`group_id`) USING BTREE
) ENGINE = MyISAM AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = FIXED;

-- ----------------------------
-- Records of t_user_user_group_relation
-- ----------------------------
INSERT INTO `t_user_user_group_relation` VALUES (1, 1, 1, 1);
INSERT INTO `t_user_user_group_relation` VALUES (2, 1, 2, 2);
INSERT INTO `t_user_user_group_relation` VALUES (3, 1, 3, 3);

SET FOREIGN_KEY_CHECKS = 1;
