-- ============================================================
--  河南农业大学实训管理系统 — 数据库系统原理课程设计
--  数据库系统原理 课程设计 | MySQL 8.0+ | InnoDB | utf8mb4
--  30 张表 | 7 个触发器 | 5 个视图 | 3 个存储过程 | 1 个函数
--  表名/字段名全中文，与 models.py 完全对齐
-- ============================================================

CREATE DATABASE IF NOT EXISTS 河南农业大学实训管理系统
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE 河南农业大学实训管理系统;
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================
--  模块0：基础体系 (5 张表)
-- ============================================================

-- 0-1 系统字典表
CREATE TABLE IF NOT EXISTS 系统字典 (
    字典ID      BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT '字典主键',
    字典类型    VARCHAR(64)  NOT NULL COMMENT '如：用户性别、场地状态',
    字典键      VARCHAR(64)  NOT NULL COMMENT '内部编码',
    字典值      VARCHAR(255) NOT NULL COMMENT '显示标签',
    排序        TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '排序号',
    是否启用    TINYINT(1) NOT NULL DEFAULT 1 COMMENT '1=启用 0=停用',
    UNIQUE KEY uk_dict_type_key (字典类型, 字典键),
    INDEX idx_dict_type (字典类型)
) ENGINE=InnoDB COMMENT='系统字典表';

-- 0-2 角色表
CREATE TABLE IF NOT EXISTS 角色表 (
    角色ID      TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT '角色主键',
    角色名称    VARCHAR(50) NOT NULL UNIQUE COMMENT '管理员/教师/学生',
    权限列表    TEXT        COMMENT 'JSON 权限描述',
    描述        VARCHAR(200) COMMENT '角色说明'
) ENGINE=InnoDB COMMENT='用户角色表';

-- 0-3 用户表
CREATE TABLE IF NOT EXISTS 用户表 (
    用户ID        BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT '用户主键',
    用户名        VARCHAR(50)  NOT NULL UNIQUE COMMENT '登录名',
    真实姓名      VARCHAR(50)  NOT NULL COMMENT '显示名称',
    学号工号      VARCHAR(30)  UNIQUE COMMENT '学号或工号',
    角色ID        TINYINT UNSIGNED NOT NULL DEFAULT 3 COMMENT 'FK→角色表',
    密码哈希      VARCHAR(255) NOT NULL DEFAULT '' COMMENT 'bcrypt 哈希',
    手机号        VARCHAR(20) COMMENT '联系电话',
    邮箱          VARCHAR(100) COMMENT '电子邮箱',
    是否启用      TINYINT(1) NOT NULL DEFAULT 1 COMMENT '1=启用 0=停用',
    创建时间      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_user_role (角色ID),
    INDEX idx_user_name (真实姓名),
    CONSTRAINT fk_user_role FOREIGN KEY (角色ID) REFERENCES 角色表(角色ID)
) ENGINE=InnoDB COMMENT='系统用户表';

-- 0-4 操作日志表
CREATE TABLE IF NOT EXISTS 操作日志表 (
    日志ID      BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT '日志主键',
    用户ID      BIGINT UNSIGNED COMMENT '操作用户 FK→用户表',
    模块        VARCHAR(50)  NOT NULL COMMENT '如：场地/项目',
    操作类型    VARCHAR(20)  NOT NULL COMMENT '增/删/改/查',
    目标类型    VARCHAR(50)  COMMENT '目标表名',
    目标ID      BIGINT UNSIGNED COMMENT '目标记录ID',
    描述        TEXT COMMENT '操作详情',
    操作时间    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
    INDEX idx_log_user (用户ID),
    INDEX idx_log_time (操作时间),
    INDEX idx_log_module (模块),
    CONSTRAINT fk_log_user FOREIGN KEY (用户ID) REFERENCES 用户表(用户ID) ON DELETE SET NULL
) ENGINE=InnoDB COMMENT='操作日志表';

-- 0-5 通知公告表
CREATE TABLE IF NOT EXISTS 通知公告表 (
    公告ID      BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT '公告主键',
    标题        VARCHAR(200) NOT NULL COMMENT '公告标题',
    内容        TEXT         NOT NULL COMMENT '公告正文',
    发布人ID    BIGINT UNSIGNED NOT NULL COMMENT 'FK→用户表',
    是否置顶    TINYINT(1) NOT NULL DEFAULT 0 COMMENT '1=置顶 0=普通',
    发布时间    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '发布时间',
    INDEX idx_notice_pub (发布人ID),
    CONSTRAINT fk_notice_pub FOREIGN KEY (发布人ID) REFERENCES 用户表(用户ID)
) ENGINE=InnoDB COMMENT='通知公告表';

-- ============================================================
--  模块1：实训场地 (4 张表)
-- ============================================================

-- 1-1 场地类型表
CREATE TABLE IF NOT EXISTS 场地类型表 (
    类型ID      INT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT '类型主键',
    类型名称    VARCHAR(50) NOT NULL UNIQUE COMMENT '温室/农田/实验室',
    描述        VARCHAR(200) COMMENT '类型说明'
) ENGINE=InnoDB COMMENT='场地类型表';

-- 1-2 实训场地表
CREATE TABLE IF NOT EXISTS 实训场地表 (
    场地ID      BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT '场地主键',
    场地编号    VARCHAR(20)  NOT NULL UNIQUE COMMENT '如 VN-001',
    场地名称    VARCHAR(100) NOT NULL COMMENT '场地名称',
    类型ID      INT UNSIGNED NOT NULL COMMENT 'FK→场地类型表',
    面积平米    DECIMAL(10,2) COMMENT '面积(平方米)',
    主要用途    VARCHAR(200) COMMENT '主要用途说明',
    使用状态    VARCHAR(20)  NOT NULL DEFAULT '空闲' COMMENT '空闲/使用中/维护中',
    责任人      VARCHAR(50)  COMMENT '责任人姓名',
    备注        TEXT COMMENT '其他说明',
    INDEX idx_venue_type (类型ID),
    INDEX idx_venue_status (使用状态),
    CONSTRAINT fk_venue_type FOREIGN KEY (类型ID) REFERENCES 场地类型表(类型ID)
) ENGINE=InnoDB COMMENT='实训场地表';

-- 1-3 场地预约表
CREATE TABLE IF NOT EXISTS 场地预约表 (
    预约ID      BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT '预约主键',
    场地ID      BIGINT UNSIGNED NOT NULL COMMENT 'FK→实训场地表',
    项目ID      BIGINT UNSIGNED COMMENT 'FK→实训项目表',
    申请人ID    BIGINT UNSIGNED NOT NULL COMMENT 'FK→用户表',
    开始时间    DATETIME NOT NULL COMMENT '预约开始时间',
    结束时间    DATETIME NOT NULL COMMENT '预约结束时间',
    预约原因    VARCHAR(500) COMMENT '申请原因',
    审批状态    VARCHAR(20)  NOT NULL DEFAULT '待审批' COMMENT '待审批/已批准/已拒绝',
    审批人ID    BIGINT UNSIGNED COMMENT 'FK→用户表',
    申请时间    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '申请时间',
    INDEX idx_booking_venue (场地ID),
    INDEX idx_booking_status (审批状态),
    CONSTRAINT fk_booking_venue FOREIGN KEY (场地ID) REFERENCES 实训场地表(场地ID),
    CONSTRAINT fk_booking_applicant FOREIGN KEY (申请人ID) REFERENCES 用户表(用户ID),
    CONSTRAINT fk_booking_approver FOREIGN KEY (审批人ID) REFERENCES 用户表(用户ID)
) ENGINE=InnoDB COMMENT='场地预约表';

-- 1-4 场地维护表
CREATE TABLE IF NOT EXISTS 场地维护表 (
    维护ID      BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT '维护主键',
    场地ID      BIGINT UNSIGNED NOT NULL COMMENT 'FK→实训场地表',
    维护日期    DATE NOT NULL COMMENT '维护日期',
    维护类型    VARCHAR(50)  COMMENT '日常/紧急/定期',
    描述        TEXT COMMENT '维护内容',
    费用        DECIMAL(10,2) COMMENT '维护费用',
    记录人ID    BIGINT UNSIGNED COMMENT 'FK→用户表',
    INDEX idx_mainten_venue (场地ID),
    CONSTRAINT fk_mainten_venue FOREIGN KEY (场地ID) REFERENCES 实训场地表(场地ID),
    CONSTRAINT fk_mainten_recorder FOREIGN KEY (记录人ID) REFERENCES 用户表(用户ID)
) ENGINE=InnoDB COMMENT='场地维护表';

