"""
河南农业大学实训管理系统 - FastAPI Backend
30 tables | Login + CRUD + Attendance Check-in
Model fields aligned with agri_base.sql
"""
from fastapi import FastAPI, Depends, HTTPException, Query, Header, Body, Request
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import create_engine, func, text, desc
from sqlalchemy.orm import sessionmaker, Session
from typing import Optional, List
from datetime import date, datetime
import os, hashlib, secrets

# ==================== 数据库配置 ====================
DB_URL = "mysql+pymysql://root:123456@localhost:3306/河南农业大学实训管理系统?charset=utf8mb4"
engine = create_engine(DB_URL, pool_pre_ping=True, echo=False)
SessionLocal = sessionmaker(bind=engine, autoflush=False)

def get_db():
    db = SessionLocal()
    try: yield db
    finally: db.close()

# ==================== 模型（与 agri_base.sql 完全对齐） ====================
from sqlalchemy import Column, Integer, String, Date, DateTime, Text, Boolean, ForeignKey, DECIMAL, Time, BigInteger
from sqlalchemy.orm import registry, relationship
mapper_registry = registry()
Base = mapper_registry.generate_base()

# 用户表 — 对齐 agri_base.sql line 40-54
class 用户表(Base):
    __tablename__ = "用户表"
    用户ID = Column(BigInteger, primary_key=True)
    用户名 = Column(String(50), unique=True, nullable=False)
    真实姓名 = Column(String(50), nullable=False)
    学号工号 = Column(String(30), unique=True)
    角色ID = Column(Integer)
    密码哈希 = Column(String(255), nullable=False, default="")
    手机号 = Column(String(20))
    邮箱 = Column(String(100))
    是否启用 = Column(Integer, default=1)
    创建时间 = Column(DateTime)

class 角色表(Base):
    __tablename__ = "角色表"
    角色ID = Column(Integer, primary_key=True)
    角色名称 = Column(String(50), nullable=False, unique=True)
    权限列表 = Column(Text)
    描述 = Column(String(200))

# 实训场地表 — 对齐 agri_base.sql line 96-109
class 实训场地表(Base):
    __tablename__ = "实训场地表"
    场地ID = Column(BigInteger, primary_key=True)
    场地编号 = Column(String(20), unique=True, nullable=False)
    场地名称 = Column(String(100), nullable=False)
    类型ID = Column(Integer)
    面积平米 = Column(DECIMAL(10, 2))
    主要用途 = Column(String(200))
    使用状态 = Column(String(20), default="空闲")
    责任人 = Column(String(50))
    备注 = Column(Text)

# 场地类型表
class 场地类型表(Base):
    __tablename__ = "场地类型表"
    类型ID = Column(Integer, primary_key=True)
    类型名称 = Column(String(50), unique=True, nullable=False)
    描述 = Column(String(200))

# 作物品种表 — 对齐 agri_base.sql line 149-156（替换原来的 实训作物表）
class 作物品种表(Base):
    __tablename__ = "作物品种表"
    品种ID = Column(Integer, primary_key=True)
    品种名称 = Column(String(100), nullable=False)
    科属 = Column(String(100))
    培育周期 = Column(Integer)
    温湿范围 = Column(String(50))
    描述 = Column(Text)

# 培育批次表 — 对齐 agri_base.sql line 159-176
class 培育批次表(Base):
    __tablename__ = "培育批次表"
    批次ID = Column(BigInteger, primary_key=True)
    批次名称 = Column(String(100), nullable=False)
    品种ID = Column(Integer)
    场地ID = Column(BigInteger)
    种植日期 = Column(Date)
    数量 = Column(Integer, default=0)
    生长状态 = Column(String(20), default="播种期")
    存活率 = Column(DECIMAL(5, 2))
    记录人ID = Column(BigInteger)
    创建时间 = Column(DateTime)

# 实训项目表 — 对齐 agri_base.sql line 222-240
class 实训项目表(Base):
    __tablename__ = "实训项目表"
    项目ID = Column(BigInteger, primary_key=True)
    项目名称 = Column(String(200), nullable=False)
    项目描述 = Column(Text)
    场地ID = Column(BigInteger)
    学期ID = Column(Integer)
    负责教师ID = Column(BigInteger)
    开始日期 = Column(Date)
    结束日期 = Column(Date)
    人数上限 = Column(Integer, default=30)
    项目状态 = Column(String(20), default="招募中")
    创建时间 = Column(DateTime)

# 学生报名表 — 对齐 agri_base.sql line 243-255
class 学生报名表(Base):
    __tablename__ = "学生报名表"
    报名ID = Column(BigInteger, primary_key=True)
    项目ID = Column(BigInteger, nullable=False)
    学生ID = Column(BigInteger, nullable=False)
    报名状态 = Column(String(20), default="待审核")
    报名时间 = Column(DateTime)
    综合成绩 = Column(DECIMAL(5, 2))

# 场地预约表 — 对齐 agri_base.sql line 112-128
class 场地预约表(Base):
    __tablename__ = "场地预约表"
    预约ID = Column(BigInteger, primary_key=True)
    场地ID = Column(BigInteger, nullable=False)
    项目ID = Column(BigInteger)
    申请人ID = Column(BigInteger, nullable=False)
    开始时间 = Column(DateTime, nullable=False)
    结束时间 = Column(DateTime, nullable=False)
    预约原因 = Column(String(500))
    审批状态 = Column(String(20), default="待审批")
    审批人ID = Column(BigInteger)
    申请时间 = Column(DateTime)

# 场地维护表 — 对齐 agri_base.sql line 131-142
class 场地维护表(Base):
    __tablename__ = "场地维护表"
    维护ID = Column(BigInteger, primary_key=True)
    场地ID = Column(BigInteger, nullable=False)
    维护日期 = Column(Date, nullable=False)
    维护类型 = Column(String(50))
    描述 = Column(Text)
    费用 = Column(DECIMAL(10, 2))
    记录人ID = Column(BigInteger)

# 器材分类表
class 器材分类表(Base):
    __tablename__ = "器材分类表"
    分类ID = Column(Integer, primary_key=True)
    分类名称 = Column(String(50), nullable=False)
    描述 = Column(String(200))

