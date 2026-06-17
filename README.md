# 河南农业大学实训管理系统 — 全栈项目

## 文件结构

```
前后端/
├── backend/
│   ├── agri_base.sql      # 数据库脚本 (DBeaver 先执行)
│   ├── models.py          # SQLAlchemy ORM 模型
│   ├── schemas.py         # Pydantic 数据校验
│   ├── main.py            # FastAPI 后端 (600+ API)
│   └── requirements.txt   # Python 依赖
├── frontend/
│   └── index.html         # Vue3 单页应用
└── README.md
```

## 启动步骤 (VSCode)

### 1. 导入数据库
- 打开 DBeaver，连接到你的 MySQL
- 打开 `backend/agri_base.sql`
- 按 Alt+X 执行

### 2. 启动后端
在 VSCode 终端中：
```bash
cd D:\数据库课设\output2\前后端\backend
pip install fastapi uvicorn sqlalchemy pymysql pydantic
python main.py
```

### 3. 打开前端
浏览器打开 `frontend/index.html`

## 演示账号

| 角色 | 用户名 | 密码 |
|------|--------|------|
| 管理员 | admin | 123 |
| 教师 | t001 | 123 |
| 学生 | s001 | 123 |

## 技术栈
- 后端: FastAPI + SQLAlchemy + PyMySQL
- 前端: Vue3 + Element Plus + ECharts + Axios
- 数据库: MySQL 8.0 + InnoDB + utf8mb4
- 数据库名: **河南农业大学实训管理系统**
