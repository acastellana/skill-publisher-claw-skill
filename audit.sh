#!/bin/bash
#
# Skill Audit Script
# Run before publishing any skill to verify it's ready for release.
#
# Usage: ./audit.sh [skill-directory]
#

set -e

SKILL_DIR="${1:-.}"
cd "$SKILL_DIR"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ERRORS=0
WARNINGS=0

pass() { echo -e "${GREEN}✓${NC} $1"; }
fail() { echo -e "${RED}✗${NC} $1"; ((ERRORS++)); }
warn() { echo -e "${YELLOW}⚠${NC} $1"; ((WARNINGS++)); }

echo ""
echo "🔍 Auditing skill: $(basename "$(pwd)")"
echo "   Path: $(pwd)"
echo ""

# ============================================
# 1. STRUCTURE
# ============================================
echo "━━━ STRUCTURE ━━━"

[ -f "SKILL.md" ] && pass "SKILL.md exists" || fail "SKILL.md MISSING (required)"
[ -f "README.md" ] && pass "README.md exists" || warn "README.md missing (recommended)"

# Check SKILL.md has required sections
if [ -f "SKILL.md" ]; then
    grep -qi "when to use" SKILL.md && pass "SKILL.md has 'When to Use' section" || warn "SKILL.md missing 'When to Use' section"
fi

echo ""

# ============================================
# 2. SECURITY
# ============================================
echo "━━━ SECURITY ━━━"

# Check for potential secrets
if grep -rniE "(api[_-]?key|secret|password|token|bearer)\s*[=:]\s*['\"]?[a-zA-Z0-9]{8,}" . --include="*.md" 2>/dev/null | grep -v "example\|sample\|your[_-]" > /dev/null; then
    fail "POTENTIAL SECRETS FOUND - review carefully:"
    grep -rniE "(api[_-]?key|secret|password|token|bearer)\s*[=:]\s*['\"]?[a-zA-Z0-9]{8,}" . --include="*.md" 2>/dev/null | grep -v "example\|sample\|your[_-]" | head -5
else
    pass "No obvious secret patterns"
fi

# Check for common API key prefixes
if grep -rniE "(sk-[a-zA-Z0-9]{20,}|pk-[a-zA-Z0-9]{20,}|xai-[a-zA-Z0-9]{20,}|ghp_[a-zA-Z0-9]{20,}|gho_[a-zA-Z0-9]{20,})" . --include="*.md" 2>/dev/null; then
    fail "API KEY PATTERNS FOUND"
else
    pass "No API key patterns (sk-, pk-, xai-, ghp_, gho_)"
fi

# Check for emails
if grep -rniE "[a-zA-Z0-9._%+-]+@(gmail|yahoo|hotmail|proton|outlook)\." . --include="*.md" 2>/dev/null; then
    warn "Personal email addresses found - consider using example.com"
else
    pass "No personal email addresses"
fi

# Check for phone numbers
if grep -rniE "\+?[0-9]{1,3}[-.\s]?[0-9]{3}[-.\s]?[0-9]{3}[-.\s]?[0-9]{4}" . --include="*.md" 2>/dev/null; then
    warn "Phone number patterns found - review for PII"
else
    pass "No phone number patterns"
fi

echo ""

# ============================================
# 3. PORTABILITY
# ============================================
echo "━━━ PORTABILITY ━━━"

# Check for hardcoded home paths
if grep -rniE "\/home\/[a-z]+" . --include="*.md" 2>/dev/null; then
    fail "HARDCODED /home/ PATHS - use relative paths or \$HOME"
else
    pass "No hardcoded /home/ paths"
fi

# Check for macOS paths
if grep -rniE "\/Users\/[a-zA-Z]+" . --include="*.md" 2>/dev/null; then
    fail "HARDCODED /Users/ PATHS - use relative paths or \$HOME"
else
    pass "No hardcoded /Users/ paths"
fi

# Check for Windows paths
if grep -rniE "C:\\\\Users\\\\" . --include="*.md" 2>/dev/null; then
    fail "HARDCODED WINDOWS PATHS"
else
    pass "No hardcoded Windows paths"
fi

echo ""

# ============================================
# 4. QUALITY
# ============================================
echo "━━━ QUALITY ━━━"

# Check for TODOs
TODO_COUNT=$(grep -rniE "(TODO|FIXME|XXX|HACK)" . --include="*.md" 2>/dev/null | wc -l)
if [ "$TODO_COUNT" -gt 0 ]; then
    warn "$TODO_COUNT TODO/FIXME items found - review before publish"
else
    pass "No TODO/FIXME markers"
fi

# Check for placeholder text
if grep -rniE "(lorem ipsum|TBD|placeholder|CHANGEME)" . --include="*.md" 2>/dev/null; then
    fail "PLACEHOLDER TEXT FOUND"
else
    pass "No placeholder text"
fi

# Check for debug statements in code blocks
if grep -rniE "(console\.log|print\(.*debug|debugger;)" . --include="*.md" 2>/dev/null; then
    warn "Debug statements in code examples"
else
    pass "No debug statements"
fi

echo ""

# ============================================
# 5. DOCUMENTATION
# ============================================
echo "━━━ DOCUMENTATION ━━━"

# Check README has key sections
if [ -f "README.md" ]; then
    grep -qi "## " README.md && pass "README.md has sections" || warn "README.md has no sections"
    grep -qiE "(license|licence)" README.md && pass "README.md mentions license" || warn "README.md doesn't mention license"
fi

# Check for broken internal links
BROKEN_LINKS=0
for link in $(grep -oE '\[.*\]\([^)]+\.md\)' ./*.md 2>/dev/null | grep -oE '\([^)]+\.md\)' | tr -d '()'); do
    if [ ! -f "$link" ]; then
        warn "Broken link: $link"
        ((BROKEN_LINKS++))
    fi
done
[ "$BROKEN_LINKS" -eq 0 ] && pass "No broken internal links"

echo ""

# ============================================
# 6. GIT
# ============================================
echo "━━━ GIT ━━━"

[ -d ".git" ] && pass "Git repository initialized" || warn "Not a git repository"
[ -f ".gitignore" ] && pass ".gitignore exists" || warn "No .gitignore file"

# Check for secrets in git history (if git repo)
if [ -d ".git" ]; then
    if git log -p 2>/dev/null | grep -iE "(api[_-]?key|secret|password)\s*[=:]\s*['\"]?[a-zA-Z0-9]{16,}" | head -1 > /dev/null 2>&1; then
        fail "SECRETS MAY EXIST IN GIT HISTORY - review with: git log -p | grep -i secret"
    else
        pass "No obvious secrets in git history"
    fi
fi

echo ""

# ============================================
# 7. METADATA
# ============================================
echo "━━━ METADATA ━━━"

[ -f "LICENSE" ] || [ -f "LICENSE.md" ] || [ -f "LICENSE.txt" ] && pass "License file exists" || warn "No LICENSE file"

echo ""

# ============================================
# SUMMARY
# ============================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $ERRORS -gt 0 ]; then
    echo -e "${RED}✗ FAILED${NC} - $ERRORS error(s), $WARNINGS warning(s)"
    echo "  Fix errors before publishing!"
    exit 1
elif [ $WARNINGS -gt 0 ]; then
    echo -e "${YELLOW}⚠ PASSED WITH WARNINGS${NC} - $WARNINGS warning(s)"
    echo "  Review warnings before publishing."
    exit 0
else
    echo -e "${GREEN}✓ PASSED${NC} - Ready to publish!"
    exit 0
fi
