<div align="center">
  <img src="./assets/cc-orchestrator-cli-skill.svg" alt="CC Orchestrator CLI Skill icon" width="120" height="120">
  <h1>CC Orchestrator CLI Skill</h1>
  <p>Claude Code の agent team を CLI から安定して実行し、debug log と teammate 単位の報告まで揃えるためのスキルです。</p>

  <p>
    <img src="https://img.shields.io/badge/skill-Claude%20Code%20CLI-BD3C2B?style=flat-square" alt="Claude Code CLI badge">
    <img src="https://img.shields.io/badge/platform-Windows%20PowerShell-4472C4?style=flat-square" alt="Windows PowerShell badge">
    <img src="https://img.shields.io/badge/license-MIT-2F855A?style=flat-square" alt="MIT license badge">
  </p>

  <p>
    <a href="./README.md">English</a>
  </p>
</div>

## ✨ できること

このリポジトリは、Claude Code を CLI から「本物の agent team モード」で動かすためのルートスキルをまとめたものです。

前提にしている運用は次のとおりです。

- `--agents` ではなく Claude Code 自身に team を作らせる
- 長いプロンプトは引数ではなく stdin で渡す
- `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` を有効にする
- debug log を保存する
- teammate spawn を確認してから team 実行成功と判断する
- 各 teammate が実際に何をしたかを最終報告に含めさせる

## 🚀 クイックスタート

1. シェルから `claude` が使える状態にします。
2. [SKILL.md](./SKILL.md) の運用ルールを確認します。
3. PowerShell helper で prompt を渡して実行します。

```powershell
.\scripts\run-claude-team.ps1 -PromptText @'
Create an agent team in this workspace and build a small static browser app.
- Spawn exactly 3 teammates yourself: coder, designer, reviewer.
- Report what each teammate actually did.
- Clean up the team when done.
'@ -Dangerous
```

実行後は `DEBUG_PATH=...` が出るので、そのログに `spawnInProcessTeammate`、`coder@`、`designer@`、`reviewer@` があるか確認します。

## 🧭 リポジトリ構成

```text
.
|-- SKILL.md
|-- README.md
|-- README.ja.md
|-- LICENSE
|-- agents/
|   `-- openai.yaml
|-- assets/
|   `-- cc-orchestrator-cli-skill.svg
|-- references/
|   `-- prompt-patterns.md
|-- scripts/
|   |-- run-claude-team.ps1
|   `-- validate-skill.ps1
|-- examples/
|   `-- omikuji-app/
`-- .github/
    `-- workflows/
        `-- validate.yml
```

## 🛠️ 含まれているもの

- [SKILL.md](./SKILL.md): スキル本体と実行ルール
- [agents/openai.yaml](./agents/openai.yaml): UI 向けメタデータ
- [references/prompt-patterns.md](./references/prompt-patterns.md): build 用・review 用の prompt テンプレ
- [scripts/run-claude-team.ps1](./scripts/run-claude-team.ps1): team mode を有効にして debug log も残す helper
- [scripts/validate-skill.ps1](./scripts/validate-skill.ps1): CI でも使う検証スクリプト
- [examples/omikuji-app/](./examples/omikuji-app): 実行例として残した生成アプリ

## 🔍 検証方法

ローカルでは次を実行します。

```powershell
.\scripts\validate-skill.ps1
```

GitHub Actions でも同じ検証を [validate.yml](./.github/workflows/validate.yml) で流せるようにしています。

## 🧪 確認済みのこと

この repo では、Claude Code が自分で teammates を spawn した実行ログを元に運用を固めています。

実際に確認した項目は次のとおりです。

- helper script が Claude の応答と debug log path を返すこと
- debug log に `spawnInProcessTeammate` が出ること
- teammate 名がログに出ること
- スキル名とメタデータが一致していること

## ⚠️ 注意点

- Claude Code のインストールと認証はローカル環境で済んでいる前提です。
- `--dangerously-skip-permissions` は必要なときだけ付ける運用を想定しています。
- このリポジトリは docs サイト公開よりも CLI スキル運用の再利用に主眼を置いています。

## 📄 ライセンス

このリポジトリは [MIT License](./LICENSE) で提供します。