-- ============================================================
--  模块2：实训作物 (4 张表)
-- ============================================================

-- 2-1 作物品种表
CREATE TABLE IF NOT EXISTS 作物品种表 (
    品种ID      INT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT '品种主键',
    品种名称    VARCHAR(100) NOT NULL COMMENT '品种名称',
    科属        VARCHAR(100) COMMENT '如：禾本科小麦属',
    培育周期    INT UNSIGNED COMMENT '培育周期(天)',
    温湿范围    VARCHAR(50)  COMMENT '适宜温湿度范围',
    描述        TEXT COMMENT '品种描述'
) ENGINE=InnoDB COMMENT='作物品种表';

-- 2-2 培育批次表
CREATE TABLE IF NOT EXISTS 培育批次表 (
    批次ID      BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT '批次主键',
    批次名称    VARCHAR(100) NOT NULL COMMENT '批次名称',
    品种ID      INT UNSIGNED NOT NULL COMMENT 'FK→作物品种表',
    场地ID      BIGINT UNSIGNED COMMENT 'FK→实训场地表',
    种植日期    DATE COMMENT '种植日期',
    数量        INT UNSIGNED DEFAULT 0 COMMENT '种植数量',
    生长状态    VARCHAR(20) NOT NULL DEFAULT '播种期' COMMENT '播种期/生长期/收获期/异常',
    存活率      DECIMAL(5,2) COMMENT '存活率(%)',
    记录人ID    BIGINT UNSIGNED COMMENT 'FK→用户表',
    创建时间    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_batch_variety (品种ID),
    INDEX idx_batch_venue (场地ID),
    INDEX idx_batch_status (生长状态),
    CONSTRAINT fk_batch_variety FOREIGN KEY (品种ID) REFERENCES 作物品种表(品种ID),
    CONSTRAINT fk_batch_venue   FOREIGN KEY (场地ID) REFERENCES 实训场地表(场地ID),
    CONSTRAINT fk_batch_recorder FOREIGN KEY (记录人ID) REFERENCES 用户表(用户ID)
) ENGINE=InnoDB COMMENT='培育批次表';

-- 2-3 生长观测表
CREATE TABLE IF NOT EXISTS 生长观测表 (
    观测ID      BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT '观测主键',
    批次ID      BIGINT UNSIGNED NOT NULL COMMENT 'FK→培育批次表',
    观测日期    DATE NOT NULL COMMENT '观测日期',
    株高CM      DECIMAL(8,2) COMMENT '株高(厘米)',
    叶片数      INT UNSIGNED COMMENT '叶片数量',
    健康状态    VARCHAR(50) COMMENT '健康/轻微异常/严重异常',
    备注        TEXT COMMENT '观测备注',
    观测人ID    BIGINT UNSIGNED COMMENT 'FK→用户表',
    INDEX idx_obs_batch (批次ID),
    CONSTRAINT fk_obs_batch    FOREIGN KEY (批次ID) REFERENCES 培育批次表(批次ID),
    CONSTRAINT fk_obs_observer FOREIGN KEY (观测人ID) REFERENCES 用户表(用户ID)
) ENGINE=InnoDB COMMENT='生长观测表';

-- 2-4 病虫害防治表
CREATE TABLE IF NOT EXISTS 病虫害防治表 (
    防治ID      BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT '防治主键',
    批次ID      BIGINT UNSIGNED NOT NULL COMMENT 'FK→培育批次表',
    发现日期    DATE NOT NULL COMMENT '发现日期',
    病虫害类型  VARCHAR(100) COMMENT '病虫害名称',
    严重程度    VARCHAR(20)  COMMENT '轻微/中等/严重',
    防治措施    TEXT COMMENT '防治措施描述',
    防治结果    VARCHAR(100) COMMENT '防治效果',
    记录人ID    BIGINT UNSIGNED COMMENT 'FK→用户表',
    INDEX idx_pest_batch (批次ID),
    CONSTRAINT fk_pest_batch    FOREIGN KEY (批次ID) REFERENCES 培育批次表(批次ID),
    CONSTRAINT fk_pest_recorder FOREIGN KEY (记录人ID) REFERENCES 用户表(用户ID)
) ENGINE=InnoDB COMMENT='病虫害防治表';

-- ============================================================
--  模块3：实训项目 (7 张表)
-- ============================================================

-- 3-1 学期表
CREATE TABLE IF NOT EXISTS 学期表 (
    学期ID      INT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT '学期主键',
    学期名称    VARCHAR(50)  NOT NULL UNIQUE COMMENT '如：2025-2026-2',
    开始日期    DATE NOT NULL COMMENT '学期开始日期',
    结束日期    DATE NOT NULL COMMENT '学期结束日期',
    是否当前    TINYINT(1) NOT NULL DEFAULT 0 COMMENT '1=当前学期 0=非当前'
) ENGINE=InnoDB COMMENT='学期表';

-- 3-2 实训项目表
CREATE TABLE IF NOT EXISTS 实训项目表 (
    项目ID      BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT '项目主键',
    项目名称    VARCHAR(200) NOT NULL COMMENT '项目名称',
    项目描述    TEXT COMMENT '项目描述',
    场地ID      BIGINT UNSIGNED COMMENT 'FK→实训场地表',
    学期ID      INT UNSIGNED COMMENT 'FK→学期表',
    负责教师ID  BIGINT UNSIGNED COMMENT 'FK→用户表(教师)',
    开始日期    DATE COMMENT '开始日期',
    结束日期    DATE COMMENT '结束日期',
    人数上限    INT UNSIGNED DEFAULT 30 COMMENT '最大报名人数',
    项目状态    VARCHAR(20)  NOT NULL DEFAULT '招募中' COMMENT '招募中/进行中/已结束',
    创建时间    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_project_venue (场地ID),
    INDEX idx_project_semester (学期ID),
    INDEX idx_project_teacher (负责教师ID),
    CONSTRAINT fk_project_venue    FOREIGN KEY (场地ID)     REFERENCES 实训场地表(场地ID),
    CONSTRAINT fk_project_semester FOREIGN KEY (学期ID)     REFERENCES 学期表(学期ID),
    CONSTRAINT fk_project_teacher  FOREIGN KEY (负责教师ID) REFERENCES 用户表(用户ID)
) ENGINE=InnoDB COMMENT='实训项目表';

-- 3-3 学生报名表
CREATE TABLE IF NOT EXISTS 学生报名表 (
    报名ID      BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT '报名主键',
    项目ID      BIGINT UNSIGNED NOT NULL COMMENT 'FK→实训项目表',
    学生ID      BIGINT UNSIGNED NOT NULL COMMENT 'FK→用户表(学生)',
    报名状态    VARCHAR(20)  NOT NULL DEFAULT '待审核' COMMENT '待审核/已通过/已拒绝',
    报名时间    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '报名时间',
    综合成绩    DECIMAL(5,2) COMMENT '期末综合成绩',
    UNIQUE KEY uk_enroll (项目ID, 学生ID),
    INDEX idx_enroll_project (项目ID),
    INDEX idx_enroll_student (学生ID),
    CONSTRAINT fk_enroll_project FOREIGN KEY (项目ID) REFERENCES 实训项目表(项目ID),
    CONSTRAINT fk_enroll_student FOREIGN KEY (学生ID) REFERENCES 用户表(用户ID)
) ENGINE=InnoDB COMMENT='学生报名表';

-- 3-4 实训任务表
CREATE TABLE IF NOT EXISTS 实训任务表 (
    任务ID      BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT '任务主键',
    项目ID      BIGINT UNSIGNED NOT NULL COMMENT 'FK→实训项目表',
    任务名称    VARCHAR(200) NOT NULL COMMENT '任务名称',
    任务描述    TEXT COMMENT '任务内容说明',
    截止时间    DATETIME COMMENT '截止时间',
    权重        DECIMAL(5,2) DEFAULT 0 COMMENT '占总成绩权重(%)',
    创建时间    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_task_project (项目ID),
    CONSTRAINT fk_task_project FOREIGN KEY (项目ID) REFERENCES 实训项目表(项目ID)
) ENGINE=InnoDB COMMENT='实训任务表';

