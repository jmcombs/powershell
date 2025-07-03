# Pull Request

## Description

**Summary of Changes**
Provide a clear and concise description of what this PR does.

**Related Issues**
- Fixes #(issue number)
- Closes #(issue number)
- Related to #(issue number)

**Type of Change**
- [ ] 🐛 Bug fix (non-breaking change which fixes an issue)
- [ ] ✨ New feature (non-breaking change which adds functionality)
- [ ] 💥 Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] 📚 Documentation update
- [ ] 🧪 Test improvements
- [ ] 🔧 CI/CD improvements
- [ ] ♻️ Code refactoring (no functional changes)

## Changes Made

**Detailed Description**
Explain the changes in detail. Include:
- What was changed and why
- How the solution works
- Any design decisions made

**Files Modified**
- [ ] `scripts/get-net-pwsh-versions.sh`
- [ ] `Dockerfile`
- [ ] `.github/workflows/ci.yml`
- [ ] `.github/workflows/test.yml`
- [ ] `README.md`
- [ ] `CONTRIBUTING.md`
- [ ] Test files
- [ ] Other: ___________

## Testing

**Test Coverage**
- [ ] Unit tests added/updated
- [ ] Integration tests added/updated
- [ ] Manual testing completed
- [ ] All existing tests pass

**Test Results**
```bash
# Paste test output here
$ bats tests/
✓ test 1
✓ test 2
...
```

**Manual Testing Steps**
1. Step 1
2. Step 2
3. Step 3

**Test Environment**
- OS: [e.g. Ubuntu 22.04]
- Docker version: [e.g. 24.0.7]
- Architecture: [e.g. x64]

## Quality Assurance

**Code Quality**
- [ ] Code follows project style guidelines
- [ ] Scripts pass shellcheck validation
- [ ] No new warnings or errors introduced
- [ ] Code is properly commented

**Security**
- [ ] No sensitive information exposed
- [ ] No new security vulnerabilities introduced
- [ ] Dependencies are up to date and secure

**Performance**
- [ ] No performance regressions
- [ ] Changes are optimized where possible
- [ ] Resource usage is reasonable

## Documentation

**Documentation Updates**
- [ ] README.md updated (if needed)
- [ ] CONTRIBUTING.md updated (if needed)
- [ ] Inline code comments added/updated
- [ ] API documentation updated (if applicable)

**Breaking Changes Documentation**
If this PR introduces breaking changes, describe:
- What breaks
- How to migrate
- Timeline for deprecation (if applicable)

## Deployment

**Deployment Considerations**
- [ ] Changes are backward compatible
- [ ] No database migrations required
- [ ] No configuration changes required
- [ ] CI/CD pipeline updated (if needed)

**Rollback Plan**
If something goes wrong, how can this change be rolled back?

## Screenshots/Logs

**Before/After Comparison**
If applicable, add screenshots or log outputs showing the before and after state.

**Visual Changes**
If this PR affects the user interface or output, include screenshots.

## Checklist

**Pre-submission**
- [ ] I have performed a self-review of my code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding changes to the documentation
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix is effective or that my feature works
- [ ] New and existing unit tests pass locally with my changes

**Testing**
- [ ] I have tested the changes locally
- [ ] I have run the full test suite
- [ ] I have tested on multiple architectures (if applicable)
- [ ] I have tested the Docker container build process

**Documentation**
- [ ] I have updated relevant documentation
- [ ] I have added appropriate comments to the code
- [ ] I have updated the changelog (if applicable)

**Review Ready**
- [ ] This PR is ready for review
- [ ] I have addressed all feedback from previous reviews
- [ ] I have resolved all merge conflicts

## Additional Notes

**Reviewer Notes**
Any specific areas you'd like reviewers to focus on?

**Future Work**
Any follow-up work that should be done in future PRs?

**Dependencies**
Any external dependencies or requirements for this change?

---

**Note**: Please ensure all checkboxes are completed before requesting review. Use the preview tab to verify formatting.
