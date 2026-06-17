"""
河南农业大学实训管理系统 - SQLAlchemy ORM Models
30 tables | InnoDB | utf8mb4
"""
from sqlalchemy import (
    Column, Integer, BigInteger, SmallInteger, String, Text,
    Float, DateTime, Date, DECIMAL, ForeignKey, Time,
    Computed, Index, UniqueConstraint
)
from sqlalchemy.orm import relationship, declarative_base

Base = declarative_base()

# ==================== 基础体系 ====================
class 系统字典(Base):
    __tablename__ = '系统字典'
    字典ID   = Column(Integer, primary_key=True, autoincrement=True)
    字典类型 = Column(String(64), nullable=False)
    字典键   = Column(String(64), nullable=False)
    字典值   = Column(String(255), nullable=False)
    排序     = Column(Integer, default=0)
    是否启用 = Column(SmallInteger, default=1)

class 角色表(Base):
    __tablename__ = '角色表'
    角色ID   = Column(Integer, primary_key=True, autoincrement=True)
    角色名称 = Column(String(50), nullable=False, unique=True)
    权限列表 = Column(Text)
    描述     = Column(String(200))

class 用户表(Base):
    __tablename__ = '用户表'
    用户ID     = Column(Integer, primary_key=True, autoincrement=True)
    用户名     = Column(String(50), nullable=False, unique=True)
    真实姓名   = Column(String(50), nullable=False)
    学号工号   = Column(String(30))
    角色ID     = Column(Integer, ForeignKey('角色表.角色ID'), default=3)
    密码哈希   = Column(String(255), default='')
    手机号     = Column(String(20))
    邮箱       = Column(String(100))
    是否启用   = Column(SmallInteger, default=1)
    创建时间   = Column(DateTime)

class 操作日志表(Base):
    __tablename__ = '操作日志表'
    日志ID   = Column(Integer, primary_key=True, autoincrement=True)
    用户ID   = Column(Integer, ForeignKey('用户表.用户ID'))
    模块     = Column(String(50))
    操作类型 = Column(String(20), nullable=False)
    目标类型 = Column(String(50))
    目标ID   = Column(Integer)
    描述     = Column(Text)
    操作时间 = Column(DateTime)

class 通知公告表(Base):
    __tablename__ = '通知公告表'
    公告ID   = Column(Integer, primary_key=True, autoincrement=True)
    标题     = Column(String(200), nullable=False)
    内容     = Column(Text, nullable=False)
    发布人ID = Column(Integer, ForeignKey('用户表.用户ID'))
    是否置顶 = Column(SmallInteger, default=0)
    发布时间 = Column(DateTime)

# ==================== 模块1: 场地 ====================
class 场地类型表(Base):
    __tablename__ = '场地类型表'
    类型ID   = Column(Integer, primary_key=True, autoincrement=True)
    类型名称 = Column(String(50), nullable=False, unique=True)
    描述     = Column(String(200))

class 实训场地表(Base):
    __tablename__ = '实训场地表'
    场地ID   = Column(Integer, primary_key=True, autoincrement=True)
    场地编号 = Column(String(20), nullable=False, unique=True)
    场地名称 = Column(String(100), nullable=False)
    类型ID   = Column(Integer, ForeignKey('场地类型表.类型ID'))
    面积平米 = Column(DECIMAL(10, 2))
    主要用途 = Column(String(200))
    使用状态 = Column(String(20), default='空闲')
    责任人   = Column(String(50))
    备注     = Column(Text)

class 场地预约表(Base):
    __tablename__ = '场地预约表'
    预约ID   = Column(Integer, primary_key=True, autoincrement=True)
    场地ID   = Column(Integer, ForeignKey('实训场地表.场地ID'), nullable=False)
    项目ID   = Column(Integer)
    申请人ID = Column(Integer, ForeignKey('用户表.用户ID'), nullable=False)
    开始时间 = Column(DateTime, nullable=False)
    结束时间 = Column(DateTime, nullable=False)
    预约原因 = Column(String(500))
    审批状态 = Column(String(20), default='待审批')
    审批人ID = Column(Integer, ForeignKey('用户表.用户ID'))
    申请时间 = Column(DateTime)