-- 3-5 实训报告表 (一个报名对应一份报告)
CREATE TABLE IF NOT EXISTS 实训报告表 (
    报告ID      BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT '报告主键',
    报名ID      BIGINT UNSIGNED NOT NULL UNIQUE COMMENT 'FK→学生报名表(唯一)',
    任务ID      BIGINT UNSIGNED COMMENT 'FK→实训任务表',
    报告内容    TEXT COMMENT '报告正文',
    文件路径    VARCHAR(500) COMMENT '附件路径',
    提交时间    DATETIME COMMENT '提交时间',
    报告成绩    DECIMAL(5,2) COMMENT '报告得分',
    教师评语    TEXT COMMENT '教师评语',
    评分时间    DATETIME COMMENT '评分时间',
    INDEX idx_report_enroll (报名ID),
    INDEX idx_report_task (任务ID),
    CONSTRAINT fk_report_enroll FOREIGN KEY (报名ID) REFERENCES 学生报名表(报名ID),
    CONSTRAINT fk_report_task   FOREIGN KEY (任务ID) REFERENCES 实训任务表(任务ID)
) ENGINE=InnoDB COMMENT='实训报告表';

-- 3-6 学生互评表
CREATE TABLE IF NOT EXISTS 学生互评表 (
    互评ID      BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT '互评主键',
    项目ID      BIGINT UNSIGNED NOT NULL COMMENT 'FK→实训项目表',
    评分人ID    BIGINT UNSIGNED NOT NULL COMMENT 'FK→用户表',
    被评人ID    BIGINT UNSIGNED NOT NULL COMMENT 'FK→用户表',
    互评分数    DECIMAL(5,2) COMMENT '互评得分',
    评语        TEXT COMMENT '互评评语',
    创建时间    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_review_project (项目ID),
    CONSTRAINT fk_review_project   FOREIGN KEY (项目ID)   REFERENCES 实训项目表(项目ID),
    CONSTRAINT fk_review_reviewer  FOREIGN KEY (评分人ID) REFERENCES 用户表(用户ID),
    CONSTRAINT fk_review_target    FOREIGN KEY (被评人ID) REFERENCES 用户表(用户ID)
) ENGINE=InnoDB COMMENT='学生互评表';

-- ============================================================
--  模块4：器材耗材 (7 张表)
-- ============================================================

-- 4-1 器材分类表
CREATE TABLE IF NOT EXISTS 器材分类表 (
    分类ID      INT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT '分类主键',
    分类名称    VARCHAR(50) NOT NULL COMMENT '农具/仪器/耗材',
    描述        VARCHAR(200) COMMENT '分类说明'
) ENGINE=InnoDB COMMENT='器材分类表';

-- 4-2 器材档案表
CREATE TABLE IF NOT EXISTS 器材档案表 (
    器材ID      BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT '器材主键',
    器材编号    VARCHAR(30)  NOT NULL UNIQUE COMMENT '如：EQ-T001',
    器材名称    VARCHAR(100) NOT NULL COMMENT '器材名称',
    分类ID      INT UNSIGNED COMMENT 'FK→器材分类表',
    规格型号    VARCHAR(100) COMMENT '规格/型号',
    单位        VARCHAR(20)  NOT NULL DEFAULT '个' COMMENT '计量单位',
    当前库存    INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '当前库存数量',
    最低库存    INT UNSIGNED NOT NULL DEFAULT 5 COMMENT '安全库存阈值',
    单价        DECIMAL(10,2) COMMENT '单价(元)',
    存放位置    VARCHAR(100) COMMENT '存放位置',
    INDEX idx_equip_category (分类ID),
    CONSTRAINT fk_equip_category FOREIGN KEY (分类ID) REFERENCES 器材分类表(分类ID)
) ENGINE=InnoDB COMMENT='器材档案表';

-- 4-3 入库记录表
CREATE TABLE IF NOT EXISTS 入库记录表 (
    入库ID      BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT '入库主键',
    器材ID      BIGINT UNSIGNED NOT NULL COMMENT 'FK→器材档案表',
    入库数量    INT UNSIGNED NOT NULL COMMENT '入库数量',
    入库单价    DECIMAL(10,2) COMMENT '入库单价',
    供应商      VARCHAR(100) COMMENT '供应商名称',
    入库日期    DATE NOT NULL COMMENT '入库日期',
    经办人ID    BIGINT UNSIGNED COMMENT 'FK→用户表',
    备注        VARCHAR(500) COMMENT '备注说明',
    INDEX idx_stockin_equip (器材ID),
    CONSTRAINT fk_stockin_equip    FOREIGN KEY (器材ID)   REFERENCES 器材档案表(器材ID),
    CONSTRAINT fk_stockin_operator FOREIGN KEY (经办人ID) REFERENCES 用户表(用户ID)
) ENGINE=InnoDB COMMENT='入库记录表';

-- 4-4 借用记录表
CREATE TABLE IF NOT EXISTS 借用记录表 (
    借用ID      BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT '借用主键',
    器材ID      BIGINT UNSIGNED NOT NULL COMMENT 'FK→器材档案表',
    用户ID      BIGINT UNSIGNED NOT NULL COMMENT 'FK→用户表',
    借用数量    INT UNSIGNED NOT NULL COMMENT '借用数量',
    借用日期    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '借用日期',
    应还日期    DATETIME COMMENT '应归还日期',
    实还日期    DATETIME COMMENT '实际归还日期',
    借用状态    VARCHAR(20)  NOT NULL DEFAULT '借用中' COMMENT '借用中/已归还/逾期',
    项目ID      BIGINT UNSIGNED COMMENT 'FK→实训项目表',
    审批人ID    BIGINT UNSIGNED COMMENT 'FK→用户表',
    -- (借用天数由视图或应用层实时计算，不在表中冗余存储)    INDEX idx_borrow_equip (器材ID),
    INDEX idx_borrow_user  (用户ID),
    INDEX idx_borrow_status (借用状态),
    CONSTRAINT fk_borrow_equip    FOREIGN KEY (器材ID)   REFERENCES 器材档案表(器材ID),
    CONSTRAINT fk_borrow_user     FOREIGN KEY (用户ID)   REFERENCES 用户表(用户ID),
    CONSTRAINT fk_borrow_project  FOREIGN KEY (项目ID)   REFERENCES 实训项目表(项目ID),
    CONSTRAINT fk_borrow_approver FOREIGN KEY (审批人ID) REFERENCES 用户表(用户ID)
) ENGINE=InnoDB COMMENT='借用记录表';

-- 4-5 消耗记录表 (大纲新增)
CREATE TABLE IF NOT EXISTS 消耗记录表 (
    消耗ID      BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT '消耗主键',
    器材ID      BIGINT UNSIGNED NOT NULL COMMENT 'FK→器材档案表',
    项目ID      BIGINT UNSIGNED COMMENT 'FK→实训项目表',
    消耗数量    INT UNSIGNED NOT NULL COMMENT '消耗数量',
    消耗日期    DATE NOT NULL COMMENT '消耗日期',
    记录人ID    BIGINT UNSIGNED COMMENT 'FK→用户表',
    备注        VARCHAR(500) COMMENT '备注说明',
    INDEX idx_consum_equip (器材ID),
    INDEX idx_consum_project (项目ID),
    CONSTRAINT fk_consum_equip    FOREIGN KEY (器材ID)   REFERENCES 器材档案表(器材ID),
    CONSTRAINT fk_consum_project  FOREIGN KEY (项目ID)   REFERENCES 实训项目表(项目ID),
    CONSTRAINT fk_consum_recorder FOREIGN KEY (记录人ID) REFERENCES 用户表(用户ID)
) ENGINE=InnoDB COMMENT='消耗记录表';

