---
title: "Sessions and workspaces"
linkTitle: "Sessions and workspaces"
description: "Sessions, workspaces, the composer and trajectories — how DSH is used day to day, and how to open a first conversation."
group: "use"
weight: 10
---

A session is the unit of work in DSH. It holds the conversation history, the tool-call trajectory and its workspace binding.

## Workspaces

A workspace is the directory the agent works in. Pick one when you create a session; file reads, writes and commands all happen inside its scope. One workspace can host many sessions.

## The composer

- **Multi-line**: `Shift` + `Enter` for a newline, `Enter` to send.
- **Attachments**: drag or paste images; they become part of the message.
- **`@@` references**: pull a file or path into the context explicitly.
- **Stop**: interrupt at any point; the trajectory so far is kept.

## Trajectories

Every tool call leaves an expandable trajectory: **the command, the diff and the output** are all there to read back, rather than a bare "done". That is what makes "what did it actually change" a checkable question.

## A good first conversation

Starting with one concrete task beats asking for a whole project:

1. Pick a real workspace (a repository you are working in).
2. Describe the **outcome** you want, not a list of steps.
3. Read the trajectory and check the plan matches your intent.
4. Anything irreversible, it asks first.

## Next

- [Models and permission modes](/en/docs/models-permissions/)
- [Keyboard shortcuts](/en/docs/shortcuts/)