# 器材档案表 — 对齐 agri_base.sql line 314-327
class 器材档案表(Base):
    __tablename__ = "器材档案表"
    器材ID = Column(BigInteger, primary_key=True)
    器材编号 = Column(String(30), unique=True, nullable=False)
    器材名称 = Column(String(100), nullable=False)
    分类ID = Column(Integer)
    规格型号 = Column(String(100))
    单位 = Column(String(20), default="个")
    当前库存 = Column(Integer, default=0)
    最低库存 = Column(Integer, default=5)
    单价 = Column(DECIMAL(10, 2))
    存放位置 = Column(String(100))

# 借用记录表 — 对齐 agri_base.sql line 345-363
class 借用记录表(Base):
    __tablename__ = "借用记录表"
    借用ID = Column(BigInteger, primary_key=True)
    器材ID = Column(BigInteger, nullable=False)
    用户ID = Column(BigInteger, nullable=False)
    借用数量 = Column(Integer, nullable=False)
    借用日期 = Column(DateTime)
    应还日期 = Column(DateTime)
    实还日期 = Column(DateTime)
    借用状态 = Column(String(20), default="借用中")
    项目ID = Column(BigInteger)
    审批人ID = Column(BigInteger)

# 消耗记录表 — 对齐 agri_base.sql line 366-379
class 消耗记录表(Base):
    __tablename__ = "消耗记录表"
    消耗ID = Column(BigInteger, primary_key=True)
    器材ID = Column(BigInteger, nullable=False)
    项目ID = Column(BigInteger)
    消耗数量 = Column(Integer, nullable=False)
    消耗日期 = Column(Date, nullable=False)
    记录人ID = Column(BigInteger)
    备注 = Column(String(500))

# 考勤场次表 — 对齐 agri_base.sql line 412-426
class 考勤场次表(Base):
    __tablename__ = "考勤场次表"
    场次ID = Column(BigInteger, primary_key=True)
    项目ID = Column(BigInteger, nullable=False)
    场次日期 = Column(Date, nullable=False)
    开始时间 = Column(Time, nullable=False)
    结束时间 = Column(Time)
    地点 = Column(String(100))
    实到人数 = Column(Integer, default=0)
    带队教师ID = Column(BigInteger)
    创建时间 = Column(DateTime)

# 签到记录表 — 对齐 agri_base.sql line 429-440
class 签到记录表(Base):
    __tablename__ = "签到记录表"
    签到ID = Column(BigInteger, primary_key=True)
    场次ID = Column(BigInteger, nullable=False)
    学生ID = Column(BigInteger, nullable=False)
    签到时间 = Column(DateTime)
    签到状态 = Column(String(20), default="缺勤")

# 操作日志表 — 对齐 agri_base.sql line 57-70
class 操作日志表(Base):
    __tablename__ = "操作日志表"
    日志ID = Column(BigInteger, primary_key=True)
    用户ID = Column(BigInteger)
    模块 = Column(String(50), nullable=False)
    操作类型 = Column(String(20), nullable=False)
    目标类型 = Column(String(50))
    目标ID = Column(BigInteger)
    描述 = Column(Text)
    操作时间 = Column(DateTime)

# ==================== 缓存与认证 ====================
CACHE = {}

def auth_required(authorization: str = Header(None)):
    if not authorization:
        raise HTTPException(status_code=401, detail="未登录")
    token = authorization.replace("Bearer ", "")
    uid = CACHE.get(token)
    if not uid:
        raise HTTPException(status_code=401, detail="登录已过期")
    db = SessionLocal()
    u = db.query(用户表).filter(用户表.用户ID == uid, 用户表.是否启用 == 1).first()
    db.close()
    if not u:
        raise HTTPException(status_code=401, detail="用户已被禁用")
    return u

def sha256(pwd: str) -> str:
    return hashlib.sha256(pwd.encode("utf-8")).hexdigest()

# ==================== FastAPI 初始化 ====================
app = FastAPI(title="河南农业大学实训管理系统 API", docs_url="/docs")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ==================== 认证 ====================
@app.post("/api/login", tags=["认证"])
def login(data: dict = Body(...)):
    db = SessionLocal()
    name = data.get("用户名", "")
    pwd = sha256(data.get("密码", ""))
    u = db.query(用户表).filter(用户表.用户名 == name, 用户表.密码哈希 == pwd, 用户表.是否启用 == 1).first()
    if not u:
        db.close()
        raise HTTPException(401, "用户名或密码错误")
    token = secrets.token_hex(16)
    CACHE[token] = u.用户ID
    role = db.query(角色表).filter(角色表.角色ID == u.角色ID).first()
    db.close()
    return {
        "token": token,
        "用户ID": u.用户ID,
        "用户名": u.用户名,
        "真实姓名": u.真实姓名,
        "角色名称": role.角色名称 if role else "",
        "角色ID": u.角色ID,
        "学号工号": u.学号工号
    }

@app.post("/api/logout", tags=["认证"])
def logout(authorization: str = Header(None)):
    if authorization:
        token = authorization.replace("Bearer ", "")
        CACHE.pop(token, None)
    return {"ok": True}

@app.put("/api/me/password", tags=["认证"])
def change_my_password(data: dict = Body(...), user=Depends(auth_required), db: Session = Depends(get_db)):
    """所有人修改自己的密码，需要验证旧密码"""
    old_pwd = sha256(data.get("旧密码", ""))
    new_pwd = data.get("新密码", "")
    if not new_pwd or len(new_pwd) < 1:
        raise HTTPException(400, "新密码不能为空")
    # 用当前 db session 重新查出用户对象，因为 auth_required 返回的是已脱离 session 的对象
    u = db.query(用户表).filter(用户表.用户ID == user.用户ID).first()
    if u.密码哈希 != old_pwd:
        raise HTTPException(400, "旧密码错误")
    u.密码哈希 = sha256(new_pwd)
    db.commit()
    log = 操作日志表(用户ID=user.用户ID, 模块="用户", 操作类型="修改", 目标类型="用户表", 目标ID=user.用户ID, 描述=f"修改密码", 操作时间=datetime.now())
    db.add(log); db.commit()
    return {"ok": True, "message": "密码修改成功"}