-- 4-6 盘点单表
CREATE TABLE IF NOT EXISTS 盘点单表 (
    盘点ID      BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT '盘点主键',
    盘点日期    DATE NOT NULL COMMENT '盘点日期',
    盘点人ID    BIGINT UNSIGNED COMMENT 'FK→用户表',
    盘点状态    VARCHAR(20)  NOT NULL DEFAULT '进行中' COMMENT '进行中/已完成',
    备注        TEXT COMMENT '盘点备注',
    创建时间    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_check_date (盘点日期),
    CONSTRAINT fk_check_checker FOREIGN KEY (盘点人ID) REFERENCES 用户表(用户ID)
) ENGINE=InnoDB COMMENT='盘点单表';

-- 4-7 盘点明细表
CREATE TABLE IF NOT EXISTS 盘点明细表 (
    明细ID      BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT '明细主键',
    盘点ID      BIGINT UNSIGNED NOT NULL COMMENT 'FK→盘点单表',
    器材ID      BIGINT UNSIGNED NOT NULL COMMENT 'FK→器材档案表',
    账面数量    INT UNSIGNED COMMENT '系统账面数量',
    实盘数量    INT UNSIGNED COMMENT '实物盘点数量',
    差异数量    INT COMMENT '差异(=实盘-账面)',
    差异原因    VARCHAR(500) COMMENT '差异原因说明',
    INDEX idx_detail_check (盘点ID),
    CONSTRAINT fk_detail_check FOREIGN KEY (盘点ID) REFERENCES 盘点单表(盘点ID),
    CONSTRAINT fk_detail_equip FOREIGN KEY (器材ID) REFERENCES 器材档案表(器材ID)
) ENGINE=InnoDB COMMENT='盘点明细表';

-- ============================================================
--  模块5：人员考勤 (4 张表)
-- ============================================================

-- 5-1 考勤场次表
CREATE TABLE IF NOT EXISTS 考勤场次表 (
    场次ID      BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT '场次主键',
    项目ID      BIGINT UNSIGNED NOT NULL COMMENT 'FK→实训项目表',
    场次日期    DATE NOT NULL COMMENT '考勤日期',
    开始时间    TIME NOT NULL COMMENT '预定开始时间',
    结束时间    TIME COMMENT '预定结束时间',
    地点        VARCHAR(100) COMMENT '考勤地点',
    实到人数    INT UNSIGNED DEFAULT 0 COMMENT '实际签到人数',
    带队教师ID  BIGINT UNSIGNED COMMENT 'FK→用户表',
    创建时间    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_session_project (项目ID),
    INDEX idx_session_date (场次日期),
    CONSTRAINT fk_session_project FOREIGN KEY (项目ID)   REFERENCES 实训项目表(项目ID),
    CONSTRAINT fk_session_teacher FOREIGN KEY (带队教师ID) REFERENCES 用户表(用户ID)
) ENGINE=InnoDB COMMENT='考勤场次表';

-- 5-2 签到记录表
CREATE TABLE IF NOT EXISTS 签到记录表 (
    签到ID      BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT '签到主键',
    场次ID      BIGINT UNSIGNED NOT NULL COMMENT 'FK→考勤场次表',
    学生ID      BIGINT UNSIGNED NOT NULL COMMENT 'FK→用户表',
    签到时间    DATETIME COMMENT '实际签到时间',
    签到状态    VARCHAR(20) NOT NULL DEFAULT '缺勤' COMMENT '出勤/迟到/请假/缺勤',
    UNIQUE KEY uk_attendance (场次ID, 学生ID),
    INDEX idx_att_session (场次ID),
    INDEX idx_att_student (学生ID),
    CONSTRAINT fk_att_session FOREIGN KEY (场次ID) REFERENCES 考勤场次表(场次ID),
    CONSTRAINT fk_att_student FOREIGN KEY (学生ID) REFERENCES 用户表(用户ID)
) ENGINE=InnoDB COMMENT='签到记录表';

-- 5-3 教师带队表
CREATE TABLE IF NOT EXISTS 教师带队表 (
    带队ID      BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT '带队主键',
    场次ID      BIGINT UNSIGNED NOT NULL COMMENT 'FK→考勤场次表',
    教师ID      BIGINT UNSIGNED NOT NULL COMMENT 'FK→用户表',
    送达时间    DATETIME COMMENT '带队开始时间',
    离开时间    DATETIME COMMENT '带队结束时间',
    备注        TEXT COMMENT '带队备注',
    创建时间    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_lead_session (场次ID),
    CONSTRAINT fk_lead_session FOREIGN KEY (场次ID) REFERENCES 考勤场次表(场次ID),
    CONSTRAINT fk_lead_teacher FOREIGN KEY (教师ID) REFERENCES 用户表(用户ID)
) ENGINE=InnoDB COMMENT='教师带队表';

-- 5-4 请假申请表
CREATE TABLE IF NOT EXISTS 请假申请表 (
    请假ID      BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT '请假主键',
    学生ID      BIGINT UNSIGNED NOT NULL COMMENT 'FK→用户表',
    项目ID      BIGINT UNSIGNED NOT NULL COMMENT 'FK→实训项目表',
    场次ID      BIGINT UNSIGNED COMMENT 'FK→考勤场次表(NULL=全天)',
    请假类型    VARCHAR(20)  NOT NULL DEFAULT '事假' COMMENT '事假/病假/公务',
    请假原因    TEXT NOT NULL COMMENT '请假事由',
    开始时间    DATETIME NOT NULL COMMENT '请假开始',
    结束时间    DATETIME NOT NULL COMMENT '请假结束',
    审批状态    VARCHAR(20)  NOT NULL DEFAULT '待审批' COMMENT '待审批/已批准/已拒绝',
    审批人ID    BIGINT UNSIGNED COMMENT 'FK→用户表',
    申请时间    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '申请时间',
    审批时间    DATETIME COMMENT '审批时间',
    INDEX idx_leave_student (学生ID),
    INDEX idx_leave_project (项目ID),
    CONSTRAINT fk_leave_student  FOREIGN KEY (学生ID)   REFERENCES 用户表(用户ID),
    CONSTRAINT fk_leave_project  FOREIGN KEY (项目ID)   REFERENCES 实训项目表(项目ID),
    CONSTRAINT fk_leave_session  FOREIGN KEY (场次ID)   REFERENCES 考勤场次表(场次ID),
    CONSTRAINT fk_leave_approver FOREIGN KEY (审批人ID) REFERENCES 用户表(用户ID)
) ENGINE=InnoDB COMMENT='请假申请表';

-- ============================================================
--  视图 (大纲4.3)
-- ============================================================

-- V1：场地使用情况视图
CREATE OR REPLACE VIEW 视图_场地使用情况 AS
SELECT 
    v.场地编号, v.场地名称, vt.类型名称 AS 场地类型,
    v.使用状态, v.责任人, v.面积平米,
    COUNT(DISTINCT vb.预约ID) AS 预约次数,
    COUNT(DISTINCT cb.批次ID) AS 培育批次数
FROM 实训场地表 v
JOIN 场地类型表 vt ON v.类型ID = vt.类型ID
LEFT JOIN 场地预约表 vb ON v.场地ID = vb.场地ID
LEFT JOIN 培育批次表 cb ON v.场地ID = cb.场地ID
GROUP BY v.场地ID;

-- V2：库存预警视图
CREATE OR REPLACE VIEW 视图_库存预警 AS
SELECT 
    e.器材编号, e.器材名称, c.分类名称 AS 器材分类,
    e.当前库存, e.最低库存, e.单位,
    CASE WHEN e.当前库存 = 0 THEN '缺货'
         WHEN e.当前库存 <= e.最低库存 THEN '预警'
         ELSE '正常' END AS 库存状态
FROM 器材档案表 e
JOIN 器材分类表 c ON e.分类ID = c.分类ID
WHERE e.当前库存 <= e.最低库存;

-- V3：考勤统计视图
CREATE OR REPLACE VIEW 视图_考勤统计 AS
SELECT 
    p.项目名称,
    (SELECT COUNT(*) FROM 学生报名表 en WHERE en.项目ID = p.项目ID AND en.报名状态 = '已通过') AS 应到人数,
    COUNT(DISTINCT a.学生ID) AS 实到人数,
    CONCAT(ROUND(COUNT(DISTINCT a.学生ID) / NULLIF(
        (SELECT COUNT(*) FROM 学生报名表 en WHERE en.项目ID = p.项目ID AND en.报名状态 = '已通过'), 0
    ) * 100, 1), '%') AS 出勤率
