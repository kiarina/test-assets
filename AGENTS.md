# AGENTS.md

このリポジトリで作業するエージェント向けのガイドラインです。

## 作業前に読むもの

あらゆるタスクを開始する前に、下記を必ず把握してください。
- `README.md`
- `.mise/tasks/`
- `Makefile`

## README の運用

- `README.md` と `README.ja.md` は、言語違いの完全なミラーとして維持してください。
- 対応箇所を見出しで追いやすくするため、`README.ja.md` の `#`, `##`, `###`, `####` などの見出しは `README.md` と同じ英語に必ず一致させてください。

## Shell script の品質

- `.mise/tasks/` 以下のスクリプトを変更したら、`make lint`（ShellCheck）を実行してください。
  CI でも同じ設定で検証します（`--severity=warning` 以上を失敗扱い）。
- macOS に同梱される Bash 3.2 でも動作する必要があるため、`mapfile` など Bash 4 以降の
  機能は使わないでください。意図的に無視する指摘は、理由をコメントに書いたうえで
  `# shellcheck disable=SCxxxx` を付けます。

## Git の運用

- commit message は [Conventional Commits](https://www.conventionalcommits.org/) に従ってください。
- commit message は英語で書いてください。
