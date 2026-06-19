import pymysql, sys
sys.stdout.reconfigure(encoding='utf-8')
conn = pymysql.connect(host='localhost', port=3306, user='root', password='123456', db='河南农业大学实训管理系统', charset='utf8mb4')
cur = conn.cursor()

print('=== 所有教师 ===')
cur.execute("SELECT 用户ID, 真实姓名 FROM 用户表 WHERE 角色ID = 2")
for r in cur.fetchall(): print(f'  ID={r[0]} 姓名={r[1]}')

print('\n=== 总学生数 ===')
cur.execute("SELECT COUNT(*) FROM 用户表 WHERE 角色ID = 3")
print(f'  {cur.fetchone()[0]} 人')

print('\n=== 各项目报名已通过人数 ===')
cur.execute("""SELECT e.项目ID, p.项目名称, COUNT(e.学生ID) as 通过人数 
FROM 学生报名表 e JOIN 实训项目表 p ON e.项目ID=p.项目ID 
WHERE e.报名状态='已通过' GROUP BY e.项目ID ORDER BY e.项目ID""")
for r in cur.fetchall(): print(f'  项目{r[0]}({r[1]}): {r[2]}人')

print('\n=== 考勤场次（最近15条）===')
cur.execute("SELECT 场次ID, 项目ID, 场次日期, 开始时间, 结束时间, 地点 FROM 考勤场次表 ORDER BY 场次日期 DESC LIMIT 15")
for r in cur.fetchall(): print(f'  ID={r[0]} 项目={r[1]} 日期={r[2]} {r[3]}~{r[4]} {r[5] or ""}')

print('\n=== 学生报名状态分布 ===')
cur.execute("SELECT 报名状态, COUNT(*) FROM 学生报名表 GROUP BY 报名状态")
for r in cur.fetchall(): print(f'  状态={r[0]}: {r[1]}条')

print('\n=== 哪些学生在哪些项目中没有已通过记录 ===')
# 找出所有有考勤场次的项目
cur.execute("SELECT DISTINCT 项目ID FROM 考勤场次表")
session_project_ids = [r[0] for r in cur.fetchall()]
print(f'  有考勤场次的项目ID: {session_project_ids}')
for pid in session_project_ids:
    cur.execute("SELECT 项目名称 FROM 实训项目表 WHERE 项目ID=%s", (pid,))
    pname = cur.fetchone()[0]
    # 该项目已通过的学生
    cur.execute("SELECT 学生ID FROM 学生报名表 WHERE 项目ID=%s AND 报名状态='已通过'", (pid,))
    approved_sids = [r[0] for r in cur.fetchall()]
    # 总学生
    cur.execute("SELECT 用户ID FROM 用户表 WHERE 角色ID=3 AND 是否启用=1")
    all_students = [r[0] for r in cur.fetchall()]
    missing = set(all_students) - set(approved_sids)
    print(f'  项目{pid}({pname}): 已通过{len(approved_sids)}人, 缺失{len(missing)}人, 缺失学生IDs: {sorted(missing)[:10]}{"..." if len(missing)>10 else ""}')

conn.close()