@app.put("/api/me/profile", tags=["认证"])
def change_my_profile(data: dict = Body(...), user=Depends(auth_required), db: Session = Depends(get_db)):
    """所有人修改自己的真实姓名，账号（学号工号/用户名）不可改"""
    new_name = data.get("真实姓名", "").strip()
    if not new_name:
        raise HTTPException(400, "姓名不能为空")
    # 用当前 db session 重新查出用户对象
    u = db.query(用户表).filter(用户表.用户ID == user.用户ID).first()
    old_name = u.真实姓名
    u.真实姓名 = new_name
    db.commit()
    log = 操作日志表(用户ID=user.用户ID, 模块="用户", 操作类型="修改", 目标类型="用户表", 目标ID=user.用户ID, 描述=f"修改姓名: {old_name} → {new_name}", 操作时间=datetime.now())
    db.add(log); db.commit()
    return {"ok": True, "真实姓名": new_name, "message": "姓名修改成功"}

# ==================== 仪表盘 ====================
@app.get("/api/dashboard/stats", tags=["仪表盘"])
def dashboard_stats(db: Session = Depends(get_db)):
    return {
        "用户数": db.query(func.count(用户表.用户ID)).filter(用户表.是否启用 == 1).scalar() or 0,
        "场地数": db.query(func.count(实训场地表.场地ID)).scalar() or 0,
        "作物数": db.query(func.count(培育批次表.批次ID)).scalar() or 0,
        "项目数": db.query(func.count(实训项目表.项目ID)).filter(实训项目表.项目状态 != "已结束").scalar() or 0,
        "器材数": db.query(func.count(器材档案表.器材ID)).scalar() or 0,
        "预约数": db.query(func.count(场地预约表.预约ID)).scalar() or 0,
        "考勤场次": db.query(func.count(考勤场次表.场次ID)).scalar() or 0,
        "日志数": db.query(func.count(操作日志表.日志ID)).scalar() or 0,
    }

@app.get("/api/dashboard/logs", tags=["仪表盘"])
def dashboard_logs(db: Session = Depends(get_db)):
    logs = db.query(操作日志表).order_by(desc(操作日志表.操作时间)).limit(8).all()
    return [{
        "日志ID": l.日志ID,
        "描述": l.描述,
        "操作时间": str(l.操作时间)[:16] if l.操作时间 else "",
        "用户姓名": db.query(用户表).filter(用户表.用户ID == l.用户ID).first().真实姓名 if l.用户ID else ""
    } for l in logs]

@app.get("/api/dashboard/charts", tags=["仪表盘"])
def dashboard_charts(db: Session = Depends(get_db)):
    """返回图表数据：角色分布、器材库存、项目状态、考勤统计"""
    # 角色分布
    roles = db.query(角色表).all()
    角色分布 = []
    for r in roles:
        cnt = db.query(func.count(用户表.用户ID)).filter(用户表.角色ID == r.角色ID, 用户表.是否启用 == 1).scalar() or 0
        角色分布.append({"角色名称": r.角色名称, "人数": cnt})

    # 器材库存概览
    器材总数 = db.query(func.count(器材档案表.器材ID)).scalar() or 0
    low = db.query(func.count(器材档案表.器材ID)).filter(器材档案表.当前库存 <= 器材档案表.最低库存).scalar() or 0
    器材库存 = {"总数": 器材总数, "低库存数": low, "正常数": 器材总数 - low}

    # 项目状态分布
    from sqlalchemy import func as sa_func
    results = db.query(实训项目表.项目状态, sa_func.count(实训项目表.项目ID)).group_by(实训项目表.项目状态).all()
    项目状态 = [{"状态": s, "数量": c} for s, c in results]

    # 考勤统计：近7天每日签到数
    from datetime import timedelta
    today = datetime.now().date()
    考勤趋势 = []
    for i in range(6, -1, -1):
        d = today - timedelta(days=i)
        cnt = db.query(func.count(签到记录表.签到ID)).filter(
            func.date(签到记录表.签到时间) == d
        ).scalar() or 0
        考勤趋势.append({"日期": str(d), "签到数": cnt})

    return {
        "角色分布": 角色分布,
        "器材库存": 器材库存,
        "项目状态": 项目状态,
        "考勤趋势": 考勤趋势
    }

# ==================== 用户管理 ====================
@app.get("/api/users", tags=["用户管理"])
def list_users(all: bool = False, db: Session = Depends(get_db)):
    q = db.query(用户表)
    if not all:
        q = q.filter(用户表.是否启用 == 1)
    users = q.order_by(用户表.用户ID).all()
    return [{
        "用户ID": u.用户ID, "用户名": u.用户名, "真实姓名": u.真实姓名,
        "学号工号": u.学号工号, "角色ID": u.角色ID, "手机号": u.手机号,
        "邮箱": u.邮箱, "是否启用": u.是否启用,
        "角色名称": db.query(角色表).filter(角色表.角色ID == u.角色ID).first().角色名称 if u.角色ID else ""
    } for u in users]

@app.post("/api/users", tags=["用户管理"])
def create_user(data: dict = Body(...), user=Depends(auth_required), db: Session = Depends(get_db)):
    if db.query(用户表).filter(用户表.用户名 == data["用户名"]).first():
        raise HTTPException(400, "用户名已存在")
    u = 用户表(
        用户名=data["用户名"], 真实姓名=data["真实姓名"],
        学号工号=data.get("学号工号", ""), 角色ID=data.get("角色ID", 3),
        密码哈希=sha256(data.get("密码", "123456")), 手机号=data.get("手机号", ""),
        邮箱=data.get("邮箱", ""), 是否启用=1, 创建时间=datetime.now()
    )
    db.add(u); db.commit(); db.refresh(u)
    log = 操作日志表(用户ID=user.用户ID, 模块="用户", 操作类型="新增", 目标类型="用户表", 目标ID=u.用户ID, 描述=f"新增用户 {u.用户名}", 操作时间=datetime.now())
    db.add(log); db.commit()
    return {"ok": True, "用户ID": u.用户ID}