class 场地维护表(Base):
    __tablename__ = '场地维护表'
    维护ID   = Column(Integer, primary_key=True, autoincrement=True)
    场地ID   = Column(Integer, ForeignKey('实训场地表.场地ID'), nullable=False)
    维护日期 = Column(Date, nullable=False)
    维护类型 = Column(String(50))
    描述     = Column(Text)
    费用     = Column(DECIMAL(10, 2))
    记录人ID = Column(Integer, ForeignKey('用户表.用户ID'))

# ==================== 模块2: 作物 ====================
class 作物品种表(Base):
    __tablename__ = '作物品种表'
    品种ID   = Column(Integer, primary_key=True, autoincrement=True)
    品种名称 = Column(String(100), nullable=False)
    科属     = Column(String(100))
    培育周期 = Column(Integer)
    温湿范围 = Column(String(50))
    描述     = Column(Text)

class 培育批次表(Base):
    __tablename__ = '培育批次表'
    批次ID   = Column(Integer, primary_key=True, autoincrement=True)
    批次名称 = Column(String(100), nullable=False)
    品种ID   = Column(Integer, ForeignKey('作物品种表.品种ID'), nullable=False)
    场地ID   = Column(Integer, ForeignKey('实训场地表.场地ID'))
    种植日期 = Column(Date)
    数量     = Column(Integer, default=0)
    生长状态 = Column(String(20), default='播种期')
    存活率   = Column(DECIMAL(5, 2))
    记录人ID = Column(Integer, ForeignKey('用户表.用户ID'))
    创建时间 = Column(DateTime)

class 生长观测表(Base):
    __tablename__ = '生长观测表'
    观测ID   = Column(Integer, primary_key=True, autoincrement=True)
    批次ID   = Column(Integer, ForeignKey('培育批次表.批次ID'), nullable=False)
    观测日期 = Column(Date, nullable=False)
    株高CM   = Column(DECIMAL(8, 2))
    叶片数   = Column(Integer)
    健康状态 = Column(String(50))
    备注     = Column(Text)
    观测人ID = Column(Integer, ForeignKey('用户表.用户ID'))

class 病虫害防治表(Base):
    __tablename__ = '病虫害防治表'
    防治ID     = Column(Integer, primary_key=True, autoincrement=True)
    批次ID     = Column(Integer, ForeignKey('培育批次表.批次ID'), nullable=False)
    发现日期   = Column(Date, nullable=False)
    病虫害类型 = Column(String(100))
    严重程度   = Column(String(20))
    防治措施   = Column(Text)
    防治结果   = Column(String(100))
    记录人ID   = Column(Integer, ForeignKey('用户表.用户ID'))

# ==================== 模块3: 项目 ====================
class 学期表(Base):
    __tablename__ = '学期表'
    学期ID   = Column(Integer, primary_key=True, autoincrement=True)
    学期名称 = Column(String(50), nullable=False, unique=True)
    开始日期 = Column(Date, nullable=False)
    结束日期 = Column(Date, nullable=False)
    是否当前 = Column(SmallInteger, default=0)

class 实训项目表(Base):
    __tablename__ = '实训项目表'
    项目ID     = Column(Integer, primary_key=True, autoincrement=True)
    项目名称   = Column(String(200), nullable=False)
    项目描述   = Column(Text)
    场地ID     = Column(Integer, ForeignKey('实训场地表.场地ID'))
    学期ID     = Column(Integer, ForeignKey('学期表.学期ID'))
    负责教师ID = Column(Integer, ForeignKey('用户表.用户ID'))
    开始日期   = Column(Date)
    结束日期   = Column(Date)
    人数上限   = Column(Integer, default=30)
    项目状态   = Column(String(20), default='招募中')
    创建时间   = Column(DateTime)

