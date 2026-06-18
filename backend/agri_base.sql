-- ============================================================
--  河南农业大学实训管理系统 — 完整数据库导出（含全部数据）
--  数据库系统原理 课程设计 | MySQL 8.0+ | InnoDB | utf8mb4
--  导出时间: 2026-06-18 13:11
--  表数: 35
-- ============================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ------------------------------------------------------------
-- Table: 作物品种表  (11 rows)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `作物品种表`;
CREATE TABLE `作物品种表` (
  `品种ID` int unsigned NOT NULL AUTO_INCREMENT COMMENT '品种主键',
  `品种名称` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '品种名称',
  `科属` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '如：禾本科小麦属',
  `培育周期` int unsigned DEFAULT NULL COMMENT '培育周期(天)',
  `温湿范围` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '适宜温湿度范围',
  `描述` text COLLATE utf8mb4_unicode_ci COMMENT '品种描述',
  PRIMARY KEY (`品种ID`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='作物品种表';

INSERT INTO `作物品种表` (`品种ID`, `品种名称`, `科属`, `培育周期`, `温湿范围`, `描述`) VALUES
(1, '豫麦58号', '禾本科小麦属', 240, '15-28°C / 60-75%', '河南省审定高产品种'),
(2, '郑单958', '禾本科玉米属', 120, '20-35°C / 50-70%', '高产玉米杂交种'),
(3, '豫豆29号', '豆科大豆属', 110, '18-30°C / 60-80%', '优质大豆品种'),
(4, '番茄(金棚一号)', '茄科番茄属', 90, '15-30°C / 50-70%', '温室番茄品种'),
(5, '黄瓜(津优35号)', '葫芦科黄瓜属', 75, '18-32°C / 70-85%', '温室黄瓜品种'),
(6, '月季(粉和平)', '蔷薇科蔷薇属', 180, '15-28°C / 50-65%', '观赏花卉品种'),
(7, '苹果(红富士)', '蔷薇科苹果属', 1095, '10-28°C / 50-70%', '果树嫁接砧木'),
(8, '香菇(0912)', '口蘑科香菇属', 90, '15-25°C / 80-90%', '食用菌品种'),
(9, '豫花23号', '豆科花生属', 130, '20-32°C / 60-75%', '优质花生品种'),
(10, '水稻(豫粳6号)', '禾本科稻属', 150, '20-35°C / 70-90%', '河南省粳稻品种'),
(11, '草莓(章姬)', '蔷薇科草莓属', 100, '15-25°C / 60-75%', '温室草莓品种');

-- ------------------------------------------------------------
-- Table: 借用记录表  (14 rows)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `借用记录表`;
CREATE TABLE `借用记录表` (
  `借用ID` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '借用主键',
  `器材ID` bigint unsigned NOT NULL COMMENT 'FK→器材档案表',
  `用户ID` bigint unsigned NOT NULL COMMENT 'FK→用户表',
  `借用数量` int unsigned NOT NULL COMMENT '借用数量',
  `借用日期` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '借用日期',
  `应还日期` datetime DEFAULT NULL COMMENT '应归还日期',
  `实还日期` datetime DEFAULT NULL COMMENT '实际归还日期',
  `借用状态` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '借用中' COMMENT '借用中/已归还/逾期',
  `项目ID` bigint unsigned DEFAULT NULL COMMENT 'FK→实训项目表',
  `审批人ID` bigint unsigned DEFAULT NULL COMMENT 'FK→用户表',
  PRIMARY KEY (`借用ID`),
  KEY `idx_borrow_user` (`用户ID`),
  KEY `idx_borrow_status` (`借用状态`),
  KEY `fk_borrow_equip` (`器材ID`),
  KEY `fk_borrow_project` (`项目ID`),
  KEY `fk_borrow_approver` (`审批人ID`),
  CONSTRAINT `fk_borrow_approver` FOREIGN KEY (`审批人ID`) REFERENCES `用户表` (`用户ID`),
  CONSTRAINT `fk_borrow_equip` FOREIGN KEY (`器材ID`) REFERENCES `器材档案表` (`器材ID`),
  CONSTRAINT `fk_borrow_project` FOREIGN KEY (`项目ID`) REFERENCES `实训项目表` (`项目ID`),
  CONSTRAINT `fk_borrow_user` FOREIGN KEY (`用户ID`) REFERENCES `用户表` (`用户ID`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='借用记录表';

INSERT INTO `借用记录表` (`借用ID`, `器材ID`, `用户ID`, `借用数量`, `借用日期`, `应还日期`, `实还日期`, `借用状态`, `项目ID`, `审批人ID`) VALUES
(1, 1, 7, 2, '2026-03-02 08:00:00', '2026-03-16 00:00:00', '2026-03-16 12:00:00', '已归还', NULL, 2),
(2, 2, 13, 3, '2026-03-01 08:00:00', '2026-03-15 00:00:00', '2026-03-14 17:00:00', '已归还', NULL, 4),
(3, 4, 8, 1, '2026-03-09 08:00:00', '2026-03-16 00:00:00', NULL, '借用中', NULL, 2),
(4, 6, 20, 1, '2026-03-15 14:00:00', '2026-03-22 00:00:00', NULL, '借用中', NULL, 6),
(5, 9, 14, 1, '2026-03-01 08:00:00', '2026-03-15 00:00:00', '2026-03-13 16:00:00', '已归还', NULL, 4),
(11, 1, 3, 2, '2026-06-19 09:00:00', '2026-06-26 09:00:00', NULL, '已归还', 2, NULL),
(12, 2, 5, 1, '2026-06-20 10:00:00', '2026-06-27 10:00:00', NULL, '借用中', 3, NULL),
(13, 4, 8, 3, '2026-06-21 14:00:00', '2026-06-28 14:00:00', '2026-06-25 14:00:00', '已归还', 3, NULL),
(14, 3, 12, 1, '2026-06-22 08:00:00', '2026-06-29 08:00:00', NULL, '借用中', 4, NULL),
(15, 5, 18, 2, '2026-06-23 09:30:00', '2026-06-30 09:30:00', '2026-06-18 12:17:15', '已归还', 5, NULL),
(16, 1, 7, 2, '2026-06-18 12:08:38', '2026-06-25 12:08:38', NULL, '待审批', NULL, NULL),
(17, 4, 1, 2, '2026-06-18 12:17:47', '2026-06-21 00:00:00', NULL, '借用中', NULL, 1),
(18, 11, 1, 4, '2026-06-18 12:37:05', '2026-06-19 00:00:00', NULL, '待审批', NULL, NULL),
(19, 11, 1, 3, '2026-06-18 12:44:39', '2026-06-19 00:00:00', NULL, '待审批', NULL, NULL);

-- ------------------------------------------------------------
-- Table: 入库记录表  (12 rows)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `入库记录表`;
CREATE TABLE `入库记录表` (
  `入库ID` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '入库主键',
  `器材ID` bigint unsigned NOT NULL COMMENT 'FK→器材档案表',
  `入库数量` int unsigned NOT NULL COMMENT '入库数量',
  `入库单价` decimal(10,2) DEFAULT NULL COMMENT '入库单价',
  `供应商` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '供应商名称',
  `入库日期` date NOT NULL COMMENT '入库日期',
  `经办人ID` bigint unsigned DEFAULT NULL COMMENT 'FK→用户表',
  `备注` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '备注说明',
  PRIMARY KEY (`入库ID`),
  KEY `idx_stockin_equip` (`器材ID`),
  KEY `fk_stockin_operator` (`经办人ID`),
  CONSTRAINT `fk_stockin_equip` FOREIGN KEY (`器材ID`) REFERENCES `器材档案表` (`器材ID`),
  CONSTRAINT `fk_stockin_operator` FOREIGN KEY (`经办人ID`) REFERENCES `用户表` (`用户ID`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='入库记录表';

INSERT INTO `入库记录表` (`入库ID`, `器材ID`, `入库数量`, `入库单价`, `供应商`, `入库日期`, `经办人ID`, `备注`) VALUES
(1, 1, 30, '25.00', '农资供应站', '2025-08-25', 1, '新学期采购'),
(2, 2, 20, '18.00', '农资供应站', '2025-08-25', 1, '新学期采购'),
(3, 3, 5, '280.00', '河南农机公司', '2025-08-28', 1, '设备更新'),
(4, 4, 15, '65.00', '河南农机公司', '2025-08-28', 1, '设备更新'),
(5, 5, 20, '22.00', '农资供应站', '2025-08-25', 1, '新学期采购'),
(6, 6, 10, '320.00', '郑州仪器公司', '2025-09-01', 2, '实验室采购'),
(7, 7, 3, '1580.00', '郑州仪器公司', '2025-09-01', 2, '实验室采购'),
(8, 8, 1, '8800.00', '郑州仪器公司', '2025-09-05', 4, '科研采购'),
(9, 9, 2, '12500.00', '郑州仪器公司', '2025-09-05', 4, '科研采购'),
(10, 10, 10, '3500.00', '郑州仪器公司', '2025-09-01', 2, '实验室采购'),
(11, 11, 50, '18.00', '育苗基质厂', '2026-02-20', 1, '春季采购'),
(12, 12, 30, '120.00', '化肥经销商', '2026-02-20', 1, '春季采购');

-- ------------------------------------------------------------
-- Table: 器材分类表  (5 rows)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `器材分类表`;
CREATE TABLE `器材分类表` (
  `分类ID` int unsigned NOT NULL AUTO_INCREMENT COMMENT '分类主键',
  `分类名称` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '农具/仪器/耗材',
  `描述` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '分类说明',
  PRIMARY KEY (`分类ID`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='器材分类表';

INSERT INTO `器材分类表` (`分类ID`, `分类名称`, `描述`) VALUES
(1, '农具', '锄头/铁锹/剪刀等类工具'),
(2, '仪器', '测量/检测设备'),
(3, '耗材', '种子/肥料/基质等消耗品'),
(4, '防护用品', '手套、口罩等安全防护用品'),
(5, '加工设备', '农产品加工处理设备');

-- ------------------------------------------------------------
-- Table: 器材档案表  (18 rows)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `器材档案表`;
CREATE TABLE `器材档案表` (
  `器材ID` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '器材主键',
  `器材编号` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '如：EQ-T001',
  `器材名称` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '器材名称',
  `分类ID` int unsigned DEFAULT NULL COMMENT 'FK→器材分类表',
  `规格型号` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '规格/型号',
  `单位` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '个' COMMENT '计量单位',
  `当前库存` int unsigned NOT NULL DEFAULT '0' COMMENT '当前库存数量',
  `最低库存` int unsigned NOT NULL DEFAULT '5' COMMENT '安全库存阈值',
  `单价` decimal(10,2) DEFAULT NULL COMMENT '单价(元)',
  `存放位置` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '存放位置',
  PRIMARY KEY (`器材ID`),
  UNIQUE KEY `器材编号` (`器材编号`),
  KEY `idx_equip_category` (`分类ID`),
  CONSTRAINT `fk_equip_category` FOREIGN KEY (`分类ID`) REFERENCES `器材分类表` (`分类ID`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='器材档案表';

INSERT INTO `器材档案表` (`器材ID`, `器材编号`, `器材名称`, `分类ID`, `规格型号`, `单位`, `当前库存`, `最低库存`, `单价`, `存放位置`) VALUES
(1, 'EQ-T001', '榔头', 1, '中号/不锈钢', '把', 15, 10, '25.00', '工具库1-A'),
(2, 'EQ-T002', '修枝剪', 1, '大号/碳钢', '把', 6, 10, '18.00', '工具库1-B'),
(3, 'EQ-T003', '电动剪枝机', 1, '220V/800W', '台', 1, 2, '280.00', '工具库2-A'),
(4, 'EQ-T004', '喷雾器', 1, '16L/背负式', '台', 10, 3, '65.00', '工具库2-B'),
(5, 'EQ-T005', '锄头', 1, '中号/木柄', '把', 30, 5, '22.00', '工具库1-C'),
(6, 'EQ-I001', '土壤pH计', 2, '精度0.1/便携', '台', 19, 3, '320.00', '仪器室A'),
(7, 'EQ-I002', '叶面积仪', 2, '手持式/LI-3000C', '台', 6, 1, '1580.00', '仪器室A'),
(8, 'EQ-I003', '自动气象站', 2, '多参数/无线', '套', 2, 1, '8800.00', '仪器室B'),
(9, 'EQ-I004', '光合仪', 2, 'LI-6800', '台', 2, 5, '12500.00', '仪器室B'),
(10, 'EQ-I005', '显微镜', 2, '双目/1000X', '台', 18, 2, '3500.00', '仪器室C'),
(11, 'EQ-C001', '育苗基质', 3, '50L/袋', '袋', 77, 10, '18.00', '耗材库A'),
(12, 'EQ-C002', '复合肥', 3, '50kg/袋', '袋', 48, 5, '120.00', '耗材库B'),
(13, 'EQ-C003', '多菌灵', 3, '500g/袋', '袋', 14, 5, '8.00', '耗材库C'),
(14, 'EQ-C004', '穴盘(128孔)', 3, '54×28cm', '个', 50, 20, '3.50', '耗材库A'),
(15, 'EQ-C005', '地膜', 3, '1.2m宽/5kg', '卷', 10, 3, '45.00', '耗材库B'),
(16, 'EQ-C006', '营养液(A液)', 3, '5L/桶', '桶', 8, 2, '68.00', '耗材库C'),
(17, 'EQ-C007', '营养液(B液)', 3, '5L/桶', '桶', 8, 2, '68.00', '耗材库C'),
(18, 'EQ-C008', '棉线手套', 3, '均码/12双', '包', 25, 10, '15.00', '耗材库A');

-- ------------------------------------------------------------
-- Table: 场地类型表  (5 rows)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `场地类型表`;
CREATE TABLE `场地类型表` (
  `类型ID` int unsigned NOT NULL AUTO_INCREMENT COMMENT '类型主键',
  `类型名称` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '温室/农田/实验室',
  `描述` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '类型说明',
  PRIMARY KEY (`类型ID`),
  UNIQUE KEY `类型名称` (`类型名称`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='场地类型表';

INSERT INTO `场地类型表` (`类型ID`, `类型名称`, `描述`) VALUES
(1, '温室大棚', '温控玻璃大棚，适用于精细育苗'),
(2, '试验农田', '露天试验田，适用于大田作物'),
(3, '实验室', '室内实验操作与检测'),
(4, '果园', '果树种植实训场地'),
(5, '茶园', '茶树栽培与制茶实训');

-- ------------------------------------------------------------
-- Table: 场地维护表  (7 rows)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `场地维护表`;
CREATE TABLE `场地维护表` (
  `维护ID` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '维护主键',
  `场地ID` bigint unsigned NOT NULL COMMENT 'FK→实训场地表',
  `维护日期` date NOT NULL COMMENT '维护日期',
  `维护类型` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '日常/紧急/定期',
  `描述` text COLLATE utf8mb4_unicode_ci COMMENT '维护内容',
  `费用` decimal(10,2) DEFAULT NULL COMMENT '维护费用',
  `记录人ID` bigint unsigned DEFAULT NULL COMMENT 'FK→用户表',
  PRIMARY KEY (`维护ID`),
  KEY `idx_mainten_venue` (`场地ID`),
  KEY `fk_mainten_recorder` (`记录人ID`),
  CONSTRAINT `fk_mainten_recorder` FOREIGN KEY (`记录人ID`) REFERENCES `用户表` (`用户ID`),
  CONSTRAINT `fk_mainten_venue` FOREIGN KEY (`场地ID`) REFERENCES `实训场地表` (`场地ID`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='场地维护表';

INSERT INTO `场地维护表` (`维护ID`, `场地ID`, `维护日期`, `维护类型`, `描述`, `费用`, `记录人ID`) VALUES
(8, 1, '2026-06-10', '日常维护', '清理杂草、检查灌溉设备', '120.00', 1),
(9, 2, '2026-06-12', '设施维修', '更换温室遮阳网', '850.00', 1),
(10, 3, '2026-06-15', '设备检修', '土壤检测仪校准', '200.00', 1),
(11, 4, '2026-06-18', '虫害防治', '喷洒生物农药', '350.00', 1),
(12, 5, '2026-06-22', '施肥', '施加有机肥料100kg', '480.00', 2),
(13, 6, '2026-06-25', '翻土', '使用旋耕机翻整土地', '300.00', 2),
(14, 7, '2026-06-28', '灌溉维修', '修复滴灌管道3处', '620.00', 1);

-- ------------------------------------------------------------
-- Table: 场地预约表  (7 rows)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `场地预约表`;
CREATE TABLE `场地预约表` (
  `预约ID` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '预约主键',
  `场地ID` bigint unsigned NOT NULL COMMENT 'FK→实训场地表',
  `项目ID` bigint unsigned DEFAULT NULL COMMENT 'FK→实训项目表',
  `申请人ID` bigint unsigned NOT NULL COMMENT 'FK→用户表',
  `开始时间` datetime NOT NULL COMMENT '预约开始时间',
  `结束时间` datetime NOT NULL COMMENT '预约结束时间',
  `预约原因` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '申请原因',
  `审批状态` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '待审批' COMMENT '待审批/已批准/已拒绝',
  `审批人ID` bigint unsigned DEFAULT NULL COMMENT 'FK→用户表',
  `申请时间` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '申请时间',
  PRIMARY KEY (`预约ID`),
  KEY `idx_booking_venue` (`场地ID`),
  KEY `idx_booking_status` (`审批状态`),
  KEY `fk_booking_applicant` (`申请人ID`),
  KEY `fk_booking_approver` (`审批人ID`),
  CONSTRAINT `fk_booking_applicant` FOREIGN KEY (`申请人ID`) REFERENCES `用户表` (`用户ID`),
  CONSTRAINT `fk_booking_approver` FOREIGN KEY (`审批人ID`) REFERENCES `用户表` (`用户ID`),
  CONSTRAINT `fk_booking_venue` FOREIGN KEY (`场地ID`) REFERENCES `实训场地表` (`场地ID`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='场地预约表';

INSERT INTO `场地预约表` (`预约ID`, `场地ID`, `项目ID`, `申请人ID`, `开始时间`, `结束时间`, `预约原因`, `审批状态`, `审批人ID`, `申请时间`) VALUES
(8, 1, NULL, 2, '2026-06-20 08:00:00', '2026-06-20 12:00:00', '小麦育种实验', '已通过', 1, '2026-06-18 12:08:24'),
(9, 2, NULL, 3, '2026-06-21 13:00:00', '2026-06-21 17:00:00', '水稻栽培实训', '已通过', 1, '2026-06-18 12:08:24'),
(10, 3, NULL, 1, '2026-06-22 08:00:00', '2026-06-22 18:00:00', '作物观摩教学', '已通过', 1, '2026-06-18 12:08:24'),
(11, 4, NULL, 4, '2026-06-23 08:00:00', '2026-06-23 12:00:00', '土壤肥力实验', '待审批', NULL, '2026-06-18 12:08:24'),
(12, 5, NULL, 5, '2026-06-24 13:00:00', '2026-06-24 16:00:00', '温室育苗', '已通过', 1, '2026-06-18 12:08:24'),
(13, 6, NULL, 2, '2026-06-25 08:00:00', '2026-06-25 11:30:00', '病虫害观察', '已通过', 1, '2026-06-18 12:08:24'),
(14, 7, NULL, 7, '2026-06-26 08:00:00', '2026-06-26 17:00:00', '农机操作实训', '待审批', NULL, '2026-06-18 12:08:24');

-- ------------------------------------------------------------
-- Table: 培育批次表  (7 rows)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `培育批次表`;
CREATE TABLE `培育批次表` (
  `批次ID` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '批次主键',
  `批次名称` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '批次名称',
  `品种ID` int unsigned NOT NULL COMMENT 'FK→作物品种表',
  `场地ID` bigint unsigned DEFAULT NULL COMMENT 'FK→实训场地表',
  `种植日期` date DEFAULT NULL COMMENT '种植日期',
  `数量` int unsigned DEFAULT '0' COMMENT '种植数量',
  `生长状态` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '播种期' COMMENT '播种期/生长期/收获期/异常',
  `存活率` decimal(5,2) DEFAULT NULL COMMENT '存活率(%)',
  `记录人ID` bigint unsigned DEFAULT NULL COMMENT 'FK→用户表',
  `创建时间` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`批次ID`),
  KEY `idx_batch_variety` (`品种ID`),
  KEY `idx_batch_venue` (`场地ID`),
  KEY `idx_batch_status` (`生长状态`),
  KEY `fk_batch_recorder` (`记录人ID`),
  CONSTRAINT `fk_batch_recorder` FOREIGN KEY (`记录人ID`) REFERENCES `用户表` (`用户ID`),
  CONSTRAINT `fk_batch_variety` FOREIGN KEY (`品种ID`) REFERENCES `作物品种表` (`品种ID`),
  CONSTRAINT `fk_batch_venue` FOREIGN KEY (`场地ID`) REFERENCES `实训场地表` (`场地ID`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='培育批次表';

INSERT INTO `培育批次表` (`批次ID`, `批次名称`, `品种ID`, `场地ID`, `种植日期`, `数量`, `生长状态`, `存活率`, `记录人ID`, `创建时间`) VALUES
(1, '001', 11, 1, '2026-06-18', 50, '播种期', '95.00', 1, '2026-06-18 11:42:51'),
(2, '002', 10, 2, '2026-06-17', 100, '生长期', '95.50', 2, '2026-06-18 11:54:00'),
(3, '003', 9, 3, '2026-06-19', 99, '收获期', '99.00', 2, '2026-06-18 11:54:46'),
(4, '004', 8, 11, '2026-06-18', 100, '播种期', '95.00', 2, '2026-06-18 11:55:13'),
(5, '005', 6, 5, '2026-06-18', 88, '生长期', '98.00', 2, '2026-06-18 11:55:36'),
(6, '006', 5, 7, '2026-06-18', 666, '收获期', '88.00', 2, '2026-06-18 11:56:04'),
(7, '007', 3, 9, '2026-06-18', 100, '播种期', '98.00', 2, '2026-06-18 11:56:42');

-- ------------------------------------------------------------
-- Table: 学期表  (5 rows)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `学期表`;
CREATE TABLE `学期表` (
  `学期ID` int unsigned NOT NULL AUTO_INCREMENT COMMENT '学期主键',
  `学期名称` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '如：2025-2026-2',
  `开始日期` date NOT NULL COMMENT '学期开始日期',
  `结束日期` date NOT NULL COMMENT '学期结束日期',
  `是否当前` tinyint(1) NOT NULL DEFAULT '0' COMMENT '1=当前学期 0=非当前',
  PRIMARY KEY (`学期ID`),
  UNIQUE KEY `学期名称` (`学期名称`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='学期表';

INSERT INTO `学期表` (`学期ID`, `学期名称`, `开始日期`, `结束日期`, `是否当前`) VALUES
(1, '2025-2026-1', '2025-09-01', '2026-01-15', 0),
(2, '2025-2026-2', '2026-02-16', '2026-07-10', 1),
(3, '2024-2025-2', '2025-02-17', '2025-07-05', 0),
(4, '2024-2025-1', '2024-09-02', '2025-01-18', 0),
(5, '2026-2027-1', '2026-09-07', '2027-01-22', 0);

-- ------------------------------------------------------------
-- Table: 学生互评表  (12 rows)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `学生互评表`;
CREATE TABLE `学生互评表` (
  `互评ID` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '互评主键',
  `项目ID` bigint unsigned NOT NULL COMMENT 'FK→实训项目表',
  `评分人ID` bigint unsigned NOT NULL COMMENT 'FK→用户表',
  `被评人ID` bigint unsigned NOT NULL COMMENT 'FK→用户表',
  `互评分数` decimal(5,2) DEFAULT NULL COMMENT '互评得分',
  `评语` text COLLATE utf8mb4_unicode_ci COMMENT '互评评语',
  `创建时间` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`互评ID`),
  KEY `idx_review_project` (`项目ID`),
  KEY `fk_review_reviewer` (`评分人ID`),
  KEY `fk_review_target` (`被评人ID`),
  CONSTRAINT `fk_review_project` FOREIGN KEY (`项目ID`) REFERENCES `实训项目表` (`项目ID`),
  CONSTRAINT `fk_review_reviewer` FOREIGN KEY (`评分人ID`) REFERENCES `用户表` (`用户ID`),
  CONSTRAINT `fk_review_target` FOREIGN KEY (`被评人ID`) REFERENCES `用户表` (`用户ID`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='学生互评表';

INSERT INTO `学生互评表` (`互评ID`, `项目ID`, `评分人ID`, `被评人ID`, `互评分数`, `评语`, `创建时间`) VALUES
(1, 1, 7, 8, '88.00', '认真负责，操作规范，值得学习', '2026-06-18 12:13:57'),
(2, 1, 7, 9, '85.50', '动手能力强，小组协作好', '2026-06-18 12:13:57'),
(3, 1, 8, 7, '90.00', '实验态度严谨，数据记录完整', '2026-06-18 12:13:57'),
(4, 1, 9, 10, '82.00', '基本操作合格，还需加强理论理解', '2026-06-18 12:13:57'),
(5, 2, 13, 14, '87.00', '田间管理负责，出勤率高', '2026-06-18 12:13:57'),
(6, 2, 14, 13, '91.00', '育种操作熟练，实验设计能力强', '2026-06-18 12:13:57'),
(7, 2, 15, 16, '83.50', '积极配合，按时完成任务', '2026-06-18 12:13:57'),
(8, 2, 16, 15, '86.00', '观察记录详细，动手能力较好', '2026-06-18 12:13:57'),
(9, 4, 8, 10, '88.50', '学习努力，进步显著', '2026-06-18 12:13:57'),
(10, 4, 10, 8, '85.00', '团队意识好，协助他人完成实验', '2026-06-18 12:13:57'),
(11, 5, 9, 12, '89.00', '花卉认知能力强，育苗技术扎实', '2026-06-18 12:13:57'),
(12, 5, 12, 9, '84.00', '需要加强动手操作练习', '2026-06-18 12:13:57');

-- ------------------------------------------------------------
-- Table: 学生报名表  (67 rows)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `学生报名表`;
CREATE TABLE `学生报名表` (
  `报名ID` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '报名主键',
  `项目ID` bigint unsigned NOT NULL COMMENT 'FK→实训项目表',
  `学生ID` bigint unsigned NOT NULL COMMENT 'FK→用户表(学生)',
  `报名状态` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '待审核' COMMENT '待审核/已通过/已拒绝',
  `报名时间` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '报名时间',
  `综合成绩` decimal(5,2) DEFAULT NULL COMMENT '期末综合成绩',
  PRIMARY KEY (`报名ID`),
  UNIQUE KEY `uk_enroll` (`项目ID`,`学生ID`),
  KEY `idx_enroll_project` (`项目ID`),
  KEY `idx_enroll_student` (`学生ID`),
  CONSTRAINT `fk_enroll_project` FOREIGN KEY (`项目ID`) REFERENCES `实训项目表` (`项目ID`),
  CONSTRAINT `fk_enroll_student` FOREIGN KEY (`学生ID`) REFERENCES `用户表` (`用户ID`)
) ENGINE=InnoDB AUTO_INCREMENT=82 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='学生报名表';

INSERT INTO `学生报名表` (`报名ID`, `项目ID`, `学生ID`, `报名状态`, `报名时间`, `综合成绩`) VALUES
(1, 1, 7, '已通过', '2026-02-20 10:00:00', NULL),
(2, 1, 8, '已通过', '2026-02-20 10:30:00', NULL),
(3, 1, 9, '已通过', '2026-02-20 11:00:00', NULL),
(4, 1, 10, '已通过', '2026-02-21 09:00:00', NULL),
(5, 1, 11, '已通过', '2026-02-21 09:30:00', NULL),
(6, 1, 12, '已通过', '2026-02-21 10:00:00', NULL),
(7, 2, 13, '已通过', '2026-02-20 10:00:00', NULL),
(8, 2, 14, '已通过', '2026-02-20 11:00:00', NULL),
(9, 2, 15, '已通过', '2026-02-21 09:00:00', NULL),
(10, 2, 16, '已通过', '2026-02-21 10:00:00', NULL),
(11, 2, 17, '已通过', '2026-02-22 09:00:00', NULL),
(12, 2, 18, '已通过', '2026-02-22 10:00:00', NULL),
(13, 3, 7, '已通过', '2026-02-22 14:00:00', NULL),
(14, 3, 19, '已通过', '2026-02-22 14:30:00', NULL),
(15, 3, 20, '已通过', '2026-02-22 15:00:00', NULL),
(16, 3, 21, '待审核', '2026-02-22 15:30:00', NULL),
(17, 4, 8, '已通过', '2026-02-23 09:00:00', NULL),
(18, 4, 10, '已通过', '2026-02-23 09:30:00', NULL),
(19, 4, 14, '已通过', '2026-02-23 10:00:00', NULL),
(20, 4, 17, '已通过', '2026-02-23 10:30:00', NULL),
(21, 5, 9, '已通过', '2026-02-24 09:00:00', NULL),
(22, 5, 12, '已通过', '2026-02-24 10:00:00', NULL),
(23, 6, 13, '已通过', '2026-02-24 11:00:00', NULL),
(24, 7, 15, '已通过', '2026-02-25 09:00:00', NULL),
(25, 8, 16, '已通过', '2026-02-25 10:00:00', NULL),
(40, 2, 8, '已通过', '2026-06-18 12:08:24', NULL),
(41, 5, 8, '已通过', '2026-06-18 12:08:24', NULL),
(42, 2, 9, '已通过', '2026-06-18 12:08:24', NULL),
(43, 4, 9, '已通过', '2026-06-18 12:08:24', NULL),
(44, 2, 10, '已通过', '2026-06-18 12:08:24', NULL),
(45, 5, 10, '已通过', '2026-06-18 12:08:24', NULL),
(46, 2, 11, '已通过', '2026-06-18 12:08:24', NULL),
(47, 4, 11, '已通过', '2026-06-18 12:08:24', NULL),
(48, 5, 11, '已通过', '2026-06-18 12:08:24', NULL),
(49, 2, 12, '已通过', '2026-06-18 12:08:24', NULL),
(50, 4, 12, '已通过', '2026-06-18 12:08:24', NULL),
(51, 4, 13, '已通过', '2026-06-18 12:08:24', NULL),
(52, 5, 13, '已通过', '2026-06-18 12:08:24', NULL),
(53, 5, 14, '已通过', '2026-06-18 12:08:24', NULL),
(54, 4, 15, '已通过', '2026-06-18 12:08:24', NULL),
(55, 5, 15, '已通过', '2026-06-18 12:08:24', NULL),
(56, 4, 16, '已通过', '2026-06-18 12:08:24', NULL),
(57, 5, 16, '已通过', '2026-06-18 12:08:24', NULL),
(58, 5, 17, '已通过', '2026-06-18 12:08:24', NULL),
(59, 4, 18, '已通过', '2026-06-18 12:08:24', NULL),
(60, 5, 18, '已通过', '2026-06-18 12:08:24', NULL),
(61, 2, 19, '已通过', '2026-06-18 12:08:24', NULL),
(62, 4, 19, '已通过', '2026-06-18 12:08:24', NULL),
(63, 5, 19, '已通过', '2026-06-18 12:08:24', NULL),
(64, 2, 20, '已通过', '2026-06-18 12:08:24', NULL),
(65, 4, 20, '已通过', '2026-06-18 12:08:24', NULL),
(66, 5, 20, '已通过', '2026-06-18 12:08:24', NULL),
(67, 2, 21, '已通过', '2026-06-18 12:08:24', NULL),
(68, 4, 21, '已通过', '2026-06-18 12:08:24', NULL),
(69, 5, 21, '已通过', '2026-06-18 12:08:24', NULL),
(70, 2, 22, '已通过', '2026-06-18 12:08:24', NULL),
(71, 4, 22, '已通过', '2026-06-18 12:08:24', NULL),
(72, 5, 22, '已通过', '2026-06-18 12:08:24', NULL),
(73, 2, 23, '已通过', '2026-06-18 12:08:24', NULL),
(74, 4, 23, '已通过', '2026-06-18 12:08:24', NULL),
(75, 5, 23, '已通过', '2026-06-18 12:08:24', NULL),
(76, 2, 24, '已通过', '2026-06-18 12:08:24', NULL),
(77, 4, 24, '已通过', '2026-06-18 12:08:24', NULL),
(78, 5, 24, '已通过', '2026-06-18 12:08:24', NULL),
(79, 2, 25, '已通过', '2026-06-18 12:08:24', NULL),
(80, 4, 25, '已通过', '2026-06-18 12:08:24', NULL),
(81, 5, 25, '已通过', '2026-06-18 12:08:24', NULL);

-- ------------------------------------------------------------
-- Table: 实训任务表  (8 rows)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `实训任务表`;
CREATE TABLE `实训任务表` (
  `任务ID` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '任务主键',
  `项目ID` bigint unsigned NOT NULL COMMENT 'FK→实训项目表',
  `任务名称` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '任务名称',
  `任务描述` text COLLATE utf8mb4_unicode_ci COMMENT '任务内容说明',
  `截止时间` datetime DEFAULT NULL COMMENT '截止时间',
  `权重` decimal(5,2) DEFAULT '0.00' COMMENT '占总成绩权重(%)',
  `创建时间` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`任务ID`),
  KEY `idx_task_project` (`项目ID`),
  CONSTRAINT `fk_task_project` FOREIGN KEY (`项目ID`) REFERENCES `实训项目表` (`项目ID`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='实训任务表';

INSERT INTO `实训任务表` (`任务ID`, `项目ID`, `任务名称`, `任务描述`, `截止时间`, `权重`, `创建时间`) VALUES
(1, 1, '小麦播种前准备', '整地施肥/种子处理', '2026-03-15 00:00:00', '10.00', '2026-06-17 19:34:27'),
(2, 1, '小麦田间管理', '灌溉/施肥/除草', '2026-05-01 00:00:00', '15.00', '2026-06-17 19:34:27'),
(3, 1, '小麦病虫害防治', '识别与防治', '2026-05-20 00:00:00', '10.00', '2026-06-17 19:34:27'),
(4, 2, '玉米亲本播种', '父母本分期播种', '2026-03-20 00:00:00', '15.00', '2026-06-17 19:34:27'),
(5, 2, '玉米套袋授粉', '杂交授粉操作', '2026-05-01 00:00:00', '20.00', '2026-06-17 19:34:27'),
(6, 3, '营养液配制', '各配方营养液配制', '2026-03-25 00:00:00', '15.00', '2026-06-17 19:34:27'),
(7, 3, '水培系统搭建', '水培设备安装调试', '2026-03-30 00:00:00', '10.00', '2026-06-17 19:34:27'),
(8, 4, '土壤采样', '多点采样法采集土壤样品', '2026-03-25 00:00:00', '10.00', '2026-06-17 19:34:27');

-- ------------------------------------------------------------
-- Table: 实训场地表  (11 rows)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `实训场地表`;
CREATE TABLE `实训场地表` (
  `场地ID` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '场地主键',
  `场地编号` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '如 VN-001',
  `场地名称` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '场地名称',
  `类型ID` int unsigned NOT NULL COMMENT 'FK→场地类型表',
  `面积平米` decimal(10,2) DEFAULT NULL COMMENT '面积(平方米)',
  `主要用途` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '主要用途说明',
  `使用状态` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '空闲' COMMENT '空闲/使用中/维护中',
  `责任人` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '责任人姓名',
  `备注` text COLLATE utf8mb4_unicode_ci COMMENT '其他说明',
  PRIMARY KEY (`场地ID`),
  UNIQUE KEY `场地编号` (`场地编号`),
  KEY `idx_venue_type` (`类型ID`),
  KEY `idx_venue_status` (`使用状态`),
  CONSTRAINT `fk_venue_type` FOREIGN KEY (`类型ID`) REFERENCES `场地类型表` (`类型ID`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='实训场地表';

INSERT INTO `实训场地表` (`场地ID`, `场地编号`, `场地名称`, `类型ID`, `面积平米`, `主要用途`, `使用状态`, `责任人`, `备注`) VALUES
(1, 'VN-001', '1号温室大棚', 1, '250.00', '蔬菜育苗与水培实验', '空闲', '张建国', ''),
(2, 'VN-002', '2号温室大棚', 1, '180.00', '花卉与观赏植物培育', '使用中', '李美华', ''),
(3, 'VN-003', '3号温室大棚', 1, '250.00', '果树嫁接与栽培实验', '空闲', '张建国', ''),
(4, 'VN-004', '东区试验田A区', 2, '500.00', '小麦育种与栽培实验', '使用中', '王志强', ''),
(5, 'VN-005', '东区试验田B区', 2, '450.00', '玉米杂交实验', '空闲', '王志强', ''),
(6, 'VN-006', '西区试验田', 2, '600.00', '大豆与杂粮栽培', '维护中', '赵春梅', '灌溉系统维修'),
(7, 'VN-007', '植物生理实验室', 3, '80.00', '植物光合作用与生理指标检测', '空闲', '刘明辉', ''),
(8, 'VN-008', '土壤分析实验室', 3, '60.00', '土壤成分分析', '空闲', '刘明辉', ''),
(9, 'VN-009', '南示范田', 2, '800.00', '新品种展示与示范', '使用中', '赵春梅', ''),
(10, 'VN-010', '微生物培养室', 3, '40.00', '微生物与菌剂培养', '空闲', '刘明辉', ''),
(11, 'VN-011', '4号温室大棚', 1, '666.00', '种植大蒜', '使用中', '管理员', '没事就来种大蒜');

-- ------------------------------------------------------------
-- Table: 实训报告表  (5 rows)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `实训报告表`;
CREATE TABLE `实训报告表` (
  `报告ID` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '报告主键',
  `报名ID` bigint unsigned NOT NULL COMMENT 'FK→学生报名表(唯一)',
  `任务ID` bigint unsigned DEFAULT NULL COMMENT 'FK→实训任务表',
  `报告内容` text COLLATE utf8mb4_unicode_ci COMMENT '报告正文',
  `文件路径` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '附件路径',
  `提交时间` datetime DEFAULT NULL COMMENT '提交时间',
  `报告成绩` decimal(5,2) DEFAULT NULL COMMENT '报告得分',
  `教师评语` text COLLATE utf8mb4_unicode_ci COMMENT '教师评语',
  `评分时间` datetime DEFAULT NULL COMMENT '评分时间',
  PRIMARY KEY (`报告ID`),
  UNIQUE KEY `报名ID` (`报名ID`),
  KEY `idx_report_enroll` (`报名ID`),
  KEY `idx_report_task` (`任务ID`),
  CONSTRAINT `fk_report_enroll` FOREIGN KEY (`报名ID`) REFERENCES `学生报名表` (`报名ID`),
  CONSTRAINT `fk_report_task` FOREIGN KEY (`任务ID`) REFERENCES `实训任务表` (`任务ID`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='实训报告表';

INSERT INTO `实训报告表` (`报告ID`, `报名ID`, `任务ID`, `报告内容`, `文件路径`, `提交时间`, `报告成绩`, `教师评语`, `评分时间`) VALUES
(1, 1, 1, '按操作规程完成整地，施用基肥50kg/亩...', NULL, '2026-03-14 16:00:00', '88.00', '完成良好', '2026-03-16 10:00:00'),
(2, 2, 1, '完成种子精选，发芽率检测95%...', NULL, '2026-03-15 17:00:00', '92.00', '操作规范', '2026-03-17 09:00:00'),
(3, 7, 4, '按杂交育种规程完成亲本播种...', NULL, '2026-03-19 15:00:00', '85.00', '需注意行比', '2026-03-22 10:00:00'),
(4, 13, 6, '完成营养液配制，各元素配比正确...', NULL, '2026-03-24 16:30:00', '90.00', '配比准确', '2026-03-26 09:00:00'),
(5, 17, 8, '完成三个采样点土样采集...', NULL, '2026-03-24 17:00:00', '78.00', '采样点选择可优化', '2026-03-27 10:00:00');

-- ------------------------------------------------------------
-- Table: 实训项目表  (8 rows)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `实训项目表`;
CREATE TABLE `实训项目表` (
  `项目ID` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '项目主键',
  `项目名称` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '项目名称',
  `项目描述` text COLLATE utf8mb4_unicode_ci COMMENT '项目描述',
  `场地ID` bigint unsigned DEFAULT NULL COMMENT 'FK→实训场地表',
  `学期ID` int unsigned DEFAULT NULL COMMENT 'FK→学期表',
  `负责教师ID` bigint unsigned DEFAULT NULL COMMENT 'FK→用户表(教师)',
  `开始日期` date DEFAULT NULL COMMENT '开始日期',
  `结束日期` date DEFAULT NULL COMMENT '结束日期',
  `人数上限` int unsigned DEFAULT '30' COMMENT '最大报名人数',
  `项目状态` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '招募中' COMMENT '招募中/进行中/已结束',
  `创建时间` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`项目ID`),
  KEY `idx_project_venue` (`场地ID`),
  KEY `idx_project_semester` (`学期ID`),
  KEY `idx_project_teacher` (`负责教师ID`),
  CONSTRAINT `fk_project_semester` FOREIGN KEY (`学期ID`) REFERENCES `学期表` (`学期ID`),
  CONSTRAINT `fk_project_teacher` FOREIGN KEY (`负责教师ID`) REFERENCES `用户表` (`用户ID`),
  CONSTRAINT `fk_project_venue` FOREIGN KEY (`场地ID`) REFERENCES `实训场地表` (`场地ID`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='实训项目表';

INSERT INTO `实训项目表` (`项目ID`, `项目名称`, `项目描述`, `场地ID`, `学期ID`, `负责教师ID`, `开始日期`, `结束日期`, `人数上限`, `项目状态`, `创建时间`) VALUES
(1, '小麦高产栽培技术实训', '学习小麦从播种到收获的全流程栽培技术', 4, 2, 2, '2026-03-02', '2026-06-30', 15, '进行中', '2026-06-17 19:34:27'),
(2, '玉米杂交育种实验', '掌握玉米杂交套袋授粉等技术操作', 5, 2, 4, '2026-03-01', '2026-07-01', 60, '进行中', '2026-06-17 19:34:27'),
(3, '温室蔬菜无土栽培', '学习水培与基质栽培技术', 1, 2, 2, '2026-03-10', '2026-06-20', 10, '进行中', '2026-06-17 19:34:27'),
(4, '土壤养分检测与分析', '掌握土壤采样与实验室分析技能', 8, 2, 6, '2026-03-15', '2026-05-30', 60, '招募中', '2026-06-17 19:34:27'),
(5, '花卉育苗与养护', '温室花卉播种育苗全流程实训', 2, 2, 3, '2026-03-05', '2026-06-15', 60, '招募中', '2026-06-17 19:34:27'),
(6, '食用菌栽培技术', '香菇菌棒制作与出菇管理', 10, 2, 5, '2026-03-20', '2026-06-10', 8, '招募中', '2026-06-17 19:34:27'),
(7, '植物病害诊断与防治', '常见作物病害识别与药剂防治', 7, 2, 6, '2026-04-01', '2026-06-25', 10, '已结束', '2026-06-17 19:34:27'),
(8, '果树嫁接技术实训', '苹果苗木嫁接与后期管理', 3, 2, 3, '2026-03-25', '2026-06-30', 8, '招募中', '2026-06-17 19:34:27');

-- ------------------------------------------------------------
-- Table: 操作日志表  (41 rows)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `操作日志表`;
CREATE TABLE `操作日志表` (
  `日志ID` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '日志主键',
  `用户ID` bigint unsigned DEFAULT NULL COMMENT '操作用户 FK→用户表',
  `模块` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '如：场地/项目',
  `操作类型` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '增/删/改/查',
  `目标类型` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '目标表名',
  `目标ID` bigint unsigned DEFAULT NULL COMMENT '目标记录ID',
  `描述` text COLLATE utf8mb4_unicode_ci COMMENT '操作详情',
  `操作时间` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
  PRIMARY KEY (`日志ID`),
  KEY `idx_log_user` (`用户ID`),
  KEY `idx_log_time` (`操作时间`),
  KEY `idx_log_module` (`模块`),
  CONSTRAINT `fk_log_user` FOREIGN KEY (`用户ID`) REFERENCES `用户表` (`用户ID`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=46 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='操作日志表';

INSERT INTO `操作日志表` (`日志ID`, `用户ID`, `模块`, `操作类型`, `目标类型`, `目标ID`, `描述`, `操作时间`) VALUES
(1, 1, '场地', '新增', '实训场地表', 1, '新增1号温室大棚', '2026-06-17 19:34:27'),
(2, 1, '器材', '新增', '器材档案表', 1, '新增园艺铁锹', '2026-06-17 19:34:27'),
(3, 2, '项目', '新增', '实训项目表', 1, '发布小麦高产栽培技术实训', '2026-06-17 19:34:27'),
(4, 7, '报名', '新增', '学生报名表', 1, '学生陈晓宇报名小麦项目', '2026-06-17 19:34:27'),
(5, 2, '签到', '新增', '签到记录表', 1, '场次1签到', '2026-06-17 19:34:27'),
(6, 2, '考勤', '新增', '考勤场次表', 9, '发布考勤场次（2026-06-22）', '2026-06-17 19:42:01'),
(9, 1, '器材', '删除', '器材档案表', 20, '删除器材 恒温培养箱', '2026-06-17 19:45:37'),
(10, 1, '器材', '删除', '器材档案表', 19, '删除器材 标本瓶', '2026-06-17 19:45:42'),
(13, 2, '用户', '修改', '用户表', 2, '修改密码', '2026-06-17 21:53:26'),
(14, 7, '用户', '修改', '用户表', 7, '修改密码', '2026-06-17 21:54:02'),
(15, 22, '用户', '修改', '用户表', 22, '修改密码', '2026-06-17 21:56:18'),
(16, 22, '用户', '修改', '用户表', 22, '修改密码', '2026-06-17 21:57:11'),
(17, 22, '用户', '修改', '用户表', 22, '修改密码', '2026-06-17 21:57:11'),
(18, 2, '用户', '修改', '用户表', 2, '修改密码', '2026-06-17 21:59:35'),
(19, 2, '用户', '修改', '用户表', 2, '修改密码', '2026-06-17 22:00:09'),
(20, 1, '场地', '新增', '实训场地表', 11, '新增场地 4号温室大棚', '2026-06-17 22:10:29'),
(21, 1, '用户', '新增', '用户表', NULL, '管理员 批量新增了23名学生（s018~s040），学生总数达40人', '2026-06-18 11:24:22'),
(22, 1, '用户', '修改', '用户表', 1, '修改密码', '2026-06-18 11:27:47'),
(23, 1, '用户', '修改', '用户表', 1, '修改密码', '2026-06-18 11:28:15'),
(24, 1, '作物', '新增', '培育批次表', 1, '系统管理员 新增了培育批次「001」（数量50株）', '2026-06-18 11:42:51'),
(25, 2, '器材', '修改', '器材档案表', 1, '张建国 修改了器材「榔头」信息', '2026-06-18 11:43:56'),
(26, 2, '作物', '新增', '培育批次表', 2, '张建国 新增了培育批次「002」（数量100株）', '2026-06-18 11:54:00'),
(27, 2, '作物', '新增', '培育批次表', 3, '张建国 新增了培育批次「003」（数量99株）', '2026-06-18 11:54:46'),
(28, 2, '作物', '新增', '培育批次表', 4, '张建国 新增了培育批次「004」（数量100株）', '2026-06-18 11:55:13'),
(29, 2, '作物', '新增', '培育批次表', 5, '张建国 新增了培育批次「005」（数量88株）', '2026-06-18 11:55:36'),
(30, 2, '作物', '新增', '培育批次表', 6, '张建国 新增了培育批次「006」（数量666株）', '2026-06-18 11:56:04'),
(31, 2, '作物', '新增', '培育批次表', 7, '张建国 新增了培育批次「007」（数量100株）', '2026-06-18 11:56:42'),
(32, 2, '器材', '修改', '器材档案表', 9, '张建国 修改了器材「光合仪」信息', '2026-06-18 11:57:24'),
(33, 2, '器材', '修改', '器材档案表', 2, '张建国 修改了器材「修枝剪」信息', '2026-06-18 11:57:41'),
(34, 2, '考勤', '新增', '考勤场次表', 10, '发布考勤场次（2026-06-18）', '2026-06-18 11:58:15'),
(35, 7, '器材', '新增', '借用记录表', 16, '陈晓宇 申请借用「榔头」2件', '2026-06-18 12:08:38'),
(36, 1, '器材', '修改', '借用记录表', 15, '系统管理员 确认归还「锄头」2件（库存恢复到30）', '2026-06-18 12:17:15'),
(37, 1, '器材', '新增', '借用记录表', 17, '系统管理员 申请借用「喷雾器」2件', '2026-06-18 12:17:47'),
(38, 1, '器材', '修改', '借用记录表', 17, '系统管理员 审批通过器材借用（喷雾器，借出2件，库存10）', '2026-06-18 12:34:59'),
(39, 1, '器材', '新增', '借用记录表', 18, '系统管理员 申请借用「育苗基质」4件', '2026-06-18 12:37:05'),
(40, 1, '器材', '新增', '借用记录表', 19, '系统管理员 申请借用「育苗基质」3件', '2026-06-18 12:44:39'),
(41, 1, '项目', '新增', '实训项目表', 9, '新增项目 11', '2026-06-18 12:46:15'),
(42, 1, '项目', '删除', '实训项目表', 9, '系统管理员 删除了项目「11」，级联删除0条签到+0场考勤+0条报名', '2026-06-18 12:46:50'),
(43, 2, '考勤', '新增', '考勤场次表', 11, '发布考勤场次（2026-06-18）', '2026-06-18 12:48:15'),
(44, 7, '考勤', '新增', '签到记录表', 88, '陈晓宇 签到成功（场次11）', '2026-06-18 12:48:35'),
(45, 7, '考勤', '新增', '签到记录表', 89, '陈晓宇 签到成功（场次10）', '2026-06-18 12:48:42');

-- ------------------------------------------------------------
-- Table: 教师带队表  (8 rows)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `教师带队表`;
CREATE TABLE `教师带队表` (
  `带队ID` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '带队主键',
  `场次ID` bigint unsigned NOT NULL COMMENT 'FK→考勤场次表',
  `教师ID` bigint unsigned NOT NULL COMMENT 'FK→用户表',
  `送达时间` datetime DEFAULT NULL COMMENT '带队开始时间',
  `离开时间` datetime DEFAULT NULL COMMENT '带队结束时间',
  `备注` text COLLATE utf8mb4_unicode_ci COMMENT '带队备注',
  `创建时间` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`带队ID`),
  KEY `idx_lead_session` (`场次ID`),
  KEY `fk_lead_teacher` (`教师ID`),
  CONSTRAINT `fk_lead_session` FOREIGN KEY (`场次ID`) REFERENCES `考勤场次表` (`场次ID`),
  CONSTRAINT `fk_lead_teacher` FOREIGN KEY (`教师ID`) REFERENCES `用户表` (`用户ID`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='教师带队表';

INSERT INTO `教师带队表` (`带队ID`, `场次ID`, `教师ID`, `送达时间`, `离开时间`, `备注`, `创建时间`) VALUES
(1, 1, 3, '2026-03-09 08:00:00', '2026-03-09 12:00:00', '张建国老师请假，李美华老师代班带队小麦实训', '2026-06-18 12:13:57'),
(2, 2, 4, '2026-03-16 13:00:00', '2026-03-16 17:00:00', '王志强老师协助下午小麦施肥实训', '2026-06-18 12:13:57'),
(3, 3, 5, '2026-03-01 08:00:00', '2026-03-01 11:30:00', '赵春梅老师协助玉米杂交实验', '2026-06-18 12:13:57'),
(4, 4, 6, '2026-03-08 08:00:00', '2026-03-08 11:30:00', '刘明辉老师协助玉米田间管理', '2026-06-18 12:13:57'),
(5, 1, 2, '2026-03-02 08:00:00', '2026-03-02 12:00:00', '张建国老师带队小麦播种实训', '2026-06-18 12:13:57'),
(6, 6, 3, '2026-03-10 08:30:00', '2026-03-10 12:00:00', '李美华老师协助温室蔬菜水培', '2026-06-18 12:13:57'),
(7, 7, 4, '2026-03-17 08:30:00', '2026-03-17 12:00:00', '王志强老师协助温室温度调控实训', '2026-06-18 12:13:57'),
(8, 10, 6, '2026-06-18 08:00:00', '2026-06-18 11:30:00', '刘明辉老师带队大棚实训', '2026-06-18 12:13:57');

-- ------------------------------------------------------------
-- Table: 消耗记录表  (8 rows)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `消耗记录表`;
CREATE TABLE `消耗记录表` (
  `消耗ID` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '消耗主键',
  `器材ID` bigint unsigned NOT NULL COMMENT 'FK→器材档案表',
  `项目ID` bigint unsigned DEFAULT NULL COMMENT 'FK→实训项目表',
  `消耗数量` int unsigned NOT NULL COMMENT '消耗数量',
  `消耗日期` date NOT NULL COMMENT '消耗日期',
  `记录人ID` bigint unsigned DEFAULT NULL COMMENT 'FK→用户表',
  `备注` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '备注说明',
  PRIMARY KEY (`消耗ID`),
  KEY `idx_consum_equip` (`器材ID`),
  KEY `idx_consum_project` (`项目ID`),
  KEY `fk_consum_recorder` (`记录人ID`),
  CONSTRAINT `fk_consum_equip` FOREIGN KEY (`器材ID`) REFERENCES `器材档案表` (`器材ID`),
  CONSTRAINT `fk_consum_project` FOREIGN KEY (`项目ID`) REFERENCES `实训项目表` (`项目ID`),
  CONSTRAINT `fk_consum_recorder` FOREIGN KEY (`记录人ID`) REFERENCES `用户表` (`用户ID`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='消耗记录表';

INSERT INTO `消耗记录表` (`消耗ID`, `器材ID`, `项目ID`, `消耗数量`, `消耗日期`, `记录人ID`, `备注`) VALUES
(1, 11, 1, 3, '2026-03-02', 2, '小麦播种基质消耗'),
(2, 12, 4, 2, '2026-03-15', 6, '土壤实验肥力添加'),
(3, 13, 3, 1, '2026-03-17', 2, '蔬菜病害防治'),
(9, 1, 1, 5, '2026-06-16', 1, '项目实验消耗'),
(10, 2, 2, 3, '2026-06-17', 1, '日常教学消耗'),
(11, 3, 3, 8, '2026-06-19', 2, '实训课使用'),
(12, 4, 4, 12, '2026-06-20', 2, '防护用品消耗'),
(13, 5, 5, 2, '2026-06-21', 1, '加工实训消耗');

-- ------------------------------------------------------------
-- Table: 生长观测表  (10 rows)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `生长观测表`;
CREATE TABLE `生长观测表` (
  `观测ID` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '观测主键',
  `批次ID` bigint unsigned NOT NULL COMMENT 'FK→培育批次表',
  `观测日期` date NOT NULL COMMENT '观测日期',
  `株高CM` decimal(8,2) DEFAULT NULL COMMENT '株高(厘米)',
  `叶片数` int unsigned DEFAULT NULL COMMENT '叶片数量',
  `健康状态` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '健康/轻微异常/严重异常',
  `备注` text COLLATE utf8mb4_unicode_ci COMMENT '观测备注',
  `观测人ID` bigint unsigned DEFAULT NULL COMMENT 'FK→用户表',
  PRIMARY KEY (`观测ID`),
  KEY `idx_obs_batch` (`批次ID`),
  KEY `fk_obs_observer` (`观测人ID`),
  CONSTRAINT `fk_obs_batch` FOREIGN KEY (`批次ID`) REFERENCES `培育批次表` (`批次ID`),
  CONSTRAINT `fk_obs_observer` FOREIGN KEY (`观测人ID`) REFERENCES `用户表` (`用户ID`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='生长观测表';

INSERT INTO `生长观测表` (`观测ID`, `批次ID`, `观测日期`, `株高CM`, `叶片数`, `健康状态`, `备注`, `观测人ID`) VALUES
(1, 1, '2026-06-20', '12.50', 4, '健康', '株高正常增长，叶片深绿', 7),
(2, 1, '2026-06-27', '18.30', 6, '健康', '进入快速生长期', 8),
(3, 2, '2026-06-22', '25.00', 8, '健康', '叶片宽大，茎秆粗壮', 9),
(4, 2, '2026-06-29', '32.50', 10, '亚健康', '部分叶片出现黄斑，需加强水肥管理', 10),
(5, 3, '2026-06-25', '85.00', 22, '健康', '即将进入收获期，颗粒饱满', 11),
(6, 3, '2026-07-02', '92.00', 24, '健康', '成熟度良好，预计下周可收获', 12),
(7, 4, '2026-06-24', '8.00', 3, '健康', '出苗整齐，长势良好', 13),
(8, 4, '2026-07-01', '15.20', 5, '亚健康', '发现少量蚜虫，已做初步处理', 14),
(9, 5, '2026-06-26', '45.00', 14, '健康', '株型紧凑，叶色正常', 15),
(10, 6, '2026-06-28', '120.00', 30, '健康', '进入抽穗期，穗型良好', 16);

-- ------------------------------------------------------------
-- Table: 用户表  (46 rows)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `用户表`;
CREATE TABLE `用户表` (
  `用户ID` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '用户主键',
  `用户名` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '登录名',
  `真实姓名` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '显示名称',
  `学号工号` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '学号或工号',
  `角色ID` tinyint unsigned NOT NULL DEFAULT '3' COMMENT 'FK→角色表',
  `密码哈希` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'bcrypt 哈希',
  `手机号` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '联系电话',
  `邮箱` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '电子邮箱',
  `是否启用` tinyint(1) NOT NULL DEFAULT '1' COMMENT '1=启用 0=停用',
  `创建时间` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`用户ID`),
  UNIQUE KEY `用户名` (`用户名`),
  UNIQUE KEY `学号工号` (`学号工号`),
  KEY `idx_user_role` (`角色ID`),
  KEY `idx_user_name` (`真实姓名`),
  CONSTRAINT `fk_user_role` FOREIGN KEY (`角色ID`) REFERENCES `角色表` (`角色ID`)
) ENGINE=InnoDB AUTO_INCREMENT=47 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统用户表';

INSERT INTO `用户表` (`用户ID`, `用户名`, `真实姓名`, `学号工号`, `角色ID`, `密码哈希`, `手机号`, `邮箱`, `是否启用`, `创建时间`) VALUES
(1, 'admin', '系统管理员', 'A001', 1, 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', '13800000001', 'admin@henau.edu.cn', 1, '2025-01-01 08:00:00'),
(2, 't001', '张建国', 'T001', 2, 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', '13800000002', 'zhangjg@henau.edu.cn', 1, '2025-01-01 08:00:00'),
(3, 't002', '李美华', 'T002', 2, 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', '13800000003', 'limh@henau.edu.cn', 1, '2025-01-01 08:00:00'),
(4, 't003', '王志强', 'T003', 2, 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', '13800000004', 'wangzq@henau.edu.cn', 1, '2025-01-01 08:00:00'),
(5, 't004', '赵春梅', 'T004', 2, 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', '13800000005', 'zhaocm@henau.edu.cn', 1, '2025-01-01 08:00:00'),
(6, 't005', '刘明辉', 'T005', 2, 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', '13800000006', 'liumh@henau.edu.cn', 1, '2025-01-01 08:00:00'),
(7, 's001', '陈晓宇', '20230101', 3, 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', '13900000001', '', 1, '2025-09-01 08:00:00'),
(8, 's002', '林小芳', '20230102', 3, 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', '13900000002', '', 1, '2025-09-01 08:00:00'),
(9, 's003', '周大鹏', '20230103', 3, 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', '13900000003', '', 1, '2025-09-01 08:00:00'),
(10, 's004', '吴丽丽', '20230104', 3, 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', '13900000004', '', 1, '2025-09-01 08:00:00'),
(11, 's005', '黄俊杰', '20230105', 3, 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', '13900000005', '', 1, '2025-09-01 08:00:00'),
(12, 's006', '郑美玲', '20230106', 3, 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', '13900000006', '', 1, '2025-09-01 08:00:00'),
(13, 's007', '赵建峰', '20230107', 3, 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', '13900000007', '', 1, '2025-09-01 08:00:00'),
(14, 's008', '孙雅婷', '20230108', 3, 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', '13900000008', '', 1, '2025-09-01 08:00:00'),
(15, 's009', '周昊然', '20230109', 3, 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', '13900000009', '', 1, '2025-09-01 08:00:00'),
(16, 's010', '钱小慧', '20230110', 3, 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', '13900000010', '', 1, '2025-09-01 08:00:00'),
(17, 's011', '林志远', '20230111', 3, 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', '13900000011', '', 1, '2025-09-01 08:00:00'),
(18, 's012', '黄小燕', '20230112', 3, 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', '13900000012', '', 1, '2025-09-01 08:00:00'),
(19, 's013', '马小龙', '20230113', 3, 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', '13900000013', '', 1, '2025-09-01 08:00:00'),
(20, 's014', '刘思雨', '20230114', 3, 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', '13900000014', '', 1, '2025-09-01 08:00:00'),
(21, 's015', '杨浩然', '20230115', 3, 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', '13900000015', '', 1, '2025-09-01 08:00:00'),
(22, 's016', '何小雨', '20230116', 3, 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', '13900000016', '', 1, '2025-09-01 08:00:00'),
(23, 's017', '蒋一鸣', '20230117', 3, 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', '13900000017', '', 1, '2025-09-01 08:00:00'),
(24, 's018', '刘思远', '2022001018', 3, 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', NULL, NULL, 1, '2026-06-18 11:22:10'),
(25, 's019', '王雨晴', '2022001019', 3, 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', NULL, NULL, 1, '2026-06-18 11:22:10'),
(26, 's020', '张浩然', '2022001020', 3, 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', NULL, NULL, 1, '2026-06-18 11:22:10'),
(27, 's021', '陈佳琪', '2022001021', 3, 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', NULL, NULL, 1, '2026-06-18 11:22:10'),
(28, 's022', '赵明哲', '2022001022', 3, 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', NULL, NULL, 1, '2026-06-18 11:22:10'),
(29, 's023', '李欣怡', '2022001023', 3, 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', NULL, NULL, 1, '2026-06-18 11:22:10'),
(30, 's024', '周子涵', '2022001024', 3, 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', NULL, NULL, 1, '2026-06-18 11:22:10'),
(31, 's025', '吴俊杰', '2022001025', 3, 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', NULL, NULL, 1, '2026-06-18 11:22:10'),
(32, 's026', '郑雨桐', '2022001026', 3, 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', NULL, NULL, 1, '2026-06-18 11:22:10'),
(33, 's027', '钱一鸣', '2022001027', 3, 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', NULL, NULL, 1, '2026-06-18 11:22:10'),
(34, 's028', '孙悦然', '2022001028', 3, 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', NULL, NULL, 1, '2026-06-18 11:22:10'),
(35, 's029', '马晓宇', '2022001029', 3, 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', NULL, NULL, 1, '2026-06-18 11:22:10'),
(36, 's030', '黄奕晨', '2022001030', 3, 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', NULL, NULL, 1, '2026-06-18 11:22:10'),
(37, 's031', '林婉婷', '2022001031', 3, 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', NULL, NULL, 1, '2026-06-18 11:22:10'),
(38, 's032', '徐子轩', '2022001032', 3, 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', NULL, NULL, 1, '2026-06-18 11:22:10'),
(39, 's033', '胡雪莹', '2022001033', 3, 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', NULL, NULL, 1, '2026-06-18 11:22:10'),
(40, 's034', '郭志远', '2022001034', 3, 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', NULL, NULL, 1, '2026-06-18 11:22:10'),
(41, 's035', '高诗涵', '2022001035', 3, 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', NULL, NULL, 1, '2026-06-18 11:22:10'),
(42, 's036', '罗宇航', '2022001036', 3, 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', NULL, NULL, 1, '2026-06-18 11:22:10'),
(43, 's037', '梁思琪', '2022001037', 3, 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', NULL, NULL, 1, '2026-06-18 11:22:10'),
(44, 's038', '宋嘉乐', '2022001038', 3, 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', NULL, NULL, 1, '2026-06-18 11:22:10'),
(45, 's039', '唐晓萱', '2022001039', 3, 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', NULL, NULL, 1, '2026-06-18 11:22:10'),
(46, 's040', '韩铭泽', '2022001040', 3, 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', NULL, NULL, 1, '2026-06-18 11:22:10');

-- ------------------------------------------------------------
-- Table: 病虫害防治表  (7 rows)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `病虫害防治表`;
CREATE TABLE `病虫害防治表` (
  `防治ID` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '防治主键',
  `批次ID` bigint unsigned NOT NULL COMMENT 'FK→培育批次表',
  `发现日期` date NOT NULL COMMENT '发现日期',
  `病虫害类型` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '病虫害名称',
  `严重程度` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '轻微/中等/严重',
  `防治措施` text COLLATE utf8mb4_unicode_ci COMMENT '防治措施描述',
  `防治结果` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '防治效果',
  `记录人ID` bigint unsigned DEFAULT NULL COMMENT 'FK→用户表',
  PRIMARY KEY (`防治ID`),
  KEY `idx_pest_batch` (`批次ID`),
  KEY `fk_pest_recorder` (`记录人ID`),
  CONSTRAINT `fk_pest_batch` FOREIGN KEY (`批次ID`) REFERENCES `培育批次表` (`批次ID`),
  CONSTRAINT `fk_pest_recorder` FOREIGN KEY (`记录人ID`) REFERENCES `用户表` (`用户ID`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='病虫害防治表';

INSERT INTO `病虫害防治表` (`防治ID`, `批次ID`, `发现日期`, `病虫害类型`, `严重程度`, `防治措施`, `防治结果`, `记录人ID`) VALUES
(1, 1, '2026-06-22', '蚜虫', '轻度', '喷洒吡虫啉1000倍液，连续3天', '已控制', 2),
(2, 2, '2026-06-25', '白粉病', '中度', '喷洒三唑酮800倍液，加强通风', '好转中', 3),
(3, 3, '2026-06-28', '玉米螟', '轻度', '释放赤眼蜂天敌防治', '已控制', 4),
(4, 4, '2026-07-01', '蚜虫', '轻度', '喷洒啶虫脒1500倍液', '已根治', 5),
(5, 5, '2026-06-30', '灰霉病', '中度', '喷洒腐霉利1000倍液，降低棚内湿度', '好转中', 6),
(6, 6, '2026-07-03', '锈病', '轻度', '喷洒戊唑醇悬浮剂600倍液', '已控制', 2),
(7, 7, '2026-07-05', '潜叶蝇', '轻度', '悬挂黄色粘虫板，喷洒阿维菌素', '已在监控', 3);

-- ------------------------------------------------------------
-- Table: 盘点单表  (7 rows)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `盘点单表`;
CREATE TABLE `盘点单表` (
  `盘点ID` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '盘点主键',
  `盘点日期` date NOT NULL COMMENT '盘点日期',
  `盘点人ID` bigint unsigned DEFAULT NULL COMMENT 'FK→用户表',
  `盘点状态` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '进行中' COMMENT '进行中/已完成',
  `备注` text COLLATE utf8mb4_unicode_ci COMMENT '盘点备注',
  `创建时间` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`盘点ID`),
  KEY `idx_check_date` (`盘点日期`),
  KEY `fk_check_checker` (`盘点人ID`),
  CONSTRAINT `fk_check_checker` FOREIGN KEY (`盘点人ID`) REFERENCES `用户表` (`用户ID`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='盘点单表';

INSERT INTO `盘点单表` (`盘点ID`, `盘点日期`, `盘点人ID`, `盘点状态`, `备注`, `创建时间`) VALUES
(1, '2026-06-15', 1, '已完成', '月度期末器材盘点', '2026-06-18 12:13:57'),
(2, '2026-05-15', 1, '已完成', '5月期中器材盘点', '2026-06-18 12:13:57'),
(3, '2026-04-15', 2, '已完成', '4月器材盘点，张建国老师负责', '2026-06-18 12:13:57'),
(4, '2026-03-15', 2, '已完成', '3月学期初器材盘点', '2026-06-18 12:13:57'),
(5, '2026-06-16', 3, '已完成', '李美华老师负责1号温室工具盘点', '2026-06-18 12:13:57'),
(6, '2026-06-17', 4, '已完成', '王志强老师负责实验室仪器盘点', '2026-06-18 12:13:57'),
(7, '2026-06-18', 1, '进行中', '6月期末全面盘点（进行中）', '2026-06-18 12:13:57');

-- ------------------------------------------------------------
-- Table: 盘点明细表  (18 rows)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `盘点明细表`;
CREATE TABLE `盘点明细表` (
  `明细ID` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '明细主键',
  `盘点ID` bigint unsigned NOT NULL COMMENT 'FK→盘点单表',
  `器材ID` bigint unsigned NOT NULL COMMENT 'FK→器材档案表',
  `账面数量` int unsigned DEFAULT NULL COMMENT '系统账面数量',
  `实盘数量` int unsigned DEFAULT NULL COMMENT '实物盘点数量',
  `差异数量` int DEFAULT NULL COMMENT '差异(=实盘-账面)',
  `差异原因` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '差异原因说明',
  PRIMARY KEY (`明细ID`),
  KEY `idx_detail_check` (`盘点ID`),
  KEY `fk_detail_equip` (`器材ID`),
  CONSTRAINT `fk_detail_check` FOREIGN KEY (`盘点ID`) REFERENCES `盘点单表` (`盘点ID`),
  CONSTRAINT `fk_detail_equip` FOREIGN KEY (`器材ID`) REFERENCES `器材档案表` (`器材ID`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='盘点明细表';

INSERT INTO `盘点明细表` (`明细ID`, `盘点ID`, `器材ID`, `账面数量`, `实盘数量`, `差异数量`, `差异原因`) VALUES
(1, 1, 1, 15, 15, 0, '账实相符'),
(2, 1, 2, 6, 6, 0, '账实相符'),
(3, 1, 3, 2, 1, -1, '1台电动剪枝机送修中'),
(4, 2, 4, 12, 12, 0, '账实相符'),
(5, 2, 5, 28, 28, 0, '账实相符'),
(6, 2, 6, 20, 19, -1, '1台土壤pH计外出借出'),
(7, 3, 9, 2, 2, 0, '账实相符'),
(8, 3, 10, 18, 18, 0, '账实相符'),
(9, 4, 11, 80, 77, -3, '3袋育苗基质已消耗未登记'),
(10, 4, 12, 50, 48, -2, '2袋复合肥已使用'),
(11, 5, 13, 15, 14, -1, '1瓶多菌灵已开瓶使用'),
(12, 5, 14, 50, 50, 0, '账实相符'),
(13, 6, 7, 6, 6, 0, '账实相符'),
(14, 6, 8, 2, 2, 0, '账实相符'),
(15, 7, 15, 10, 10, 0, '账实相符'),
(16, 7, 16, 8, 8, 0, '账实相符'),
(17, 7, 17, 8, 8, 0, '账实相符'),
(18, 7, 18, 25, 25, 0, '账实相符');

-- ------------------------------------------------------------
-- Table: 签到记录表  (59 rows)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `签到记录表`;
CREATE TABLE `签到记录表` (
  `签到ID` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '签到主键',
  `场次ID` bigint unsigned NOT NULL COMMENT 'FK→考勤场次表',
  `学生ID` bigint unsigned NOT NULL COMMENT 'FK→用户表',
  `签到时间` datetime DEFAULT NULL COMMENT '实际签到时间',
  `签到状态` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '缺勤' COMMENT '出勤/迟到/请假/缺勤',
  PRIMARY KEY (`签到ID`),
  UNIQUE KEY `uk_attendance` (`场次ID`,`学生ID`),
  KEY `idx_att_session` (`场次ID`),
  KEY `idx_att_student` (`学生ID`),
  CONSTRAINT `fk_att_session` FOREIGN KEY (`场次ID`) REFERENCES `考勤场次表` (`场次ID`),
  CONSTRAINT `fk_att_student` FOREIGN KEY (`学生ID`) REFERENCES `用户表` (`用户ID`)
) ENGINE=InnoDB AUTO_INCREMENT=90 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='签到记录表';

INSERT INTO `签到记录表` (`签到ID`, `场次ID`, `学生ID`, `签到时间`, `签到状态`) VALUES
(1, 1, 7, '2026-03-02 07:55:00', '出勤'),
(2, 1, 8, '2026-03-02 07:58:00', '出勤'),
(3, 1, 9, '2026-03-02 08:05:00', '出勤'),
(4, 1, 10, '2026-03-02 08:20:00', '迟到'),
(5, 1, 11, '2026-03-02 07:50:00', '出勤'),
(6, 1, 12, '2026-03-02 08:02:00', '出勤'),
(7, 2, 7, '2026-03-09 07:56:00', '出勤'),
(8, 2, 8, '2026-03-09 08:10:00', '出勤'),
(9, 2, 9, '2026-03-09 07:59:00', '出勤'),
(10, 2, 10, '2026-03-09 07:55:00', '出勤'),
(11, 2, 11, '2026-03-09 08:01:00', '出勤'),
(12, 2, 12, '2026-03-09 08:18:00', '迟到'),
(13, 3, 7, '2026-03-16 13:02:00', '出勤'),
(14, 3, 8, '2026-03-16 13:05:00', '出勤'),
(15, 3, 10, '2026-03-16 12:58:00', '出勤'),
(16, 3, 11, '2026-03-16 13:10:00', '出勤'),
(17, 3, 12, '2026-03-16 13:20:00', '迟到'),
(18, 4, 13, '2026-03-01 07:55:00', '出勤'),
(19, 4, 14, '2026-03-01 08:00:00', '出勤'),
(20, 4, 15, '2026-03-01 08:03:00', '出勤'),
(21, 4, 16, '2026-03-01 07:58:00', '出勤'),
(22, 4, 17, '2026-03-01 08:10:00', '出勤'),
(23, 4, 18, '2026-03-01 08:25:00', '迟到'),
(24, 5, 13, '2026-03-08 07:50:00', '出勤'),
(25, 5, 14, '2026-03-08 08:02:00', '出勤'),
(26, 5, 16, '2026-03-08 07:59:00', '出勤'),
(27, 5, 17, '2026-03-08 08:05:00', '出勤'),
(28, 6, 7, '2026-03-10 08:28:00', '出勤'),
(29, 6, 19, '2026-03-10 08:31:00', '出勤'),
(30, 6, 20, '2026-03-10 08:50:00', '迟到'),
(31, 5, 7, '2026-06-17 19:43:14', '迟到'),
(32, 7, 7, '2026-06-17 19:48:21', '迟到'),
(63, 1, 4, '2026-06-18 12:08:24', '迟到'),
(64, 2, 4, '2026-06-18 12:08:24', '迟到'),
(65, 4, 4, '2026-06-18 12:08:24', '迟到'),
(66, 5, 4, '2026-06-18 12:08:24', '迟到'),
(67, 7, 4, '2026-06-18 12:08:24', '迟到'),
(68, 1, 5, '2026-06-18 12:08:24', '迟到'),
(69, 2, 5, '2026-06-18 12:08:24', '迟到'),
(70, 4, 5, '2026-06-18 12:08:24', '迟到'),
(71, 5, 5, '2026-06-18 12:08:24', '迟到'),
(72, 7, 5, '2026-06-18 12:08:24', '迟到'),
(73, 1, 6, '2026-06-18 12:08:24', '迟到'),
(74, 2, 6, '2026-06-18 12:08:24', '迟到'),
(75, 4, 6, '2026-06-18 12:08:24', '迟到'),
(76, 5, 6, '2026-06-18 12:08:24', '迟到'),
(77, 7, 6, '2026-06-18 12:08:24', '迟到'),
(78, 4, 7, '2026-06-18 12:08:24', '迟到'),
(79, 4, 8, '2026-06-18 12:08:24', '迟到'),
(80, 5, 8, '2026-06-18 12:08:24', '迟到'),
(81, 7, 8, '2026-06-18 12:08:24', '迟到'),
(82, 4, 9, '2026-06-18 12:08:24', '迟到'),
(83, 5, 9, '2026-06-18 12:08:24', '迟到'),
(84, 7, 9, '2026-06-18 12:08:24', '迟到'),
(85, 4, 10, '2026-06-18 12:08:24', '迟到'),
(86, 5, 10, '2026-06-18 12:08:24', '迟到'),
(87, 7, 10, '2026-06-18 12:08:24', '迟到'),
(88, 11, 7, '2026-06-18 12:48:35', '迟到'),
(89, 10, 7, '2026-06-18 12:48:42', '迟到');

-- ------------------------------------------------------------
-- Table: 系统字典  (7 rows)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `系统字典`;
CREATE TABLE `系统字典` (
  `字典ID` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '字典主键',
  `字典类型` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '如：用户性别、场地状态',
  `字典键` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '内部编码',
  `字典值` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '显示标签',
  `排序` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '排序号',
  `是否启用` tinyint(1) NOT NULL DEFAULT '1' COMMENT '1=启用 0=停用',
  PRIMARY KEY (`字典ID`),
  UNIQUE KEY `uk_dict_type_key` (`字典类型`,`字典键`),
  KEY `idx_dict_type` (`字典类型`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统字典表';

INSERT INTO `系统字典` (`字典ID`, `字典类型`, `字典键`, `字典值`, `排序`, `是否启用`) VALUES
(1, '场地状态', 'idle', '空闲', 1, 1),
(2, '场地状态', 'in_use', '使用中', 2, 1),
(3, '场地状态', 'maint', '维护中', 3, 1),
(4, '生长状态', 'seeding', '播种期', 1, 1),
(5, '生长状态', 'growing', '生长期', 2, 1),
(6, '生长状态', 'harvest', '收获期', 3, 1),
(7, '生长状态', 'abnormal', '异常', 4, 1);

-- ------------------------------------------------------------
-- Table: 考勤场次表  (10 rows)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `考勤场次表`;
CREATE TABLE `考勤场次表` (
  `场次ID` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '场次主键',
  `项目ID` bigint unsigned NOT NULL COMMENT 'FK→实训项目表',
  `场次日期` date NOT NULL COMMENT '考勤日期',
  `开始时间` time NOT NULL COMMENT '预定开始时间',
  `结束时间` time DEFAULT NULL COMMENT '预定结束时间',
  `地点` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '考勤地点',
  `实到人数` int unsigned DEFAULT '0' COMMENT '实际签到人数',
  `带队教师ID` bigint unsigned DEFAULT NULL COMMENT 'FK→用户表',
  `创建时间` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`场次ID`),
  KEY `idx_session_project` (`项目ID`),
  KEY `idx_session_date` (`场次日期`),
  KEY `fk_session_teacher` (`带队教师ID`),
  CONSTRAINT `fk_session_project` FOREIGN KEY (`项目ID`) REFERENCES `实训项目表` (`项目ID`),
  CONSTRAINT `fk_session_teacher` FOREIGN KEY (`带队教师ID`) REFERENCES `用户表` (`用户ID`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='考勤场次表';

INSERT INTO `考勤场次表` (`场次ID`, `项目ID`, `场次日期`, `开始时间`, `结束时间`, `地点`, `实到人数`, `带队教师ID`, `创建时间`) VALUES
(1, 1, '2026-03-02', '8:00:00', '11:30:00', '4号试验田', 9, 2, '2026-06-17 19:34:27'),
(2, 1, '2026-03-09', '8:00:00', '11:30:00', '4号试验田', 9, 2, '2026-06-17 19:34:27'),
(3, 1, '2026-03-16', '13:00:00', '17:00:00', '4号试验田', 5, 2, '2026-06-17 19:34:27'),
(4, 2, '2026-03-01', '8:00:00', '11:30:00', '5号试验田', 13, 4, '2026-06-17 19:34:27'),
(5, 2, '2026-03-08', '8:00:00', '11:30:00', '5号试验田', 11, 4, '2026-06-17 19:34:27'),
(6, 3, '2026-03-10', '8:30:00', '12:00:00', '1号温室', 3, 2, '2026-06-17 19:34:27'),
(7, 3, '2026-03-17', '8:30:00', '12:00:00', '1号温室', 7, 2, '2026-06-17 19:34:27'),
(8, 4, '2026-03-15', '14:00:00', '17:30:00', '土壤分析实验室', 0, 6, '2026-06-17 19:34:27'),
(10, 3, '2026-06-18', '8:00:00', '11:30:00', '1号大棚', 1, 2, '2026-06-18 11:58:15'),
(11, 3, '2026-06-18', '8:00:00', '11:30:00', '1', 1, 2, '2026-06-18 12:48:15');

-- ------------------------------------------------------------
-- Table: 角色表  (3 rows)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `角色表`;
CREATE TABLE `角色表` (
  `角色ID` tinyint unsigned NOT NULL AUTO_INCREMENT COMMENT '角色主键',
  `角色名称` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '管理员/教师/学生',
  `权限列表` text COLLATE utf8mb4_unicode_ci COMMENT 'JSON 权限描述',
  `描述` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '角色说明',
  PRIMARY KEY (`角色ID`),
  UNIQUE KEY `角色名称` (`角色名称`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户角色表';

INSERT INTO `角色表` (`角色ID`, `角色名称`, `权限列表`, `描述`) VALUES
(1, '管理员', '{"all": true}', '系统管理员，拥有全部权限'),
(2, '教师', '{"venue": "rwu", "crop": "rwu", "project": "rwu", "equip": "rw", "attendance": "rwu", "user": "r"}', '教师用户'),
(3, '学生', '{"project": "r", "attendance": "r", "report": "rw", "equip": "r"}', '学生用户');

-- ------------------------------------------------------------
-- Table: 请假申请表  (8 rows)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `请假申请表`;
CREATE TABLE `请假申请表` (
  `请假ID` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '请假主键',
  `学生ID` bigint unsigned NOT NULL COMMENT 'FK→用户表',
  `项目ID` bigint unsigned NOT NULL COMMENT 'FK→实训项目表',
  `场次ID` bigint unsigned DEFAULT NULL COMMENT 'FK→考勤场次表(NULL=全天)',
  `请假类型` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '事假' COMMENT '事假/病假/公务',
  `请假原因` text COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '请假事由',
  `开始时间` datetime NOT NULL COMMENT '请假开始',
  `结束时间` datetime NOT NULL COMMENT '请假结束',
  `审批状态` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '待审批' COMMENT '待审批/已批准/已拒绝',
  `审批人ID` bigint unsigned DEFAULT NULL COMMENT 'FK→用户表',
  `申请时间` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '申请时间',
  `审批时间` datetime DEFAULT NULL COMMENT '审批时间',
  PRIMARY KEY (`请假ID`),
  KEY `idx_leave_student` (`学生ID`),
  KEY `idx_leave_project` (`项目ID`),
  KEY `fk_leave_session` (`场次ID`),
  KEY `fk_leave_approver` (`审批人ID`),
  CONSTRAINT `fk_leave_approver` FOREIGN KEY (`审批人ID`) REFERENCES `用户表` (`用户ID`),
  CONSTRAINT `fk_leave_project` FOREIGN KEY (`项目ID`) REFERENCES `实训项目表` (`项目ID`),
  CONSTRAINT `fk_leave_session` FOREIGN KEY (`场次ID`) REFERENCES `考勤场次表` (`场次ID`),
  CONSTRAINT `fk_leave_student` FOREIGN KEY (`学生ID`) REFERENCES `用户表` (`用户ID`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='请假申请表';

INSERT INTO `请假申请表` (`请假ID`, `学生ID`, `项目ID`, `场次ID`, `请假类型`, `请假原因`, `开始时间`, `结束时间`, `审批状态`, `审批人ID`, `申请时间`, `审批时间`) VALUES
(1, 7, 1, 1, '病假', '感冒发烧，需卧床休息', '2026-03-15 08:00:00', '2026-03-16 17:00:00', '已通过', 2, '2026-03-15 07:30:00', '2026-03-15 08:00:00'),
(2, 8, 1, 2, '事假', '参加省级竞赛', '2026-03-08 08:00:00', '2026-03-09 17:00:00', '已通过', 2, '2026-03-07 20:00:00', '2026-03-07 21:00:00'),
(3, 11, 2, 4, '病假', '急性肠胃炎', '2026-03-02 08:00:00', '2026-03-02 11:30:00', '已通过', 4, '2026-03-01 22:00:00', '2026-03-02 07:00:00'),
(4, 14, 2, 5, '事假', '家中有急事需回家处理', '2026-03-07 08:00:00', '2026-03-07 11:30:00', '已通过', 4, '2026-03-06 18:00:00', '2026-03-06 20:00:00'),
(5, 17, 2, NULL, '病假', '腿部受伤，无法参与本次实训', '2026-03-05 00:00:00', '2026-03-15 23:59:00', '待审批', NULL, '2026-03-05 09:00:00', NULL),
(6, 7, 3, 6, '事假', '参加校运会训练', '2026-03-11 08:30:00', '2026-03-11 12:00:00', '已拒绝', 2, '2026-03-10 15:00:00', '2026-03-10 16:00:00'),
(7, 20, 3, 7, '事假', '参加社团活动', '2026-03-17 08:30:00', '2026-03-17 12:00:00', '待审批', NULL, '2026-03-16 20:00:00', NULL),
(8, 9, 4, 8, '病假', '眼睛发炎，不能接触化学试剂', '2026-03-14 14:00:00', '2026-03-14 17:30:00', '已通过', 6, '2026-03-14 12:00:00', '2026-03-14 13:00:00');

-- ------------------------------------------------------------
-- Table: 通知公告表  (5 rows)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `通知公告表`;
CREATE TABLE `通知公告表` (
  `公告ID` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '公告主键',
  `标题` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '公告标题',
  `内容` text COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '公告正文',
  `发布人ID` bigint unsigned NOT NULL COMMENT 'FK→用户表',
  `是否置顶` tinyint(1) NOT NULL DEFAULT '0' COMMENT '1=置顶 0=普通',
  `发布时间` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '发布时间',
  PRIMARY KEY (`公告ID`),
  KEY `idx_notice_pub` (`发布人ID`),
  CONSTRAINT `fk_notice_pub` FOREIGN KEY (`发布人ID`) REFERENCES `用户表` (`用户ID`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='通知公告表';

INSERT INTO `通知公告表` (`公告ID`, `标题`, `内容`, `发布人ID`, `是否置顶`, `发布时间`) VALUES
(1, '关于2026年春季实训基地开放安排的通知', '本学期实训基地将于2月16日正式开放...', 1, 1, '2026-02-10 08:00:00'),
(2, '实训安全培训通知', '请所有参加实训项目的同学于2月25日前完成安全培训...', 2, 0, '2026-02-18 09:00:00'),
(3, '关于器材借用的管理规定', '即日起器材借用需提前一天申请...', 1, 1, '2026-03-01 10:00:00'),
(4, '2026夏季实训安全须知', '各位老师、同学：夏季高温炎热，请务必注意以下事项：1. 外出实训注意防晒防暑；2. 温室大棚实训注意通风；3. 农药操作必须佩戴防护用具。安全第一，实训第二！', 1, 1, '2026-06-01 08:00:00'),
(5, '关于延长实训基地开放时间的通知', '为了更好地服务同学们的实训需求，经院领导研究决定，自2026年6月20日起，实训基地（1-5号试验田、1-2号温室）晚间开放时间延长至21:00。请同学们合理安排实训时间，注意晚间安全。', 1, 0, '2026-06-15 10:00:00');

SET FOREIGN_KEY_CHECKS = 1;