@app.put("/api/users/{uid}", tags=["用户管理"])
def update_user(uid: int, data: dict = Body(...), user=Depends(auth_required), db: Session = Depends(get_db)):
    u = db.query(用户表).filter(用户表.用户ID == uid).first()
    if not u: raise HTTPException(404, "用户不存在")
    for k in ["用户名", "真实姓名", "学号工号", "角色ID", "手机号", "邮箱", "是否启用"]:
        if k in data and data[k] is not None:
            setattr(u, k, data[k])
    if data.get("密码"):
        u.密码哈希 = sha256(data["密码"])
    db.commit()
    return {"ok": True}

@app.delete("/api/users/{uid}", tags=["用户管理"])
def delete_user(uid: int, user=Depends(auth_required), db: Session = Depends(get_db)):
    if user.角色ID == 2:
        target = db.query(用户表).filter(用户表.用户ID == uid).first()
        if not target or target.角色ID != 3:
            raise HTTPException(403, "教师只能删除学生用户")
    elif user.用户ID == uid:
        raise HTTPException(400, "不能删除自己")
    u = db.query(用户表).filter(用户表.用户ID == uid).first()
    if not u: raise HTTPException(404, "用户不存在")
    name = u.用户名
    u.是否启用 = 0
    log = 操作日志表(用户ID=user.用户ID, 模块="用户", 操作类型="删除", 目标类型="用户表", 目标ID=uid, 描述=f"禁用用户 {name}", 操作时间=datetime.now())
    db.add(log); db.commit()
    return {"ok": True}

@app.put("/api/users/{uid}/restore", tags=["用户管理"])
def restore_user(uid: int, user=Depends(auth_required), db: Session = Depends(get_db)):
    if user.角色ID != 1:
        raise HTTPException(403, "只有管理员可以启用用户")
    u = db.query(用户表).filter(用户表.用户ID == uid).first()
    if not u: raise HTTPException(404, "用户不存在")
    u.是否启用 = 1
    log = 操作日志表(用户ID=user.用户ID, 模块="用户", 操作类型="修改", 目标类型="用户表", 目标ID=uid, 描述=f"启用用户 {u.用户名}", 操作时间=datetime.now())
    db.add(log); db.commit()
    return {"ok": True}

@app.put("/api/users/{uid}/reset-password", tags=["用户管理"])
def reset_user_password(uid: int, data: dict = Body(...), user=Depends(auth_required), db: Session = Depends(get_db)):
    """重置用户密码: 管理员可重置所有人, 教师仅可重置学生"""
    target = db.query(用户表).filter(用户表.用户ID == uid).first()
    if not target:
        raise HTTPException(404, "用户不存在")
    # 权限校验
    if user.角色ID == 1:
        pass  # 管理员可重置所有人
    elif user.角色ID == 2:
        if target.角色ID != 3:
            raise HTTPException(403, "教师只能重置学生密码")
    else:
        raise HTTPException(403, "无权限重置他人密码")
    new_pwd = data.get("新密码", "")
    if not new_pwd:
        raise HTTPException(400, "新密码不能为空")
    target.密码哈希 = sha256(new_pwd)
    db.commit()
    log = 操作日志表(用户ID=user.用户ID, 模块="用户", 操作类型="修改", 目标类型="用户表", 目标ID=uid, 描述=f"{user.真实姓名} 重置了 {target.真实姓名} 的密码", 操作时间=datetime.now())
    db.add(log); db.commit()
    return {"ok": True, "message": f"已重置 {target.真实姓名} 的密码"}

@app.get("/api/roles", tags=["用户管理"])
def list_roles(db: Session = Depends(get_db)):
    return [{"角色ID": r.角色ID, "角色名称": r.角色名称} for r in db.query(角色表).order_by(角色表.角色ID).all()]

# ==================== 场地管理 ====================
@app.get("/api/venues", tags=["场地管理"])
def list_venues(status: str = None, db: Session = Depends(get_db)):
    q = db.query(实训场地表)
    if status: q = q.filter(实训场地表.使用状态 == status)
    venues = q.order_by(实训场地表.场地ID).all()
    return [{
        "场地ID": v.场地ID, "场地编号": v.场地编号, "场地名称": v.场地名称,
        "类型名称": db.query(场地类型表).filter(场地类型表.类型ID == v.类型ID).first().类型名称 if v.类型ID else "",
        "类型ID": v.类型ID,
        "面积平米": float(v.面积平米) if v.面积平米 else None,
        "主要用途": v.主要用途, "使用状态": v.使用状态,
        "责任人": v.责任人, "备注": v.备注
    } for v in venues]

@app.get("/api/venue_types", tags=["场地管理"])
def list_venue_types(db: Session = Depends(get_db)):
    return [{"类型ID": t.类型ID, "类型名称": t.类型名称} for t in db.query(场地类型表).order_by(场地类型表.类型ID).all()]

@app.post("/api/venues", tags=["场地管理"])
def create_venue(data: dict = Body(...), user=Depends(auth_required), db: Session = Depends(get_db)):
    v = 实训场地表(
        场地编号=data.get("场地编号", ""), 场地名称=data["场地名称"],
        类型ID=data.get("类型ID"), 面积平米=data.get("面积平米"),
        主要用途=data.get("主要用途", ""), 使用状态=data.get("使用状态", "空闲"),
        责任人=data.get("责任人", ""), 备注=data.get("备注", "")
    )
    db.add(v); db.commit(); db.refresh(v)
    log = 操作日志表(用户ID=user.用户ID, 模块="场地", 操作类型="新增", 目标类型="实训场地表", 目标ID=v.场地ID, 描述=f"新增场地 {v.场地名称}", 操作时间=datetime.now())
    db.add(log); db.commit()
    return {"ok": True, "场地ID": v.场地ID}

@app.put("/api/venues/{vid}", tags=["场地管理"])
def update_venue(vid: int, data: dict = Body(...), user=Depends(auth_required), db: Session = Depends(get_db)):
    v = db.query(实训场地表).filter(实训场地表.场地ID == vid).first()
    if not v: raise HTTPException(404, "场地不存在")
    for k in ["场地编号", "场地名称", "类型ID", "面积平米", "主要用途", "使用状态", "责任人", "备注"]:
        if k in data and data[k] is not None:
            setattr(v, k, data[k])
    db.commit()
    return {"ok": True}