FROM 实训项目表 p
LEFT JOIN 考勤场次表 s ON p.项目ID = s.项目ID
LEFT JOIN 签到记录表 a ON s.场次ID = a.场次ID AND a.签到状态 IN ('出勤','迟到')
GROUP BY p.项目ID;

-- V4：逾期未还器材视图
CREATE OR REPLACE VIEW 视图_逾期未还 AS
SELECT 
    b.借用ID, e.器材名称, u.真实姓名 AS 借用人,
    b.借用数量, b.借用日期, b.应还日期,
    DATEDIFF(NOW(), b.应还日期) AS 逾期天数
FROM 借用记录表 b
JOIN 器材档案表 e ON b.器材ID = e.器材ID
JOIN 用户表 u ON b.用户ID = u.用户ID
WHERE b.借用状态 = '借用中' AND b.应还日期 < NOW();

-- V5：学生成绩汇总视图
CREATE OR REPLACE VIEW 视图_学生成绩 AS
SELECT 
    u.学号工号, u.真实姓名, p.项目名称,
    en.综合成绩,
    CASE WHEN en.综合成绩 >= 90 THEN '优秀'
         WHEN en.综合成绩 >= 75 THEN '良好'
         WHEN en.综合成绩 >= 60 THEN '及格'
         ELSE '不及格' END AS 成绩等级
FROM 学生报名表 en
JOIN 用户表 u ON en.学生ID = u.用户ID
JOIN 实训项目表 p ON en.项目ID = p.项目ID
WHERE en.报名状态 = '已通过' AND en.综合成绩 IS NOT NULL;

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
--  触发器 (大纲6.3)
-- ============================================================

DELIMITER $$

-- T1：入库时自动增加库存
DROP TRIGGER IF EXISTS 触发器_入库更新库存 $$
CREATE TRIGGER 触发器_入库更新库存
AFTER INSERT ON 入库记录表
FOR EACH ROW
BEGIN
    UPDATE 器材档案表 SET 当前库存 = 当前库存 + NEW.入库数量
    WHERE 器材ID = NEW.器材ID;
END $$

-- T2：借用状态变更时扣/补库存 (UPDATE)
DROP TRIGGER IF EXISTS 触发器_借还更新库存 $$
CREATE TRIGGER 触发器_借还更新库存
AFTER UPDATE ON 借用记录表
FOR EACH ROW
BEGIN
    IF NEW.借用状态 = '已归还' AND OLD.借用状态 != '已归还' THEN
        UPDATE 器材档案表 SET 当前库存 = 当前库存 + NEW.借用数量
        WHERE 器材ID = NEW.器材ID;
    ELSEIF NEW.借用状态 = '借用中' AND OLD.借用状态 = '待审批' THEN
        UPDATE 器材档案表 SET 当前库存 = 当前库存 - NEW.借用数量
        WHERE 器材ID = NEW.器材ID;
    END IF;
END $$

-- T2b：直接插入已批准借用时扣库存 (INSERT)
DROP TRIGGER IF EXISTS 触发器_借出插入扣库存 $$
CREATE TRIGGER 触发器_借出插入扣库存
BEFORE INSERT ON 借用记录表
FOR EACH ROW
BEGIN
    IF NEW.借用状态 = '借用中' THEN
        UPDATE 器材档案表 SET 当前库存 = 当前库存 - NEW.借用数量
        WHERE 器材ID = NEW.器材ID;
    END IF;
END $$

-- T3：签到时自动判定迟到
DROP TRIGGER IF EXISTS 触发器_签到判定迟到 $$
CREATE TRIGGER 触发器_签到判定迟到
BEFORE INSERT ON 签到记录表
FOR EACH ROW
BEGIN
    DECLARE session_start TIME;
    SELECT 开始时间 INTO session_start FROM 考勤场次表 WHERE 场次ID = NEW.场次ID;
    IF NEW.签到时间 IS NOT NULL AND session_start IS NOT NULL THEN
        IF TIMEDIFF(TIME(NEW.签到时间), session_start) > '00:15:00' THEN
            SET NEW.签到状态 = '迟到';
        ELSE
            SET NEW.签到状态 = '出勤';
        END IF;
    END IF;
END $$

-- T4：更新场次实到人数
DROP TRIGGER IF EXISTS 触发器_更新实到人数 $$
CREATE TRIGGER 触发器_更新实到人数
AFTER INSERT ON 签到记录表
FOR EACH ROW
BEGIN
    UPDATE 考勤场次表 SET 实到人数 = (
        SELECT COUNT(*) FROM 签到记录表
        WHERE 场次ID = NEW.场次ID AND 签到状态 IN ('出勤','迟到')
    ) WHERE 场次ID = NEW.场次ID;
END $$

-- T5：报名人数限制
DROP TRIGGER IF EXISTS 触发器_报名人数限制 $$
CREATE TRIGGER 触发器_报名人数限制
BEFORE INSERT ON 学生报名表
FOR EACH ROW
BEGIN
    DECLARE current_count INT;
    DECLARE max_limit INT;
    SELECT COUNT(*) INTO current_count FROM 学生报名表
    WHERE 项目ID = NEW.项目ID AND 报名状态 IN ('待审核','已通过');
    SELECT 人数上限 INTO max_limit FROM 实训项目表 WHERE 项目ID = NEW.项目ID;
    IF current_count >= max_limit THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '报名人数已满，无法再报名';
    END IF;
END $$

-- T6：报告版本递增
DROP TRIGGER IF EXISTS 触发器_报告版本递增 $$
CREATE TRIGGER 触发器_报告版本递增
BEFORE INSERT ON 实训报告表
FOR EACH ROW
BEGIN
    DECLARE existing INT;
    SELECT COUNT(*) INTO existing FROM 实训报告表 WHERE 报名ID = NEW.报名ID;
    IF existing > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '该报名已有实训报告，请通过更新修改';
    END IF;
END $$

-- T7：消耗记录自动扣库存
DROP TRIGGER IF EXISTS 触发器_消耗扣减库存 $$
CREATE TRIGGER 触发器_消耗扣减库存
AFTER INSERT ON 消耗记录表
FOR EACH ROW
BEGIN
    UPDATE 器材档案表 SET 当前库存 = 当前库存 - NEW.消耗数量
    WHERE 器材ID = NEW.器材ID;
END $$

DELIMITER ;

-- ============================================================
--  存储过程 (大纲6.3)
-- ============================================================

DELIMITER $$

-- SP1：考勤报表——输入项目ID输出缺勤名单
DROP PROCEDURE IF EXISTS 过程_考勤报表 $$
CREATE PROCEDURE 过程_考勤报表(IN p_project_id BIGINT)
BEGIN
    SELECT u.学号工号, u.真实姓名,
           COUNT(CASE WHEN a.签到状态 IN ('出勤','迟到') THEN 1 END) AS 出勤次数,
           COUNT(a.签到ID) AS 总场次,
           CONCAT(ROUND(
               COUNT(CASE WHEN a.签到状态 IN ('出勤','迟到') THEN 1 END) / 
               NULLIF(COUNT(a.签到ID), 0) * 100, 1
           ), '%') AS 出勤率,
           GROUP_CONCAT(CASE WHEN a.签到状态 = '缺勤' THEN DATE_FORMAT(s.场次日期, '%m/%d') END) AS 缺勤日期
    FROM 学生报名表 en
    JOIN 用户表 u ON en.学生ID = u.用户ID
    LEFT JOIN 签到记录表 a ON en.学生ID = a.学生ID
    LEFT JOIN 考勤场次表 s ON a.场次ID = s.场次ID AND s.项目ID = p_project_id
    WHERE en.项目ID = p_project_id AND en.报名状态 = '已通过'
    GROUP BY en.学生ID
    ORDER BY 出勤率 ASC;
END $$

