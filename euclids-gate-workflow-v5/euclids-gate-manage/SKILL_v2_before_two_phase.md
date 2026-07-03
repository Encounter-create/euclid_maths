---
name: euclids-gate-manage
description: >
  欧几里德之门公众号文章管理系统。负责双系统（自动/手动）调度、文章索引读写、主题确定、文件保存与索引更新。触发场景：写公众号文章、写数学推文、新建文章、修改文章、文章管理。当用户要求撰写或管理数学公众号文章时使用。与 euclids-gate-math-writing（写作模板）和 euclids-gate-agenda（未完成任务）配合使用。
---

# 欧几里德之门 文章管理系统

## 双系统架构

| 系统 | 触发方式 | 行为差异 |
|------|---------|---------|
| 自动系统 | 定时任务每日触发 | 全自动闭环：读索引→跟预告→写作→更新索引 |
| 手动系统 | 当前会话窗口 | 交互式：先问专题方向→写作→更新索引 |

## 索引文件

**路径（固定，跨系统共用）**：
```
C:\Users\wlx\AppData\Roaming\Tencent\Marvis\User\oAN1i2U46IdrQRZXhZd0FRdRn2E0\workspace\conv_19e7ecc2725_70d494d8379c\output\article_index.json
```

### 索引结构

```json
{
  "articles": [
    {
      "id": 1,
      "title": "No1. 文章标题",
      "date": "2026-06-01",
      "category": "组合数论",
      "file": "绝对路径",
      "preview": "预告主题",
      "questions": ["思考题1", "思考题2"],
      "questions_answered": false
    }
  ],
  "agenda": {
    "pending_answers": [
      {"article_id": 1, "title": "文章标题", "question_count": 3}
    ],
    "pending_topics": [
      "网格作图（grid construction）",
      "Lucas 定理"
    ]
  }
}
```

## 手动系统工作流

### 步骤一：询问专题方向

使用 ask_user 工具询问：

> 本期文章有没有大概的专题方向？或者我自由选题？

选项：
- 「我有方向」→ 等待用户输入具体方向
- 「自由选题」→ 自主选题

### 步骤二：确定主题

- 若用户指定方向：按方向写作
- 若用户选择自由选题：参考 agenda.pending_topics 中最早的未完成预告，或按代数→几何→组合→数论轮换选择新主题

### 步骤三：撰写文章

按 euclids-gate-math-writing 规范撰写。**必须使用 write_file 将文章保存为 .md 文件到 output 目录**。文章内容仅通过 yyb-product 卡片在右侧预览区展示，**绝对禁止在聊天对话框中输出文章全文**。不要在文中自动加入往期思考题解答，除非用户明确要求调用 agenda。

### 步骤四：保存与更新索引

- 文件命名格式：`No{id}_主题.md`，保存到 output 目录
- 更新 article_index.json：
  - 追加新文章记录（id 递增、标题、日期、板块、预告、思考题、questions_answered: false）
  - 从 agenda.pending_topics 中移除已完成的预告
  - 将新文章的思考题加入 agenda.pending_answers
  - 将新预告加入 agenda.pending_topics

### 步骤五：产出物声明

在回复末尾使用 yyb-product 卡片声明本次生成的 Markdown 文件产出物。排版由用户手动完成，**绝对禁止打开浏览器或调用 browser agent 进行排版**。

## 自动系统工作流

全自动执行，无用户交互：

1. 读取 article_index.json
2. 取 agenda.pending_topics 中最早未完成的预告主题
3. 若无预告，按代数→几何→组合→数论轮换
4. 撰写文章（不附往期解答）
5. 保存文件并更新索引
6. **绝对禁止打开浏览器或调用 browser agent 进行排版**

## 修改已写文章

当用户要求修改某篇文章时：

1. 从 article_index.json 找到目标文章的文件路径
2. 读取文件内容
3. 将原文件重命名为 `No{id}_主题_v{版本号}.md`（如 `No5_连分式_v1.md`），版本号从 1 开始递增
4. 按用户要求修改内容，保存为新文件（保持原文件名不变，即 `No{id}_主题.md`）
5. 不更新索引（除非标题或预告变更）

**版本保留规则**：每次修改都必须保留旧版本，不得直接覆盖。旧版本文件命名格式为 `No{id}_主题_v{版本号}.md`，版本号按已有旧版本数量递增。

## 文章目录路径

所有文章保存到：
```
C:\Users\wlx\AppData\Roaming\Tencent\Marvis\User\oAN1i2U46IdrQRZXhZd0FRdRn2E0\workspace\conv_19e7ecc2725_70d494d8379c\output
```