@app.delete("/api/venues/{vid}", tags=["场地管理"])
def delete_venue(vid: int, user=Depends(auth_required), db: Session = Depends(get_db)):
    if user.角色ID != 1:
        raise HTTPException(403, "只有管理员可以删除场地")
    # 级联清除
    db.query(培育批次表).filter(培育批次表.场地ID == vid).delete()
    db.query(场地预约表).filter(场地预约表.场地ID == vid).delete()
    db.query(场地维护表).filter(场地维护表.场地ID == vid).delete()
    v = db.query(实训场地表).filter(实训场地表.场地ID == vid).first()
    if v:
        name = v.场地名称
        db.delete(v)
        log = 操作日志表(用户ID=user.用户ID, 模块="场地", 操作类型="删除", 目标类型="实训场地表", 目标ID=vid, 描述=f"删除场地 {name}", 操作时间=datetime.now())
        db.add(log); db.commit()
    return {"ok": True}

# ==================== 作物管理 ====================
@app.get("/api/crops", tags=["作物管理"])
def list_crops(db: Session = Depends(get_db)):
    crops = db.query(作物品种表).order_by(desc(作物品种表.品种ID)).all()
    return [{
        "品种ID": c.品种ID, "品种名称": c.品种名称, "科属": c.科属,
        "培育周期": c.培育周期, "温湿范围": c.温湿范围, "描述": c.描述
    } for c in crops]

@app.post("/api/crops", tags=["作物管理"])
def create_crop(data: dict = Body(...), user=Depends(auth_required), db: Session = Depends(get_db)):
    c = 作物品种表(
        品种名称=data["品种名称"], 科属=data.get("科属", ""),
        培育周期=data.get("培育周期"), 温湿范围=data.get("温湿范围", ""),
        描述=data.get("描述", "")
    )
    db.add(c); db.commit(); db.refresh(c)
    return {"ok": True, "品种ID": c.品种ID}

@app.put("/api/crops/{cid}", tags=["作物管理"])
def update_crop(cid: int, data: dict = Body(...), user=Depends(auth_required), db: Session = Depends(get_db)):
    c = db.query(作物品种表).filter(作物品种表.品种ID == cid).first()
    if not c: raise HTTPException(404, "作物不存在")
    for k in ["品种名称", "科属", "培育周期", "温湿范围", "描述"]:
        if k in data and data[k] is not None:
            setattr(c, k, data[k])
    db.commit()
    return {"ok": True}

@app.delete("/api/crops/{cid}", tags=["作物管理"])
def delete_crop(cid: int, user=Depends(auth_required), db: Session = Depends(get_db)):
    c = db.query(作物品种表).filter(作物品种表.品种ID == cid).first()
    if not c: raise HTTPException(404, "作物不存在")
    db.delete(c); db.commit()
    return {"ok": True}

@app.get("/api/batches", tags=["作物管理"])
def list_batches(场地ID: int = None, db: Session = Depends(get_db)):
    q = db.query(培育批次表)
    if 场地ID: q = q.filter(培育批次表.场地ID == 场地ID)
    batches = q.order_by(desc(培育批次表.批次ID)).all()
    return [{
        "批次ID": b.批次ID, "批次名称": b.批次名称, "品种ID": b.品种ID,
        "场地ID": b.场地ID, "种植日期": str(b.种植日期) if b.种植日期 else "",
        "数量": b.数量, "生长状态": b.生长状态,
        "存活率": float(b.存活率) if b.存活率 else None,
        "场地名称": db.query(实训场地表).filter(实训场地表.场地ID == b.场地ID).first().场地名称 if b.场地ID else "",
        "品种名称": db.query(作物品种表).filter(作物品种表.品种ID == b.品种ID).first().品种名称 if b.品种ID else ""
    } for b in batches]

@app.post("/api/batches", tags=["作物管理"])
def create_batch(data: dict = Body(...), user=Depends(auth_required), db: Session = Depends(get_db)):
    b = 培育批次表(
        批次名称=data.get("批次名称", ""), 品种ID=data.get("品种ID"),
        场地ID=data.get("场地ID"), 种植日期=data.get("种植日期"),
        数量=data.get("数量", 0), 生长状态=data.get("生长状态", "播种期"),
        存活率=data.get("存活率"), 记录人ID=user.用户ID, 创建时间=datetime.now()
    )
    db.add(b); db.commit(); db.refresh(b)
    return {"ok": True, "批次ID": b.批次ID}

@app.put("/api/batches/{bid}", tags=["作物管理"])
def update_batch(bid: int, data: dict = Body(...), user=Depends(auth_required), db: Session = Depends(get_db)):
    b = db.query(培育批次表).filter(培育批次表.批次ID == bid).first()
    if not b: raise HTTPException(404, "批次不存在")
    for k in ["批次名称", "品种ID", "场地ID", "种植日期", "数量", "生长状态", "存活率"]:
        if k in data and data[k] is not None:
            setattr(b, k, data[k])
    db.commit()
    return {"ok": True}

@app.delete("/api/batches/{bid}", tags=["作物管理"])
def delete_batch(bid: int, user=Depends(auth_required), db: Session = Depends(get_db)):
    b = db.query(培育批次表).filter(培育批次表.批次ID == bid).first()
    if not b: raise HTTPException(404, "批次不存在")
    db.delete(b); db.commit()
    return {"ok": True}

# ==================== 项目管理 ====================
@app.get("/api/projects", tags=["项目管理"])
def list_projects(db: Session = Depends(get_db)):
    projects = db.query(实训项目表).order_by(desc(实训项目表.项目ID)).all()
    return [{
        "项目ID": p.项目ID, "项目名称": p.项目名称, "项目描述": p.项目描述,
        "场地ID": p.场地ID, "学期ID": p.学期ID,
        "负责教师ID": p.负责教师ID,
        "开始日期": str(p.开始日期) if p.开始日期 else "",
        "结束日期": str(p.结束日期) if p.结束日期 else "",
        "人数上限": p.人数上限, "项目状态": p.项目状态,
        "负责教师": db.query(用户表).filter(用户表.用户ID == p.负责教师ID).first().真实姓名 if p.负责教师ID else "",
        "场地名称": db.query(实训场地表).filter(实训场地表.场地ID == p.场地ID).first().场地名称 if p.场地ID else ""
    } for p in projects]

