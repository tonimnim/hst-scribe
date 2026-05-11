# Project-scoped Claude Code skills

Skills placed in this directory are loaded only when Claude Code runs inside `hst-scribe/`. They take precedence over and stay isolated from user-level skills in `~/.claude/skills/`, so HST Scribe specifics don't bleed into other projects.

## Layout

```
.claude/
└── skills/
    └── <skill-name>/
        ├── SKILL.md      # required — frontmatter + body
        └── ...           # any supporting files the skill references
```

Each skill is its own folder with a `SKILL.md`. The frontmatter declares the trigger; the body is the instructions Claude Code follows when the skill fires.

## When to add a skill here

- Repeatable project workflows ("scaffold a new backend service the HST way").
- Project-specific verification (run the eval set, validate a wire change against `contract/`).
- Anything you find yourself re-explaining in every Claude Code session.

Don't park general-purpose skills here — those belong in `~/.claude/skills/`.
