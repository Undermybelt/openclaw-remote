---
name: actionbook-browser
description: Browser automation with Actionbook - precise DOM selectors without guessing. Use for web scraping, form filling, navigation. 100x token savings vs full HTML.
---

# Actionbook Browser Automation

Precise browser operations with pre-computed DOM selectors.

## Install

```bash
npm install -g @actionbookdev/cli
```

## CLI Location

```bash
/Users/thrill3r/.npm-global/lib/node_modules/@actionbookdev/cli/node_modules/@actionbookdev/cli-darwin-arm64/bin/actionbook
```

## Usage

### Get action manual for a website

```bash
actionbook get-actions <url>
```

Returns JSON with:
- Available actions (click, type, scroll)
- Precise DOM selectors
- Form field names

### Search actions

```bash
actionbook search "<query>" --url <url>
```

## When to Use

- ✅ Web scraping with complex DOM
- ✅ Form filling automation
- ✅ Multi-step navigation
- ✅ Need to save tokens (100x vs full HTML)

## When NOT to Use

- ❌ Simple page fetch (use web_fetch)
- ❌ Already have Playwriter session
- ❌ Site not in Actionbook database

## Integration with OpenClaw

1. Get action manual first
2. Use selectors with Playwriter or browser tool
3. Avoid guessing selectors

## Example

```bash
# Get Airbnb search actions
actionbook get-actions https://airbnb.com

# Use returned selectors in Playwriter
playwriter -s 1 -e "await page.fill('input[data-testid=\"destination\"]', 'Tokyo')"
```

## Benefits

| Traditional | Actionbook |
|-------------|------------|
| Parse full HTML | Pre-computed selectors |
| Guess selectors | Exact DOM paths |
| 50k tokens | 500 tokens |
| Breaks on UI update | Maintained manuals |

## References

- Website: https://actionbook.dev
- GitHub: https://github.com/actionbook/actionbook
