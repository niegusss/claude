# Spec Workflow Guide

> Standalone guide for projects using the Spec Workflow MCP server.
> Configured via `/setup-project` → "Spec Workflow MCP" option.

---

## What is Spec Workflow?

Spec Workflow is a structured approach to planning and tracking development work. It enforces a sequential process:

```
Requirements → Design → Tasks → Implementation
```

Each stage must be approved before moving to the next, ensuring thorough planning before coding begins.

---

## Getting Started

### 1. Start the Dashboard

After setup, start the Spec Workflow dashboard:

```bash
npx @pimzino/spec-workflow-mcp@latest dashboard
```

This opens a web dashboard (usually at `http://localhost:3000`) where you can:
- View all specs and their status
- Track task progress visually
- Approve/reject specs at each stage

### 2. Creating Specs in Claude Code

When working with Claude Code, the spec workflow tools become available. Here's the typical flow:

**Step 1: Create Requirements Spec**
```
"Create a requirements spec for the user authentication feature"
```
Claude will use the `create_requirements_spec` tool to generate a structured requirements document.

**Step 2: Review and Approve Requirements**
- Review the generated requirements in the dashboard
- Click "Approve" to unlock the Design phase
- Or request changes and regenerate

**Step 3: Create Design Spec**
```
"Create a design spec for the approved authentication requirements"
```
Claude uses `create_design_spec` to generate technical design based on approved requirements.

**Step 4: Review and Approve Design**
- Review architecture, component structure, data models
- Approve to unlock Task creation

**Step 5: Create Tasks**
```
"Break down the authentication design into implementation tasks"
```
Claude uses `create_tasks` to generate actionable development tasks.

---

## Available MCP Tools

Once configured, these tools are available in Claude Code:

| Tool | Purpose |
|------|---------|
| `create_requirements_spec` | Generate requirements document |
| `create_design_spec` | Generate technical design |
| `create_tasks` | Break design into tasks |
| `get_spec_status` | Check current spec status |
| `approve_spec` | Approve a spec stage |
| `update_task_status` | Mark tasks as in-progress/done |
| `list_specs` | List all specs in project |

---

## Example Workflow Session

```
User: "Let's plan the dashboard feature using spec workflow"

Claude: [Uses create_requirements_spec]
"I've created a requirements spec for the dashboard. Key requirements:
- Display list of estimates
- Filter by status
- Search functionality
- Pagination

Please review in the dashboard and approve to proceed with design."

User: "Approved. Now create the design"

Claude: [Uses create_design_spec]
"Design spec created. Architecture:
- DashboardPage component
- EstimateList with virtualization
- FilterBar component
- useEstimates hook with React Query

Please review and approve to generate tasks."

User: "Looks good, approved. Generate tasks"

Claude: [Uses create_tasks]
"Created 8 implementation tasks:
1. Create DashboardPage skeleton
2. Implement EstimateCard component
3. Build FilterBar with status options
...

You can track progress in the dashboard. Ready to start implementation?"
```

---

## Tips for Effective Spec Workflow

1. **Be specific in requests** - The more context you provide, the better the specs
2. **Review carefully** - Don't rush approvals; specs are the foundation
3. **Use the dashboard** - Visual tracking helps maintain overview
4. **Update task status** - Keep tasks current for accurate progress tracking
5. **Iterate if needed** - It's OK to reject and regenerate specs

---

## Troubleshooting

**Dashboard won't start:**
- Check if port 3000 is available
- Try: `npx @pimzino/spec-workflow-mcp@latest dashboard --port 3001`

**Tools not available in Claude:**
- Verify `.mcp.json` is in project root
- Restart Claude Code session
- Check MCP server logs for errors

**Specs not syncing:**
- Ensure dashboard and Claude Code use same project path
- Check file permissions in `.specs/` directory
