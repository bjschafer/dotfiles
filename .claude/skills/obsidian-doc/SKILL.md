---
name: obsidian-doc
description: Use when asked to save, document, or write a note to Obsidian. Use when completing a runbook, design doc, research investigation, or incident report that should be preserved in the Personal vault.
---

# Obsidian Doc

## Overview

Writes documentation directly to the Personal Obsidian vault. Use the Write tool to create or append files — no extra tooling required.

**Vault path:** `/Users/bschafer/Documents/Obsidian/Personal`

## Folder Mapping

| Doc type | Target folder | Naming convention |
|---|---|---|
| Runbook / incident report | `Homelab/Reports/` | `YYYY-MM-DD <Title>.md` |
| Design doc / plan | `Homelab/Guides/` | `YYYY-MM-DD <Title>.md` |
| Research / investigation | `Homelab/Reference/` | `<Topic>.md` or `YYYY-MM-DD <Title>.md` |
| System-specific note | `Homelab/Systems/<System>.md` | Append to existing file if it exists |


Use `<Topic>.md` for evergreen reference material (a stable topic that will be updated over time). Use `YYYY-MM-DD <Title>.md` for time-bound investigations or point-in-time findings.

If content does not fit any category, use `Homelab/Quick Notes/` and confirm placement with the user.

## Frontmatter

Every new file must start with:

```yaml
---
aliases: []
tags:
  - <topic tags inferred from context, e.g. ceph, kubernetes, incident>
  - ai-generated
date created: YYYY-MM-DD
---
```

Appended sections in existing Systems files do not need frontmatter — add a `## YYYY-MM-DD: <Title>` heading instead.

## Process

1. **Infer doc type** from the current session context. Ask if genuinely ambiguous.
2. **Select target** using the folder mapping above.
3. **For system-specific content:** check whether `Homelab/Systems/<System>.md` exists; if so, offer to append rather than create a new file.
4. **Propose and confirm:** state the intended title, target path, and tags before writing. Wait for user confirmation.
5. **Write the file** using the Write tool (or append using Edit if adding to an existing Systems file).