@app.post("/api/projects", tags=["项目管理"])
def create_project(data: dict = Body(...), user=Depends(auth_required), db: Session = Depends(get_db)):
    p = 实训项目表(
        项目名称=data["项目名称"], 项目描述=data.get("项目描述", ""),
        场地ID=data.get("场地ID"), 学期ID=data.get("学期ID"),
        负责教师ID=data.get("负责教师ID"), 开始日期=data.get("开始日期"),
        结束日期=data.get("结束日期"), 人数上限=data.get("人数上限", 30),
        项目状态=data.get("项目状态", "招募中"), 创建时间=datetime.now()
    )
    db.add(p); db.commit(); db.refresh(p)
    log = 操作日志表(用户ID=user.用户ID, 模块="项目", 操作类型="新增", 目标类型="实训项目表", 目标ID=p.项目ID, 描述=f"新增项目 {p.项目名称}", 操作时间=datetime.now())
    db.add(log); db.commit()
    return {"ok": True, "项目ID": p.项目ID}

@app.put("/api/projects/{pid}", tags=["项目管理"])
def update_project(pid: int, data: dict = Body(...), user=Depends(auth_required), db: Session = Depends(get_db)):
    p = db.query(实训项目表).filter(实训项目表.项目ID == pid).first()
    if not p: raise HTTPException(404, "项目不存在")
    for k in ["项目名称", "项目描述", "场地ID", "学期ID", "负责教师ID", "开始日期", "结束日期", "人数上限", "项目状态"]:
        if k in data and data[k] is not None:
            setattr(p, k, data[k])
    db.commit()
    return {"ok": True}

@app.delete("/api/projects/{pid}", tags=["项目管理"])
def delete_project(pid: int, user=Depends(auth_required), db: Session = Depends(get_db)):
    sids = [s.场次ID for s in db.query(考勤场次表).filter(考勤场次表.项目ID == pid).all()]
    for sid in sids:
        db.query(签到记录表).filter(签到记录表.场次ID == sid).delete()
    db.query(考勤场次表).filter(考勤场次表.项目ID == pid).delete()
    db.query(学生报名表).filter(学生报名表.项目ID == pid).delete()
    p = db.query(实训项目表).filter(实训项目表.项目ID == pid).first()
    if p:
        name = p.项目名称
        db.delete(p)
        log = 操作日志表(用户ID=user.用户ID, 模块="项目", 操作类型="删除", 目标类型="实训项目表", 目标ID=pid, 描述=f"删除项目 {name}", 操作时间=datetime.now())
        db.add(log); db.commit()
    return {"ok": True}

@app.get("/api/enrollments", tags=["项目管理"])
def list_enrollments(项目ID: int = None, db: Session = Depends(get_db)):
    q = db.query(学生报名表)
    if 项目ID: q = q.filter(学生报名表.项目ID == 项目ID)
    return [{
        "报名ID": e.报名ID, "项目ID": e.项目ID, "学生ID": e.学生ID,
        "报名状态": e.报名状态,
        "报名时间": str(e.报名时间)[:16] if e.报名时间 else "",
        "综合成绩": float(e.综合成绩) if e.综合成绩 else None,
        "学生姓名": db.query(用户表).filter(用户表.用户ID == e.学生ID).first().真实姓名 if e.学生ID else ""
    } for e in q.order_by(desc(学生报名表.报名时间)).all()]

@app.put("/api/enrollments/{eid}", tags=["项目管理"])
def update_enrollment(eid: int, data: dict = Body(...), user=Depends(auth_required), db: Session = Depends(get_db)):
    e = db.query(学生报名表).filter(学生报名表.报名ID == eid).first()
    if not e: raise HTTPException(404, "报名记录不存在")
    if "报名状态" in data: e.报名状态 = data["报名状态"]
    if "综合成绩" in data: e.综合成绩 = data["综合成绩"]
    db.commit()
    return {"ok": True}

# ==================== 器材管理 ====================
@app.get("/api/equipment", tags=["器材管理"])
def list_equipment(db: Session = Depends(get_db)):
    items = db.query(器材档案表).order_by(器材档案表.器材ID).all()
    return [{
        "器材ID": e.器材ID, "器材编号": e.器材编号, "器材名称": e.器材名称,
        "分类ID": e.分类ID, "规格型号": e.规格型号, "单位": e.单位,
        "当前库存": e.当前库存, "最低库存": e.最低库存,
        "单价": float(e.单价) if e.单价 else None,
        "存放位置": e.存放位置,
        "分类名称": db.query(器材分类表).filter(器材分类表.分类ID == e.分类ID).first().分类名称 if e.分类ID else ""
    } for e in items]

@app.post("/api/equipment", tags=["器材管理"])
def create_equipment(data: dict = Body(...), user=Depends(auth_required), db: Session = Depends(get_db)):
    if db.query(器材档案表).filter(器材档案表.器材编号 == data.get("器材编号", "")).first():
        raise HTTPException(400, "器材编号已存在")
    e = 器材档案表(
        器材编号=data.get("器材编号", ""), 器材名称=data["器材名称"],
        分类ID=data.get("分类ID"), 规格型号=data.get("规格型号", ""),
        单位=data.get("单位", "个"), 当前库存=data.get("当前库存", 0),
        最低库存=data.get("最低库存", 5), 单价=data.get("单价"),
        存放位置=data.get("存放位置", "")
    )
    db.add(e); db.commit(); db.refresh(e)
    log = 操作日志表(用户ID=user.用户ID, 模块="器材", 操作类型="新增", 目标类型="器材档案表", 目标ID=e.器材ID, 描述=f"新增器材 {e.器材名称}", 操作时间=datetime.now())
    db.add(log); db.commit()
    return {"ok": True, "器材ID": e.器材ID}

@app.put("/api/equipment/{eid}", tags=["器材管理"])
def update_equipment(eid: int, data: dict = Body(...), user=Depends(auth_required), db: Session = Depends(get_db)):
    e = db.query(器材档案表).filter(器材档案表.器材ID == eid).first()
    if not e: raise HTTPException(404, "器材不存在")
    for k in ["器材编号", "器材名称", "分类ID", "规格型号", "单位", "当前库存", "最低库存", "单价", "存放位置"]:
        if k in data and data[k] is not None:
            setattr(e, k, data[k])
    db.commit()
    return {"ok": True}

