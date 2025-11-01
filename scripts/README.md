# Claude Code 自動応答システム

Claude Code の実行を**完全自動化**するスクリプト。許可プロンプトに自動応答し、アイドル時に自動的に実装を継続します。

## 🎯 主な機能

1. **完全自動起動**: コマンド1つで Claude Code が起動し、初期プロンプトを送信
2. **許可プロンプト自動応答**: "Do you want to proceed?" に自動で回答
3. **アイドル検出と自動継続**: 一定時間アイドル状態が続いたら自動プロンプト送信
4. **デバッグモード**: 詳細なログで動作を確認

## 📦 必要条件

- Python 3.6+
- tmux

```bash
# macOSの場合
brew install tmux
```

## 🚀 クイックスタート

### 🎯 最も簡単な方法（シェルスクリプト）

```bash
# 完全自動実装モード（最も推奨）
./scripts/claude-auto.sh --auto

# 積極的モード（開発中向け）
./scripts/claude-auto.sh --aggressive

# バランスモード（デフォルト）
./scripts/claude-auto.sh

# 慎重モード（長時間作業向け）
./scripts/claude-auto.sh --cautious
```

### Python スクリプトを直接実行

```bash
# 初期プロンプトを指定して完全自動で実行
python3 scripts/claude_auto.py -p "docs/features/を実装してください"
```

**これだけで：**
1. tmux セッション作成
2. Claude Code 起動
3. 初期プロンプト送信
4. 許可プロンプト自動応答
5. アイドル時の自動継続

すべてが自動化されます！

### より詳細な初期プロンプト

```bash
python3 scripts/claude_auto.py -p "日本語で、docs/features/ 配下にある実装計画を読み取ってチェックリスト形式で実装をしてください。ベストプラクティスに沿って実装をしてください。"
```

## 📋 オプション一覧

| オプション | 短縮形 | デフォルト | 説明 |
|-----------|--------|-----------|------|
| `--prompt` | `-p` | なし | **起動時に送信する初期プロンプト（重要！）** |
| `--interval` | `-i` | 20秒 | 選択肢チェック間隔 |
| `--prompt-interval` | なし | 60秒 | 自動プロンプト送信間隔（アイドル時間） |
| `--debug` | `-d` | OFF | デバッグモードを有効化 |

### 間隔のカスタマイズ

```bash
# 選択肢チェックを10秒ごと、自動プロンプトを120秒後に送信
python3 scripts/claude_auto.py -p "実装開始" -i 10 --prompt-interval 120

# より積極的な設定（5秒ごとチェック、30秒でアイドル判定）
python3 scripts/claude_auto.py -p "実装開始" -i 5 --prompt-interval 30
```

### デバッグモード

```bash
# 詳細なログを表示
python3 scripts/claude_auto.py -p "実装開始" -d
```

## 🎬 実行後の操作

スクリプトは自動的に Claude Code を起動して初期プロンプトを送信します。

### Claude 画面を見る

別のターミナルで以下を実行:

```bash
# セッションに接続
tmux attach -t claude-auto

# デタッチして戻る（Claude画面内で）
Ctrl+B → D
```

### スクリプトを停止

```bash
# 監視を停止（セッションは残る）
Ctrl+C

# セッションを完全に削除
tmux kill-session -t claude-auto
```

## 📝 応答ルール

### 許可プロンプト自動応答

- **2択の場合**: "1" (Yes) を選択
- **3択の場合**: "2" (Yes, and don't ask again) を選択

検出パターン:
- "Do you want to proceed?"
- "Would you like to continue?"
- "Should I proceed?"

### 自動プロンプト送信（デフォルト）

アイドル状態が60秒続いた場合、以下を自動送信:

```
- 日本語で
- 引き続き docs/features/ 配下にある実装計画を読み取ってチェックリスト形式で実装をしてください
- ベストプラクティスに沿って実装をしてください
- テストコードやlintなどは完全に全て通るまで実装をつづけてください
```

## 💡 推奨設定

### 🎯 シェルスクリプト（簡単）

```bash
# 完全自動実装（最も推奨）
./scripts/claude-auto.sh --auto

# 積極的モード + デバッグ
./scripts/claude-auto.sh --aggressive --debug

# カスタムプロンプト
./scripts/claude-auto.sh --auto -p "テストを実行して修正してください"
```

### 🐍 Python スクリプト（詳細制御）

#### 完全自動実装（最も推奨）

```bash
# docs/features/ の実装を完全自動で実行
python3 scripts/claude_auto.py \
  -p "日本語で、docs/features/ 配下にある実装計画を読み取ってチェックリスト形式で実装をしてください。ベストプラクティスに沿って実装をしてください。" \
  -i 10 \
  --prompt-interval 60
```

#### 開発中（積極的）

```bash
# 短い間隔でチェック、早くアイドル検出
python3 scripts/claude_auto.py \
  -p "実装を開始してください" \
  -i 5 \
  --prompt-interval 30
```

#### 通常使用（バランス型）

```bash
python3 scripts/claude_auto.py -p "実装を開始してください"
```

#### 慎重モード（長時間作業向け）

```bash
python3 scripts/claude_auto.py \
  -p "実装を開始してください" \
  -i 30 \
  --prompt-interval 120
```

## 🔍 デバッグ

### デバッグモードで実行

```bash
python3 scripts/claude_auto.py -p "テスト" -d
```

デバッグ出力の例:

```
[DEBUG] Permission prompt detected: r'Do you want to proceed\?'
[DEBUG] Not enough time since last prompt (45s/60s)
[DEBUG] Busy pattern detected: r'\.\.\.'
[DEBUG] Idle state detected (last line: '>')
```

### 許可プロンプトが検出されない場合

デバッグモードで最後の30行が表示されるので、パターンが一致しているか確認できます。

## 🛠️ トラブルシューティング

### tmux がインストールされていない

```bash
brew install tmux
```

### セッションがすでに存在する

スクリプトが自動的に既存セッションを削除します。手動で削除する場合:

```bash
tmux kill-session -t claude-auto
```

### Python のバージョン確認

```bash
python3 --version  # 3.6以上が必要
```

### アイドル検出が機能しない

- `--prompt-interval` を短く設定（例: 30秒）
- デバッグモードで動作を確認
- 最後の行が完結したメッセージになっているか確認

## 📚 ヘルプ

```bash
python3 scripts/claude_auto.py --help
```
