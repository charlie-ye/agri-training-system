"""Pydantic schemas for request/response validation."""
from pydantic import BaseModel
from typing import Optional
from datetime import date, datetime

class LoginReq(BaseModel):
    username: str
    password: str

class NoticeCreate(BaseModel):
    标题: str
    内容: str
    发布人ID: Optional[int] = None
    是否置顶: Optional[int] = 0

class VenueCreate(BaseModel):
    场地编号: str
    场地名称: str
    类型ID: Optional[int] = None
    面积平米: Optional[float] = None
    主要用途: Optional[str] = None
    使用状态: Optional[str] = '空闲'
    责任人: Optional[str] = None
    备注: Optional[str] = None

class BookingCreate(BaseModel):
    场地ID: int
    项目ID: Optional[int] = None
    申请人ID: int
    开始时间: datetime
    结束时间: datetime
    预约原因: Optional[str] = None

class BorrowCreate(BaseModel):
    器材ID: int
    用户ID: int
    借用数量: int
    项目ID: Optional[int] = None
    应还日期: Optional[datetime] = None
    借用状态: Optional[str] = '借用中'

class ConsumptionCreate(BaseModel):
    器材ID: int
    项目ID: Optional[int] = None
    消耗数量: int
    消耗日期: date
    记录人ID: Optional[int] = None
    备注: Optional[str] = None

class ReportGrade(BaseModel):
    报告成绩: float
    教师评语: Optional[str] = ''

class LeaveCreate(BaseModel):
    学生ID: int
    项目ID: int
    场次ID: Optional[int] = None
    请假类型: str = '事假'
    请假原因: str
    开始时间: datetime
    结束时间: datetime
