---
name: skill-publisher
description: Create, package, and publish OpenClaw skills to GitHub. One skill = one repo. Follow this for consistent, shareable skills.
---

# Skill Publisher

Standard workflow for creating and publishing OpenClaw skills.

## Skill Structure

```
skill-name/
├── SKILL.md           # Required: Skill definition
├── README.md          # GitHub documentation
├── package.json       # Optional: Dependencies
├── src/               # Optional: Scripts/code
└── examples/          # Optional: Usage examples
```

## SKILL.md Template

```markdown
---
name: skill-name
description: When to use this skill (triggers for AI)
---

# Skill Name

Brief description.

## Install

\`\`\`bash
# Installation command
\`\`\`

## Usage

\`\`\`bash
# Example usage
\`\`\`

## When to Use

- ✅ Scenario 1
- ✅ Scenario 2

## When NOT to Use

- ❌ Anti-pattern 1
- ❌ Anti-pattern 2

## Configuration

Any environment variables or config needed.

## Examples

Real-world usage examples.

## References

- Links to documentation
- Related resources
```

## Publishing Workflow

### 1. Create Skill Locally

```bash
mkdir -p ~/.openclaw/workspace/skills/your-skill
cd ~/.openclaw/workspace/skills/your-skill
# Create SKILL.md
```

### 2. Create GitHub Repo

```bash
# Initialize git
git init
git add SKILL.md
git commit -m "Initial skill"

# Create repo on GitHub (via gh CLI or web)
gh repo create your-skill --public --source=. --push

# Or use existing org
gh repo create openclaw-skills/your-skill --public --source=. --push
```

### 3. Add to ClawHub (Optional)

```bash
npx clawhub publish your-skill
```

## Naming Conventions

| Type | Pattern | Example |
|------|---------|---------|
| Tool wrapper | `tool-name` | `playwriter-skill` |
| Domain | `domain-purpose` | `web-design-guidelines` |
| Pattern | `pattern-name` | `proactive-agent` |
| Integration | `service-skill` | `tavily-search` |

## README.md Template

```markdown
# Skill Name

Brief description for humans.

## Installation

\`\`\`bash
npx clawhub install your-username/skill-name
\`\`\`

## Usage

Describe how to use it.

## Configuration

List any required:
- API keys
- Environment variables
- Dependencies

## Examples

Show real usage.

## License

MIT
```

## Quality Checklist

Before publishing:

- [ ] SKILL.md has frontmatter (name, description)
- [ ] Description is actionable (when to use)
- [ ] Installation steps are clear
- [ ] Examples are provided
- [ ] Anti-patterns are documented
- [ ] No hardcoded secrets
- [ ] README.md exists
- [ ] LICENSE file (MIT recommended)
- [ ] Tested on clean install

## Version Strategy

Use semantic versioning:

| Change | Version |
|--------|---------|
| Breaking change | MAJOR |
| New feature | MINOR |
| Bug fix | PATCH |

Tag releases:
```bash
git tag v1.0.0
git push --tags
gh release create v1.0.0 --title "v1.0.0" --notes "Initial release"
```

## Skill Dependencies

If your skill depends on other skills:

```yaml
# In SKILL.md frontmatter
dependencies:
  - skill: another-skill
    version: ">=1.0.0"
```

## Testing Your Skill

1. **Local test:**
   ```bash
   # Place in ~/.openclaw/skills/
   # Restart OpenClaw
   # Use the skill
   ```

2. **Clean install test:**
   ```bash
   # Remove skill
   # Install from GitHub
   npx clawhub install user/skill
   # Verify works
   ```

## Examples

### Simple Tool Wrapper

```markdown
---
name: jq-json
description: Process JSON with jq. Use for filtering, transforming, extracting JSON data.
---

# jq JSON Processor

Wrapper for jq CLI.

## Install

\`\`\`bash
brew install jq
\`\`\`

## Usage

\`\`\`bash
cat data.json | jq '.users[] | .name'
\`\`\`
```

### Complex Integration

```markdown
---
name: notion-sync
description: Sync OpenClaw memory to Notion. Use for backup and cross-platform access.
dependencies:
  - skill: web-fetch
    version: ">=1.0.0"
---

# Notion Sync

Sync workspace to Notion database.

## Configuration

Set environment variables:
- NOTION_API_KEY
- NOTION_DATABASE_ID

## Usage

\`\`\`bash
notion-sync --memory --skills
\`\`\`
```

## Publishing Checklist

- [ ] Skill works locally
- [ ] Git repo created
- [ ] Pushed to GitHub
- [ ] README is clear
- [ ] License added
- [ ] Release tagged
- [ ] (Optional) Submitted to ClawHub

## Maintenance

Keep skills updated:
- Fix bugs promptly
- Update for OpenClaw version changes
- Respond to issues
- Accept contributions

## References

- ClawHub: https://clawhub.com
- OpenClaw Skills Guide: https://docs.openclaw.ai/skills
- Skill Creator Skill: Use `skill-creator` for guided creation
