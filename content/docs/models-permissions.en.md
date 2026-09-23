---
title: "Models and permission modes"
linkTitle: "Models and permission modes"
description: "Choose the model and the permission level per session: plan, read-only, workspace write, and full access."
group: "use"
weight: 11
---

## Choosing a model

Each session can pick its own model. Models differ in reasoning depth, speed and tool-calling ability — switch per task rather than setting one globally.

## Permission modes

The permission mode decides what the agent **can do**, not merely whether it asks:

| Mode | Allowed | Good for |
| --- | --- | --- |
| Plan | read-only exploration, produce a plan | look before you leap |
| Read-only | read files, search, browse | research and questions |
| Workspace write | edit files and run commands inside the workspace | everyday changes |
| Full access | step outside the workspace, broader system actions | when you know exactly what you want |

## Grant, then take back

Permissions are granted **per session**. Do not enable writes for read-only research, and lower the level when the task is done — that is far safer than leaving full access on.

## Approval points

Even in a high-permission mode, irreversible actions — sending, deleting, buying, publishing — are explained before they run.

## Next

- [Permissions](/en/docs/permissions/) — the default-deny policy for phones and plugins.
- [Auditability](/en/docs/auditability/) — how to review what it did.
