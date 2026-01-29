# Skill Publisher

A meta-skill for preparing AI assistant skills for public release.

## Purpose

Before publishing any skill (to GitHub, ClawdHub, or sharing with others), run through this checklist to ensure it's:

- **Reusable** — Works on any machine, no hardcoded paths
- **Clean** — No debug code, proper formatting
- **Well-architected** — Logical structure, clear entry points
- **Tested** — Actually verified to work
- **Documented** — README, SKILL.md, examples
- **Safe** — No secrets, API keys, or personal data exposed
- **Properly committed** — Clean git history, good messages

## Quick Start

```bash
# Run the audit script on a skill directory
./audit.sh /path/to/skill

# Or manually review using SKILL.md checklist
```

## Files

| File | Description |
|------|-------------|
| `SKILL.md` | Complete checklist and detailed guidance |
| `audit.sh` | Automated pre-publish verification script |
| `templates/` | Template files for new skills |

## The Checklist

1. **STRUCTURE** — Required files present, logical organization
2. **SECURITY** — No secrets, keys, PII, or sensitive data
3. **PORTABILITY** — No hardcoded paths, works anywhere
4. **QUALITY** — Clean code, no debug artifacts
5. **DOCS** — README, SKILL.md, examples complete
6. **TESTING** — Verified functionality
7. **GIT** — Clean history, proper .gitignore
8. **METADATA** — License, description, tags

## License

MIT