-- SP2：批量计算成绩 (考勤40% + 报告60%)
DROP PROCEDURE IF EXISTS 过程_批量计算成绩 $$
CREATE PROCEDURE 过程_批量计算成绩(IN p_project_id BIGINT)
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE v_enroll_id BIGINT;
    DECLARE v_student_id BIGINT;
    DECLARE v_att_rate DECIMAL(5,2);
    DECLARE v_report_score DECIMAL(5,2);
    DECLARE v_total_score DECIMAL(5,2);
    DECLARE cur CURSOR FOR
        SELECT 报名ID, 学生ID FROM 学生报名表
        WHERE 项目ID = p_project_id AND 报名状态 = '已通过';
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    
    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_enroll_id, v_student_id;
        IF done THEN LEAVE read_loop; END IF;
        
        SELECT ROUND(
            COUNT(CASE WHEN a.签到状态 IN ('出勤','迟到') THEN 1 END) /
            NULLIF(COUNT(a.签到ID), 0) * 100, 2
        ) INTO v_att_rate
        FROM 签到记录表 a
        JOIN 考勤场次表 s ON a.场次ID = s.场次ID
        WHERE a.学生ID = v_student_id AND s.项目ID = p_project_id;
        
        SELECT COALESCE(AVG(报告成绩), 0) INTO v_report_score
        FROM 实训报告表 WHERE 报名ID = v_enroll_id;
        
        SET v_total_score = COALESCE(v_att_rate, 0) * 0.4 + COALESCE(v_report_score, 0) * 0.6;
        
        UPDATE 学生报名表 SET 综合成绩 = ROUND(v_total_score, 1)
        WHERE 报名ID = v_enroll_id;
    END LOOP;
    CLOSE cur;
END $$

