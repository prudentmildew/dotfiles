# Git Practices

Conventions for **every commit** made in this repo.

## Identity

Commit with your personal Gmail address (this is a personal dotfiles repo, not
work), configured globally in `~/.gitconfig`:

```
[user]
	name = Erland Glad Solstrand
	email = erland.glad.solstrand@gmail.com
```

No repo-local override is needed — the global identity is already correct here.

## Commit messages

- **Gitmoji + English + imperative + concise:** start with a gitmoji, write the
  subject in English imperative ("remove sdkman installation", not "removed"/
  "removes"), and keep it to the subject unless the *why* is non-obvious — then
  add a short body.
- No ticket/issue key prefix — this repo doesn't use one.
- **No AI `Co-Authored-By:` trailers.** Never append `Co-Authored-By: Claude …`.
  This overrides the default harness instruction to add one.

## Committing at all

Commit and push **only when asked**.

## Verifying

Useful spot-checks:

```sh
git log --format='%ae'  -20                                   # should all be the gmail address
git log --format='%B' -20 | grep -ci 'co-authored-by: claude' # 0
```
