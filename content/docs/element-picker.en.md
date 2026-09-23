---
title: "Picking elements"
linkTitle: "Picking elements"
description: "Select an element on the page and hand the agent the exact one, instead of writing a paragraph describing it."
group: "browser"
weight: 20
---

Describing an element is hard ("the grey button on the left" is rarely unique). Picking is **pointing** instead of **describing**.

## How to use it

1. Open the target page in Chrome.
2. Open the DSH side panel and enter picking mode.
3. Move the cursor over the page; candidate elements highlight.
4. Click to select — the element's details enter the conversation as context.
5. Then say what you want done with that element.

## What gets carried over

What enters the context is not just "a button" but its DOM structure, its visible text and its key attributes — enough for the agent to target **that specific element** rather than guessing a coordinate.

## Where it helps most

| Situation | Why picking wins |
| --- | --- |
| Forms with many fields | no need to describe "the second input on the third row" |
| Dynamically rendered lists | prose is ambiguous; pointing is exact |
| Changing one specific style | the target node is unambiguous |

## Next

- [Browser tools](/en/docs/browser-tools/) — what the agent can do once you have picked.