@app.delete("/api/equipment/{eid}", tags=["器材管理"])
def delete_equipment(eid: int, user=Depends(auth_required), db: Session = Depends(get_db)):
    db.query(借用记录表).filter(借用记录表.器材ID == eid).delete()
    db.query(消耗记录表).filter(消耗记录表.器材ID == eid).delete()
    e = db.query(器材档案表).filter(器材档案表.器材ID == eid).first()
    if e:
        name = e.器材名称
        db.delete(e)
        log = 操作日志表(用户ID=user.用户ID, 模块="器材", 操作类型="删除", 目标类型="器材档案表", 目标ID=eid, 描述=f"删除器材 {name}", 操作时间=datetime.now())
        db.add(log); db.commit()
    return {"ok": True}

@app.get("/api/equip_cats", tags=["器材管理"])
def list_equip_cats(db: Session = Depends(get_db)):
    return [{"分类ID": c.分类ID, "分类名称": c.分类名称} for c in db.query(器材分类表).order_by(器材分类表.分类ID).all()]

@app.get("/api/borrows", tags=["器材管理"])
def list_borrows(db: Session = Depends(get_db)):
    borrows = db.query(借用记录表).order_by(desc(借用记录表.借用日期)).all()
    return [{
        "借用ID": b.借用ID, "器材ID": b.器材ID, "用户ID": b.用户ID,
        "借用数量": b.借用数量, "借用日期": str(b.借用日期)[:16] if b.借用日期 else "",
        "应还日期": str(b.应还日期)[:16] if b.应还日期 else "",
        "实还日期": str(b.实还日期)[:16] if b.实还日期 else "",
        "借用状态": b.借用状态, "项目ID": b.项目ID,
        "器材名称": db.query(器材档案表).filter(器材档案表.器材ID == b.器材ID).first().器材名称 if b.器材ID else "",
        "用户姓名": db.query(用户表).filter(用户表.用户ID == b.用户ID).first().真实姓名 if b.用户ID else ""
    } for b in borrows]

# ==================== 考勤管理 ====================
@app.get("/api/sessions", tags=["考勤管理"])
def list_sessions(db: Session = Depends(get_db)):
    sessions = db.query(考勤场次表).order_by(desc(考勤场次表.场次日期)).all()
    return [{
        "场次ID": s.场次ID, "项目ID": s.项目ID, "场次日期": str(s.场次日期) if s.场次日期 else "",
        "开始时间": str(s.开始时间) if s.开始时间 else "",
        "结束时间": str(s.结束时间) if s.结束时间 else "",
        "地点": s.地点, "实到人数": s.实到人数, "带队教师ID": s.带队教师ID,
        "项目名称": db.query(实训项目表).filter(实训项目表.项目ID == s.项目ID).first().项目名称 if s.项目ID else ""
    } for s in sessions]

@app.post("/api/sessions", tags=["考勤管理"])
def create_session(data: dict = Body(...), user=Depends(auth_required), db: Session = Depends(get_db)):
    s = 考勤场次表(
        项目ID=data["项目ID"], 场次日期=data["场次日期"],
        开始时间=data["开始时间"], 结束时间=data.get("结束时间"),
        地点=data.get("地点", ""), 带队教师ID=data.get("带队教师ID"),
        创建时间=datetime.now()
    )
    db.add(s); db.commit(); db.refresh(s)
    log = 操作日志表(用户ID=user.用户ID, 模块="考勤", 操作类型="新增", 目标类型="考勤场次表", 目标ID=s.场次ID, 描述=f"发布考勤场次（{s.场次日期}）", 操作时间=datetime.now())
    db.add(log); db.commit()
    return {"ok": True, "场次ID": s.场次ID}

@app.put("/api/sessions/{sid}", tags=["考勤管理"])
def update_session(sid: int, data: dict = Body(...), user=Depends(auth_required), db: Session = Depends(get_db)):
    s = db.query(考勤场次表).filter(考勤场次表.场次ID == sid).first()
    if not s: raise HTTPException(404, "场次不存在")
    for k in ["场次日期", "开始时间", "结束时间", "地点", "带队教师ID"]:
        if k in data and data[k] is not None:
            setattr(s, k, data[k])
    db.commit()
    return {"ok": True}

@app.delete("/api/sessions/{sid}", tags=["考勤管理"])
def delete_session(sid: int, user=Depends(auth_required), db: Session = Depends(get_db)):
    db.query(签到记录表).filter(签到记录表.场次ID == sid).delete()
    s = db.query(考勤场次表).filter(考勤场次表.场次ID == sid).first()
    if s: db.delete(s)
    db.commit()
    return {"ok": True}

@app.get("/api/attendance", tags=["考勤管理"])
def list_attendance(session_id: int = None, db: Session = Depends(get_db)):
    q = db.query(签到记录表)
    if session_id: q = q.filter(签到记录表.场次ID == session_id)
    records = q.order_by(签到记录表.签到ID).all()
    return [{
        "签到ID": a.签到ID, "场次ID": a.场次ID, "学生ID": a.学生ID,
        "签到时间": str(a.签到时间)[:16] if a.签到时间 else "", "签到状态": a.签到状态,
        "学生姓名": db.query(用户表).filter(用户表.用户ID == a.学生ID).first().真实姓名 if a.学生ID else ""
    } for a in records]

@app.get("/api/my_attendance", tags=["考勤管理"])
def my_attendance(user=Depends(auth_required), db: Session = Depends(get_db)):
    """当前用户的所有签到记录（一次请求，避免前端循环 N 次）"""
    records = db.query(签到记录表).filter(签到记录表.学生ID == user.用户ID).order_by(desc(签到记录表.签到时间)).all()
    return [{
        "签到ID": a.签到ID, "场次ID": a.场次ID, "学生ID": a.学生ID,
        "签到时间": str(a.签到时间)[:16] if a.签到时间 else "", "签到状态": a.签到状态,
    } for a in records]