class 学生报名表(Base):
    __tablename__ = '学生报名表'
    报名ID   = Column(Integer, primary_key=True, autoincrement=True)
    项目ID   = Column(Integer, ForeignKey('实训项目表.项目ID'), nullable=False)
    学生ID   = Column(Integer, ForeignKey('用户表.用户ID'), nullable=False)
    报名状态 = Column(String(20), default='待审核')
    报名时间 = Column(DateTime)
    综合成绩 = Column(DECIMAL(5, 2))

class 实训任务表(Base):
    __tablename__ = '实训任务表'
    任务ID   = Column(Integer, primary_key=True, autoincrement=True)
    项目ID   = Column(Integer, ForeignKey('实训项目表.项目ID'), nullable=False)
    任务名称 = Column(String(200), nullable=False)
    任务描述 = Column(Text)
    截止时间 = Column(DateTime)
    权重     = Column(DECIMAL(5, 2), default=0)
    创建时间 = Column(DateTime)

class 实训报告表(Base):
    __tablename__ = '实训报告表'
    报告ID   = Column(Integer, primary_key=True, autoincrement=True)
    报名ID   = Column(Integer, ForeignKey('学生报名表.报名ID'), nullable=False, unique=True)
    任务ID   = Column(Integer, ForeignKey('实训任务表.任务ID'))
    报告内容 = Column(Text)
    文件路径 = Column(String(500))
    提交时间 = Column(DateTime)
    报告成绩 = Column(DECIMAL(5, 2))
    教师评语 = Column(Text)
    评分时间 = Column(DateTime)

class 学生互评表(Base):
    __tablename__ = '学生互评表'
    互评ID   = Column(Integer, primary_key=True, autoincrement=True)
    项目ID   = Column(Integer, ForeignKey('实训项目表.项目ID'), nullable=False)
    评分人ID = Column(Integer, ForeignKey('用户表.用户ID'), nullable=False)
    被评人ID = Column(Integer, ForeignKey('用户表.用户ID'), nullable=False)
    互评分数 = Column(DECIMAL(5, 2))
    评语     = Column(Text)
    创建时间 = Column(DateTime)

# ==================== 模块4: 器材 ====================
class 器材分类表(Base):
    __tablename__ = '器材分类表'
    分类ID   = Column(Integer, primary_key=True, autoincrement=True)
    分类名称 = Column(String(50), nullable=False)
    描述     = Column(String(200))

class 器材档案表(Base):
    __tablename__ = '器材档案表'
    器材ID   = Column(Integer, primary_key=True, autoincrement=True)
    器材编号 = Column(String(30), nullable=False, unique=True)
    器材名称 = Column(String(100), nullable=False)
    分类ID   = Column(Integer, ForeignKey('器材分类表.分类ID'))
    规格型号 = Column(String(100))
    单位     = Column(String(20), default='个')
    当前库存 = Column(Integer, default=0)
    最低库存 = Column(Integer, default=5)
    单价     = Column(DECIMAL(10, 2))
    存放位置 = Column(String(100))

class 入库记录表(Base):
    __tablename__ = '入库记录表'
    入库ID   = Column(Integer, primary_key=True, autoincrement=True)
    器材ID   = Column(Integer, ForeignKey('器材档案表.器材ID'), nullable=False)
    入库数量 = Column(Integer, nullable=False)
    入库单价 = Column(DECIMAL(10, 2))
    供应商   = Column(String(100))
    入库日期 = Column(Date, nullable=False)
    经办人ID = Column(Integer, ForeignKey('用户表.用户ID'))
    备注     = Column(String(500))

class 借用记录表(Base):
    __tablename__ = '借用记录表'
    借用ID   = Column(Integer, primary_key=True, autoincrement=True)
    器材ID   = Column(Integer, ForeignKey('器材档案表.器材ID'), nullable=False)
    用户ID   = Column(Integer, ForeignKey('用户表.用户ID'), nullable=False)
    借用数量 = Column(Integer, nullable=False)
    借用日期 = Column(DateTime)
    应还日期 = Column(DateTime)
    实还日期 = Column(DateTime)
    借用状态 = Column(String(20), default='借用中')
    项目ID   = Column(Integer, ForeignKey('实训项目表.项目ID'))
    审批人ID = Column(Integer, ForeignKey('用户表.用户ID'))