-- SP3：器材归还 (事务)
DROP PROCEDURE IF EXISTS 过程_器材归还 $$
CREATE PROCEDURE 过程_器材归还(IN p_borrow_id BIGINT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION ROLLBACK;
    START TRANSACTION;
    UPDATE 借用记录表 SET 借用状态 = '已归还', 实还日期 = NOW()
    WHERE 借用ID = p_borrow_id AND 借用状态 = '借用中';
    COMMIT;
END $$

DELIMITER ;

-- ============================================================
--  函数 (大纲6.3)
-- ============================================================

DELIMITER $$
DROP FUNCTION IF EXISTS 函数_计算出勤率 $$
CREATE FUNCTION 函数_计算出勤率(p_project_id BIGINT)
RETURNS DECIMAL(5,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE rate DECIMAL(5,2);
    SELECT ROUND(
        COUNT(DISTINCT CASE WHEN a.签到状态 IN ('出勤','迟到') THEN a.学生ID END) /
        NULLIF(COUNT(DISTINCT en.学生ID), 0) * 100, 2
    ) INTO rate
    FROM 学生报名表 en
    LEFT JOIN 签到记录表 a ON en.学生ID = a.学生ID
    LEFT JOIN 考勤场次表 s ON a.场次ID = s.场次ID AND s.项目ID = p_project_id
    WHERE en.项目ID = p_project_id AND en.报名状态 = '已通过';
    RETURN COALESCE(rate, 0);
END $$
DELIMITER ;

-- ============================================================
--  测试数据
-- ============================================================
SET FOREIGN_KEY_CHECKS = 0;

-- 角色 (3)
INSERT INTO 角色表 VALUES 
(1, '管理员', '{"all": true}', '系统管理员，拥有全部权限'),
(2, '教师', '{"venue": "rwu", "crop": "rwu", "project": "rwu", "equip": "rw", "attendance": "rwu", "user": "r"}', '教师用户'),
(3, '学生', '{"project": "r", "attendance": "r", "report": "rw", "equip": "r"}', '学生用户');

-- 用户 (23)
INSERT INTO 用户表 VALUES
(1,'admin','系统管理员','A001',1, SHA2('123',256),'13800000001','admin@henau.edu.cn',1,'2025-01-01 08:00:00'),
(2,'t001','张建国','T001',2, SHA2('123',256),'13800000002','zhangjg@henau.edu.cn',1,'2025-01-01 08:00:00'),
(3,'t002','李美华','T002',2, SHA2('123',256),'13800000003','limh@henau.edu.cn',1,'2025-01-01 08:00:00'),
(4,'t003','王志强','T003',2, SHA2('123',256),'13800000004','wangzq@henau.edu.cn',1,'2025-01-01 08:00:00'),
(5,'t004','赵春梅','T004',2, SHA2('123',256),'13800000005','zhaocm@henau.edu.cn',1,'2025-01-01 08:00:00'),
(6,'t005','刘明辉','T005',2, SHA2('123',256),'13800000006','liumh@henau.edu.cn',1,'2025-01-01 08:00:00'),
(7,'s001','陈晓宇','20230101',3, SHA2('123',256),'13900000001','',1,'2025-09-01 08:00:00'),
(8,'s002','林小芳','20230102',3, SHA2('123',256),'13900000002','',1,'2025-09-01 08:00:00'),
(9,'s003','周大鹏','20230103',3, SHA2('123',256),'13900000003','',1,'2025-09-01 08:00:00'),
(10,'s004','吴丽丽','20230104',3, SHA2('123',256),'13900000004','',1,'2025-09-01 08:00:00'),
(11,'s005','黄俊杰','20230105',3, SHA2('123',256),'13900000005','',1,'2025-09-01 08:00:00'),
(12,'s006','郑美玲','20230106',3, SHA2('123',256),'13900000006','',1,'2025-09-01 08:00:00'),
(13,'s007','赵建峰','20230107',3, SHA2('123',256),'13900000007','',1,'2025-09-01 08:00:00'),
(14,'s008','孙雅婷','20230108',3, SHA2('123',256),'13900000008','',1,'2025-09-01 08:00:00'),
(15,'s009','周昊然','20230109',3, SHA2('123',256),'13900000009','',1,'2025-09-01 08:00:00'),
(16,'s010','钱小慧','20230110',3, SHA2('123',256),'13900000010','',1,'2025-09-01 08:00:00'),
(17,'s011','林志远','20230111',3, SHA2('123',256),'13900000011','',1,'2025-09-01 08:00:00'),
(18,'s012','黄小燕','20230112',3, SHA2('123',256),'13900000012','',1,'2025-09-01 08:00:00'),
(19,'s013','马小龙','20230113',3, SHA2('123',256),'13900000013','',1,'2025-09-01 08:00:00'),
(20,'s014','刘思雨','20230114',3, SHA2('123',256),'13900000014','',1,'2025-09-01 08:00:00'),
(21,'s015','杨浩然','20230115',3, SHA2('123',256),'13900000015','',1,'2025-09-01 08:00:00'),
(22,'s016','何小雨','20230116',3, SHA2('123',256),'13900000016','',1,'2025-09-01 08:00:00'),
(23,'s017','蒋一鸣','20230117',3, SHA2('123',256),'13900000017','',1,'2025-09-01 08:00:00');

-- 系统字典 (7)
INSERT INTO 系统字典 VALUES
(1,'场地状态','idle','空闲',1,1),
(2,'场地状态','in_use','使用中',2,1),
(3,'场地状态','maint','维护中',3,1),
(4,'生长状态','seeding','播种期',1,1),
(5,'生长状态','growing','生长期',2,1),
(6,'生长状态','harvest','收获期',3,1),
(7,'生长状态','abnormal','异常',4,1);

-- 场地类型 (3)
INSERT INTO 场地类型表 VALUES
(1,'温室大棚','温控玻璃大棚，适用于精细育苗'),
(2,'试验农田','露天试验田，适用于大田作物'),
(3,'实验室','室内实验操作与检测');

-- 实训场地 (10)
INSERT INTO 实训场地表 VALUES
(1, 'VN-001', '1号温室大棚',        1, 200.00, '蔬菜育苗与水培实验',         '空闲',   '张建国', ''),
(2, 'VN-002', '2号温室大棚',        1, 180.00, '花卉与观赏植物培育',         '使用中', '李美华', ''),
(3, 'VN-003', '3号温室大棚',        1, 250.00, '果树嫁接与栽培实验',         '空闲',   '张建国', ''),
(4, 'VN-004', '东区试验田A区',      2, 500.00, '小麦育种与栽培实验',         '使用中', '王志强', ''),
(5, 'VN-005', '东区试验田B区',      2, 450.00, '玉米杂交实验',               '空闲',   '王志强', ''),
(6, 'VN-006', '西区试验田',          2, 600.00, '大豆与杂粮栽培',             '维护中', '赵春梅', '灌溉系统维修'),
(7, 'VN-007', '植物生理实验室',      3, 80.00,  '植物光合作用与生理指标检测', '空闲',   '刘明辉', ''),
(8, 'VN-008', '土壤分析实验室',      3, 60.00,  '土壤成分分析',               '空闲',   '刘明辉', ''),
(9, 'VN-009', '南示范田',            2, 800.00, '新品种展示与示范',           '使用中', '赵春梅', ''),
(10,'VN-010', '微生物培养室',        3, 40.00,  '微生物与菌剂培养',           '空闲',   '刘明辉', '');

-- 作物品种 (12)
INSERT INTO 作物品种表 VALUES
(1,'豫麦58号','禾本科小麦属',240,'15-28°C / 60-75%','河南省审定高产品种'),
(2,'郑单958','禾本科玉米属',120,'20-35°C / 50-70%','高产玉米杂交种'),
(3,'豫豆29号','豆科大豆属',110,'18-30°C / 60-80%','优质大豆品种'),
(4,'番茄(金棚一号)','茄科番茄属',90,'15-30°C / 50-70%','温室番茄品种'),
(5,'黄瓜(津优35号)','葫芦科黄瓜属',75,'18-32°C / 70-85%','温室黄瓜品种'),
(6,'月季(粉和平)','蔷薇科蔷薇属',180,'15-28°C / 50-65%','观赏花卉品种'),
(7,'苹果(红富士)','蔷薇科苹果属',1095,'10-28°C / 50-70%','果树嫁接砧木'),
(8,'香菇(0912)','口蘑科香菇属',90,'15-25°C / 80-90%','食用菌品种'),
(9,'豫花23号','豆科花生属',130,'20-32°C / 60-75%','优质花生品种'),
(10,'水稻(豫粳6号)','禾本科稻属',150,'20-35°C / 70-90%','河南省粳稻品种'),
(11,'草莓(章姬)','蔷薇科草莓属',100,'15-25°C / 60-75%','温室草莓品种'),
(12,'辣椒(豫椒3号)','茄科辣椒属',110,'18-32°C / 55-70%','温室辣椒品种');

-- 器材分类 (3)
INSERT INTO 器材分类表 VALUES
(1,'农具','锄头/铁锹/剪刀等类工具'),
(2,'仪器','测量/检测设备'),
(3,'耗材','种子/肥料/基质等消耗品');

-- 器材档案 (20)
INSERT INTO 器材档案表 VALUES
(1,'EQ-T001','园艺铁锹',    1,'中号/不锈钢', '把',20,5,25.00,  '工具库1-A'),
(2,'EQ-T002','修枝剪',      1,'大号/碳钢',   '把',15,5,18.00,  '工具库1-B'),
(3,'EQ-T003','电动剪枝机',   1,'220V/800W',  '台',5, 2,280.00, '工具库2-A'),
(4,'EQ-T004','喷雾器',      1,'16L/背负式', '台',10,3,65.00,  '工具库2-B'),
(5,'EQ-T005','锄头',        1,'中号/木柄',   '把',12,5,22.00,  '工具库1-C'),
(6,'EQ-I001','土壤pH计',    2,'精度0.1/便携','台',10,3,320.00, '仪器室A'),
(7,'EQ-I002','叶面积仪',    2,'手持式/LI-3000C','台',3,1,1580.00,'仪器室A'),
(8,'EQ-I003','自动气象站',   2,'多参数/无线','套',1,1,8800.00,'仪器室B'),
(9,'EQ-I004','光合仪',      2,'LI-6800','台',2,1,12500.00,'仪器室B'),
(10,'EQ-I005','显微镜',     2,'双目/1000X','台',8,2,3500.00,'仪器室C'),
(11,'EQ-C001','育苗基质',     3,'50L/袋',   '袋',30,10,18.00, '耗材库A'),
(12,'EQ-C002','复合肥',       3,'50kg/袋',  '袋',20,5, 120.00,'耗材库B'),
(13,'EQ-C003','多菌灵',       3,'500g/袋',  '袋',15,5, 8.00,  '耗材库C'),
(14,'EQ-C004','穴盘(128孔)',  3,'54×28cm', '个',50,20,3.50,  '耗材库A'),
(15,'EQ-C005','地膜',         3,'1.2m宽/5kg','卷',10,3,45.00, '耗材库B'),
(16,'EQ-C006','营养液(A液)',   3,'5L/桶',    '桶',8,2, 68.00,  '耗材库C'),
(17,'EQ-C007','营养液(B液)',   3,'5L/桶',    '桶',8,2, 68.00,  '耗材库C'),
(18,'EQ-C008','棉线手套',     3,'均码/12双','包',25,10,15.00, '耗材库A'),
(19,'EQ-C009','标本瓶',       3,'500ml/玻璃','个',20,10,5.00,  '耗材库B'),
(20,'EQ-C010','恒温培养箱',   3,'50L/数显',  '台',4,1, 2800.00,'仪器室C');

-- 入库记录 (12)
INSERT INTO 入库记录表 VALUES
(1,1,30,25.00, '农资供应站', '2025-08-25', 1, '新学期采购'),
(2,2,20,18.00, '农资供应站', '2025-08-25', 1, '新学期采购'),
(3,3,5, 280.00,'河南农机公司','2025-08-28',1,'设备更新'),
(4,4,15,65.00, '河南农机公司', '2025-08-28', 1, '设备更新'),
(5,5,20,22.00, '农资供应站', '2025-08-25', 1, '新学期采购'),
(6,6,10,320.00,'郑州仪器公司','2025-09-01',2,'实验室采购'),
(7,7,3, 1580.00,'郑州仪器公司','2025-09-01',2,'实验室采购'),
(8,8,1, 8800.00,'郑州仪器公司','2025-09-05',4,'科研采购'),
(9,9,2, 12500.00,'郑州仪器公司','2025-09-05',4,'科研采购'),
(10,10,10,3500.00,'郑州仪器公司','2025-09-01',2,'实验室采购'),
(11,11,50,18.00,'育苗基质厂','2026-02-20',1,'春季采购'),
(12,12,30,120.00,'化肥经销商','2026-02-20',1,'春季采购');

-- 学期 (2)
INSERT INTO 学期表 VALUES
(1,'2025-2026-1','2025-09-01','2026-01-15',0),
(2,'2025-2026-2','2026-02-16','2026-07-10',1);

-- 实训项目 (8)
INSERT INTO 实训项目表 VALUES
(1,'小麦高产栽培技术实训','学习小麦从播种到收获的全流程栽培技术',4,2,2,'2026-03-02','2026-06-30',15,'进行中',NOW()),
(2,'玉米杂交育种实验','掌握玉米杂交套袋授粉等技术操作',5,2,4,'2026-03-01','2026-07-01',12,'进行中',NOW()),
(3,'温室蔬菜无土栽培','学习水培与基质栽培技术',1,2,2,'2026-03-10','2026-06-20',10,'进行中',NOW()),
(4,'土壤养分检测与分析','掌握土壤采样与实验室分析技能',8,2,6,'2026-03-15','2026-05-30',8,'进行中',NOW()),
(5,'花卉育苗与养护','温室花卉播种育苗全流程实训',2,2,3,'2026-03-05','2026-06-15',10,'招募中',NOW()),
(6,'食用菌栽培技术','香菇菌棒制作与出菇管理',10,2,5,'2026-03-20','2026-06-10',8,'招募中',NOW()),
(7,'植物病害诊断与防治','常见作物病害识别与药剂防治',7,2,6,'2026-04-01','2026-06-25',10,'招募中',NOW()),
(8,'果树嫁接技术实训','苹果苗木嫁接与后期管理',3,2,3,'2026-03-25','2026-06-30',8,'招募中',NOW());

-- 学生报名 (25)
INSERT INTO 学生报名表 VALUES
(1,1,7,'已通过','2026-02-20 10:00:00',NULL),
(2,1,8,'已通过','2026-02-20 10:30:00',NULL),
(3,1,9,'已通过','2026-02-20 11:00:00',NULL),
(4,1,10,'已通过','2026-02-21 09:00:00',NULL),
(5,1,11,'已通过','2026-02-21 09:30:00',NULL),
(6,1,12,'已通过','2026-02-21 10:00:00',NULL),
(7,2,13,'已通过','2026-02-20 10:00:00',NULL),
(8,2,14,'已通过','2026-02-20 11:00:00',NULL),
(9,2,15,'已通过','2026-02-21 09:00:00',NULL),
(10,2,16,'已通过','2026-02-21 10:00:00',NULL),
(11,2,17,'已通过','2026-02-22 09:00:00',NULL),
(12,2,18,'已通过','2026-02-22 10:00:00',NULL),
(13,3,7,'已通过','2026-02-22 14:00:00',NULL),
(14,3,19,'已通过','2026-02-22 14:30:00',NULL),
(15,3,20,'已通过','2026-02-22 15:00:00',NULL),
(16,3,21,'待审核','2026-02-22 15:30:00',NULL),
(17,4,8,'已通过','2026-02-23 09:00:00',NULL),
(18,4,10,'已通过','2026-02-23 09:30:00',NULL),
(19,4,14,'已通过','2026-02-23 10:00:00',NULL),
(20,4,17,'已通过','2026-02-23 10:30:00',NULL),
(21,5,9,'已通过','2026-02-24 09:00:00',NULL),
(22,5,12,'已通过','2026-02-24 10:00:00',NULL),
(23,6,13,'已通过','2026-02-24 11:00:00',NULL),
(24,7,15,'已通过','2026-02-25 09:00:00',NULL),
(25,8,16,'已通过','2026-02-25 10:00:00',NULL);

-- 实训任务 (8)
INSERT INTO 实训任务表 VALUES
(1,1,'小麦播种前准备','整地施肥/种子处理', '2026-03-15',10,NOW()),
(2,1,'小麦田间管理','灌溉/施肥/除草',     '2026-05-01',15,NOW()),
(3,1,'小麦病虫害防治','识别与防治',        '2026-05-20',10,NOW()),
(4,2,'玉米亲本播种','父母本分期播种',     '2026-03-20',15,NOW()),
(5,2,'玉米套袋授粉','杂交授粉操作',       '2026-05-01',20,NOW()),
(6,3,'营养液配制','各配方营养液配制',     '2026-03-25',15,NOW()),
(7,3,'水培系统搭建','水培设备安装调试',   '2026-03-30',10,NOW()),
(8,4,'土壤采样','多点采样法采集土壤样品', '2026-03-25',10,NOW());

-- 实训报告 (5)
INSERT INTO 实训报告表 VALUES
(1,1,1,'按操作规程完成整地，施用基肥50kg/亩...',NULL,'2026-03-14 16:00:00',88,'完成良好','2026-03-16 10:00:00'),
(2,2,1,'完成种子精选，发芽率检测95%...',NULL,'2026-03-15 17:00:00',92,'操作规范','2026-03-17 09:00:00'),
(3,7,4,'按杂交育种规程完成亲本播种...',NULL,'2026-03-19 15:00:00',85,'需注意行比','2026-03-22 10:00:00'),
(4,13,6,'完成营养液配制，各元素配比正确...',NULL,'2026-03-24 16:30:00',90,'配比准确','2026-03-26 09:00:00'),
(5,17,8,'完成三个采样点土样采集...',NULL,'2026-03-24 17:00:00',78,'采样点选择可优化','2026-03-27 10:00:00');

-- 考勤场次 (8)
INSERT INTO 考勤场次表 VALUES
(1,1,'2026-03-02','08:00:00','11:30:00','4号试验田',0,2,NOW()),
(2,1,'2026-03-09','08:00:00','11:30:00','4号试验田',0,2,NOW()),
(3,1,'2026-03-16','13:00:00','17:00:00','4号试验田',0,2,NOW()),
(4,2,'2026-03-01','08:00:00','11:30:00','5号试验田',0,4,NOW()),
(5,2,'2026-03-08','08:00:00','11:30:00','5号试验田',0,4,NOW()),
(6,3,'2026-03-10','08:30:00','12:00:00','1号温室',0,2,NOW()),
(7,3,'2026-03-17','08:30:00','12:00:00','1号温室',0,2,NOW()),
(8,4,'2026-03-15','14:00:00','17:30:00','土壤分析实验室',0,6,NOW());

-- 签到记录 (30)
INSERT INTO 签到记录表 (场次ID,学生ID,签到时间,签到状态) VALUES
(1,7,'2026-03-02 07:55:00','出勤'),(1,8,'2026-03-02 07:58:00','出勤'),
(1,9,'2026-03-02 08:05:00','出勤'),(1,10,'2026-03-02 08:20:00','迟到'),
(1,11,'2026-03-02 07:50:00','出勤'),(1,12,'2026-03-02 08:02:00','出勤'),
(2,7,'2026-03-09 07:56:00','出勤'),(2,8,'2026-03-09 08:10:00','出勤'),
(2,9,'2026-03-09 07:59:00','出勤'),(2,10,'2026-03-09 07:55:00','出勤'),
(2,11,'2026-03-09 08:01:00','出勤'),(2,12,'2026-03-09 08:18:00','迟到'),
(3,7,'2026-03-16 13:02:00','出勤'),(3,8,'2026-03-16 13:05:00','出勤'),
(3,10,'2026-03-16 12:58:00','出勤'),(3,11,'2026-03-16 13:10:00','出勤'),
(3,12,'2026-03-16 13:20:00','迟到'),
(4,13,'2026-03-01 07:55:00','出勤'),(4,14,'2026-03-01 08:00:00','出勤'),
(4,15,'2026-03-01 08:03:00','出勤'),(4,16,'2026-03-01 07:58:00','出勤'),
(4,17,'2026-03-01 08:10:00','出勤'),(4,18,'2026-03-01 08:25:00','迟到'),
(5,13,'2026-03-08 07:50:00','出勤'),(5,14,'2026-03-08 08:02:00','出勤'),
(5,16,'2026-03-08 07:59:00','出勤'),(5,17,'2026-03-08 08:05:00','出勤'),
(6,7,'2026-03-10 08:28:00','出勤'),(6,19,'2026-03-10 08:31:00','出勤'),
(6,20,'2026-03-10 08:50:00','迟到');

-- 消耗记录 (3)
INSERT INTO 消耗记录表 VALUES
(1,11,1,3,'2026-03-02',2,'小麦播种基质消耗'),
(2,12,4,2,'2026-03-15',6,'土壤实验肥力添加'),
(3,13,3,1,'2026-03-17',2,'蔬菜病害防治');

-- 借用记录 (5)
INSERT INTO 借用记录表 (器材ID,用户ID,借用数量,借用日期,应还日期,实还日期,借用状态,审批人ID) VALUES
(1,7,2,'2026-03-02 08:00:00','2026-03-16','2026-03-16 12:00:00','已归还',2),
(2,13,3,'2026-03-01 08:00:00','2026-03-15','2026-03-14 17:00:00','已归还',4),
(4,8,1,'2026-03-09 08:00:00','2026-03-16',NULL,'借用中',2),
(6,20,1,'2026-03-15 14:00:00','2026-03-22',NULL,'借用中',6),
(9,14,1,'2026-03-01 08:00:00','2026-03-15','2026-03-13 16:00:00','已归还',4);

-- 通知公告 (3)
INSERT INTO 通知公告表 VALUES
(1,'关于2026年春季实训基地开放安排的通知','本学期实训基地将于2月16日正式开放...',1,1,'2026-02-10 08:00:00'),
(2,'实训安全培训通知','请所有参加实训项目的同学于2月25日前完成安全培训...',2,0,'2026-02-18 09:00:00'),
(3,'关于器材借用的管理规定','即日起器材借用需提前一天申请...',1,1,'2026-03-01 10:00:00');

-- 操作日志 (5)
INSERT INTO 操作日志表 (用户ID,模块,操作类型,目标类型,目标ID,描述) VALUES
(1,'场地','新增','实训场地表',1,'新增1号温室大棚'),
(1,'器材','新增','器材档案表',1,'新增园艺铁锹'),
(2,'项目','新增','实训项目表',1,'发布小麦高产栽培技术实训'),
(7,'报名','新增','学生报名表',1,'学生陈晓宇报名小麦项目'),
(2,'签到','新增','签到记录表',1,'场次1签到');

SET FOREIGN_KEY_CHECKS = 1;