@app.post("/api/attendance/checkin", tags=["考勤管理"])
def checkin(data: dict = Body(...), user=Depends(auth_required), db: Session = Depends(get_db)):
    sid = data.get("学生ID")
    if not sid:
        sno = data.get("学号工号", "")
        su = db.query(用户表).filter(用户表.学号工号 == sno, 用户表.角色ID == 3).first()
        if not su: raise HTTPException(404, "学生不存在或学号工号错误")
        sid = su.用户ID
    session = db.query(考勤场次表).filter(考勤场次表.场次ID == data["场次ID"]).first()
    if not session: raise HTTPException(404, "考勤场次不存在")
    existing = db.query(签到记录表).filter(签到记录表.场次ID == data["场次ID"], 签到记录表.学生ID == sid).first()
    if existing:
        raise HTTPException(400, "已签到，不可重复")
    a = 签到记录表(场次ID=data["场次ID"], 学生ID=sid, 签到时间=datetime.now(), 签到状态="出勤")
    db.add(a); db.flush()
    cnt = db.query(func.count(签到记录表.签到ID)).filter(
        签到记录表.场次ID == data["场次ID"], 签到记录表.签到状态.in_(["出勤", "迟到"])
    ).scalar() or 0
    session.实到人数 = cnt
    db.commit()
    return {"ok": True, "签到ID": a.签到ID}

# ==================== 日志管理 ====================
@app.get("/api/logs", tags=["日志管理"])
def list_logs(模块: str = None, db: Session = Depends(get_db)):
    q = db.query(操作日志表)
    if 模块 and 模块 != "全部": q = q.filter(操作日志表.模块 == 模块)
    logs = q.order_by(desc(操作日志表.操作时间)).limit(200).all()
    return [{
        "日志ID": l.日志ID, "模块": l.模块, "操作类型": l.操作类型,
        "目标类型": l.目标类型, "描述": l.描述,
        "操作时间": str(l.操作时间)[:16] if l.操作时间 else "",
        "用户姓名": db.query(用户表).filter(用户表.用户ID == l.用户ID).first().真实姓名 if l.用户ID else ""
    } for l in logs]

@app.post("/api/logs", tags=["日志管理"])
def create_log(data: dict = Body(...), user=Depends(auth_required), db: Session = Depends(get_db)):
    if user.角色ID != 1:
        raise HTTPException(403, "只有管理员可以手动记录日志")
    log = 操作日志表(
        用户ID=user.用户ID, 模块=data.get("模块", "系统"),
        操作类型=data.get("操作类型", "查询"),
        目标类型=data.get("目标类型", ""), 目标ID=data.get("目标ID"),
        描述=data.get("描述", ""), 操作时间=datetime.now()
    )
    db.add(log); db.commit()
    return {"ok": True}

@app.delete("/api/logs/{lid}", tags=["日志管理"])
def delete_log(lid: int, user=Depends(auth_required), db: Session = Depends(get_db)):
    if user.角色ID != 1:
        raise HTTPException(403, "只有管理员可以删除日志")
    l = db.query(操作日志表).filter(操作日志表.日志ID == lid).first()
    if l: db.delete(l); db.commit()
    return {"ok": True}

@app.delete("/api/logs", tags=["日志管理"])
def delete_logs_batch(模块: str = None, user=Depends(auth_required), db: Session = Depends(get_db)):
    """批量删除日志，支持按模块过滤"""
    if user.角色ID != 1:
        raise HTTPException(403, "只有管理员可以删除日志")
    q = db.query(操作日志表)
    if 模块 and 模块 != "全部":
        q = q.filter(操作日志表.模块 == 模块)
    count = q.delete()
    db.commit()
    log = 操作日志表(用户ID=user.用户ID, 模块="系统", 操作类型="删除", 目标类型="操作日志表", 描述=f"批量删除 {count} 条日志", 操作时间=datetime.now())
    db.add(log); db.commit()
    return {"ok": True, "count": count}

# ==================== 视图接口 ====================
@app.get("/api/views/low_stock", tags=["视图"])
def view_low_stock(db: Session = Depends(get_db)):
    items = db.query(器材档案表).filter(器材档案表.当前库存 <= 器材档案表.最低库存).order_by(器材档案表.当前库存).all()
    return [{
        "器材编号": e.器材编号, "器材名称": e.器材名称,
        "当前库存": e.当前库存, "最低库存": e.最低库存, "单位": e.单位,
        "分类名称": db.query(器材分类表).filter(器材分类表.分类ID == e.分类ID).first().分类名称 if e.分类ID else ""
    } for e in items]

@app.get("/api/views/attendance_stats", tags=["视图"])
def view_attendance_stats(db: Session = Depends(get_db)):
    projects = db.query(实训项目表).all()
    result = []
    for p in projects:
        enrolled = db.query(func.count(学生报名表.报名ID)).filter(学生报名表.项目ID == p.项目ID, 学生报名表.报名状态 == "已通过").scalar() or 0
        sessions = db.query(考勤场次表.场次ID).filter(考勤场次表.项目ID == p.项目ID).all()
        sid_list = [s[0] for s in sessions]
        attended = 0
        if sid_list:
            attended = db.query(func.count(func.distinct(签到记录表.学生ID))).filter(
                签到记录表.场次ID.in_(sid_list), 签到记录表.签到状态.in_(["出勤", "迟到"])
            ).scalar() or 0
        rate = round(attended / enrolled * 100, 1) if enrolled > 0 else 0
        result.append({"项目名称": p.项目名称, "应到人数": enrolled, "实到人数": attended, "出勤率": f"{rate}%"})
    return result

# ==================== 前端静态文件 ====================
FRONTEND_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "frontend")
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse

@app.get("/")
def serve_index():
    return FileResponse(os.path.join(FRONTEND_DIR, "index.html"))

app.mount("/static", StaticFiles(directory=FRONTEND_DIR), name="static")

# ==================== 启动 ====================
if __name__ == "__main__":
    import uvicorn
    print("=" * 60)
    print("  河南农业大学实训管理系统 - 后端服务")
    print("  后端 API:  http://localhost:8000/api")
    print("  前端页面:  双击 frontend/index.html 打开")
    print("  或者访问:  http://localhost:8000")
    print("  API 文档:  http://localhost:8000/docs")
    print("=" * 60)
    uvicorn.run(app, host="0.0.0.0", port=8000, log_level="info")