class 消耗记录表(Base):
    __tablename__ = '消耗记录表'
    消耗ID   = Column(Integer, primary_key=True, autoincrement=True)
    器材ID   = Column(Integer, ForeignKey('器材档案表.器材ID'), nullable=False)
    项目ID   = Column(Integer, ForeignKey('实训项目表.项目ID'))
    消耗数量 = Column(Integer, nullable=False)
    消耗日期 = Column(Date, nullable=False)
    记录人ID = Column(Integer, ForeignKey('用户表.用户ID'))
    备注     = Column(String(500))

class 盘点单表(Base):
    __tablename__ = '盘点单表'
    盘点ID   = Column(Integer, primary_key=True, autoincrement=True)
    盘点日期 = Column(Date, nullable=False)
    盘点人ID = Column(Integer, ForeignKey('用户表.用户ID'))
    盘点状态 = Column(String(20), default='进行中')
    备注     = Column(Text)
    创建时间 = Column(DateTime)

class 盘点明细表(Base):
    __tablename__ = '盘点明细表'
    明细ID   = Column(Integer, primary_key=True, autoincrement=True)
    盘点ID   = Column(Integer, ForeignKey('盘点单表.盘点ID'), nullable=False)
    器材ID   = Column(Integer, ForeignKey('器材档案表.器材ID'), nullable=False)
    账面数量 = Column(Integer)
    实盘数量 = Column(Integer)
    差异数量 = Column(Integer)
    差异原因 = Column(String(500))

# ==================== 模块5: 考勤 ====================
class 考勤场次表(Base):
    __tablename__ = '考勤场次表'
    场次ID     = Column(Integer, primary_key=True, autoincrement=True)
    项目ID     = Column(Integer, ForeignKey('实训项目表.项目ID'), nullable=False)
    场次日期   = Column(Date, nullable=False)
    开始时间   = Column(Time, nullable=False)
    结束时间   = Column(Time)
    地点       = Column(String(100))
    实到人数   = Column(Integer, default=0)
    带队教师ID = Column(Integer, ForeignKey('用户表.用户ID'))
    创建时间   = Column(DateTime)

class 签到记录表(Base):
    __tablename__ = '签到记录表'
    签到ID   = Column(Integer, primary_key=True, autoincrement=True)
    场次ID   = Column(Integer, ForeignKey('考勤场次表.场次ID'), nullable=False)
    学生ID   = Column(Integer, ForeignKey('用户表.用户ID'), nullable=False)
    签到时间 = Column(DateTime)
    签到状态 = Column(String(20), default='缺勤')

class 教师带队表(Base):
    __tablename__ = '教师带队表'
    带队ID   = Column(Integer, primary_key=True, autoincrement=True)
    场次ID   = Column(Integer, ForeignKey('考勤场次表.场次ID'), nullable=False)
    教师ID   = Column(Integer, ForeignKey('用户表.用户ID'), nullable=False)
    送达时间 = Column(DateTime)
    离开时间 = Column(DateTime)
    备注     = Column(Text)
    创建时间 = Column(DateTime)

class 请假申请表(Base):
    __tablename__ = '请假申请表'
    请假ID   = Column(Integer, primary_key=True, autoincrement=True)
    学生ID   = Column(Integer, ForeignKey('用户表.用户ID'), nullable=False)
    项目ID   = Column(Integer, ForeignKey('实训项目表.项目ID'), nullable=False)
    场次ID   = Column(Integer, ForeignKey('考勤场次表.场次ID'))
    请假类型 = Column(String(20), default='事假')
    请假原因 = Column(Text, nullable=False)
    开始时间 = Column(DateTime, nullable=False)
    结束时间 = Column(DateTime, nullable=False)
    审批状态 = Column(String(20), default='待审批')
    审批人ID = Column(Integer, ForeignKey('用户表.用户ID'))
    申请时间 = Column(DateTime)
    审批时间 = Column(DateTime)
