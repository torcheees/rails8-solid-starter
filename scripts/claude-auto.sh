#!/bin/bash
# Claude Code 自動応答システム - シェルラッパー

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_SCRIPT="$SCRIPT_DIR/claude_auto.py"

# デフォルト値（改行を含む）
DEFAULT_PROMPT="日本語で、docs/features/ 配下にある実装計画を読み取ってチェックリスト形式で実装をしてください。
ベストプラクティスに沿って実装をしてください。
テストコードやlintなどは完全に全て通るまで実装をつづけてください。"

# ヘルプメッセージ
show_help() {
    cat << EOF
Claude Code 自動応答システム

使い方:
    $0 [オプション]

プリセット:
    --auto          完全自動実装（推奨）
                    初期プロンプト: デフォルトの実装プロンプト
                    間隔: チェック10秒、アイドル60秒

    --aggressive    積極的な自動化（開発中向け）
                    間隔: チェック5秒、アイドル30秒

    --balanced      バランス型（デフォルト）
                    間隔: チェック20秒、アイドル60秒

    --cautious      慎重モード（長時間作業向け）
                    間隔: チェック30秒、アイドル120秒

オプション:
    -p, --prompt TEXT       初期プロンプトを指定
    -i, --interval SEC      選択肢チェック間隔（秒）
    --prompt-interval SEC   自動プロンプト送信間隔（秒）
    -d, --debug            デバッグモードを有効化
    -h, --help             このヘルプを表示

例:
    # 完全自動実装（最も推奨）
    $0 --auto

    # カスタムプロンプトで実行
    $0 -p "テストを実行して修正してください"

    # 積極的な自動化 + デバッグ
    $0 --aggressive --debug

    # 完全カスタマイズ
    $0 -p "実装開始" -i 5 --prompt-interval 30 -d

tmux操作:
    tmux attach -t claude-auto      # Claude画面を見る
    Ctrl+B → D                      # デタッチ
    tmux kill-session -t claude-auto # セッション削除

EOF
}

# Python3 チェック
if ! command -v python3 &> /dev/null; then
    echo "❌ エラー: python3 がインストールされていません"
    exit 1
fi

# tmux チェック
if ! command -v tmux &> /dev/null; then
    echo "❌ エラー: tmux がインストールされていません"
    echo "   インストール: brew install tmux"
    exit 1
fi

# 引数パース
ARGS=()
PRESET=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --auto)
            PRESET="auto"
            shift
            ;;
        --aggressive)
            PRESET="aggressive"
            shift
            ;;
        --balanced)
            PRESET="balanced"
            shift
            ;;
        --cautious)
            PRESET="cautious"
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            ARGS+=("$1")
            shift
            ;;
    esac
done

# プリセット適用
case $PRESET in
    auto)
        echo "🚀 完全自動実装モードで起動"
        exec python3 "$PYTHON_SCRIPT" \
            -p "$DEFAULT_PROMPT" \
            -i 10 \
            --prompt-interval 60 \
            "${ARGS[@]}"
        ;;
    aggressive)
        echo "⚡ 積極的モードで起動"
        exec python3 "$PYTHON_SCRIPT" \
            -p "$DEFAULT_PROMPT" \
            -i 5 \
            --prompt-interval 30 \
            "${ARGS[@]}"
        ;;
    balanced)
        echo "⚖️  バランスモードで起動"
        exec python3 "$PYTHON_SCRIPT" \
            -p "$DEFAULT_PROMPT" \
            "${ARGS[@]}"
        ;;
    cautious)
        echo "🐢 慎重モードで起動"
        exec python3 "$PYTHON_SCRIPT" \
            -p "$DEFAULT_PROMPT" \
            -i 30 \
            --prompt-interval 120 \
            "${ARGS[@]}"
        ;;
    *)
        # プリセットなし - 引数をそのまま渡す
        if [ ${#ARGS[@]} -eq 0 ]; then
            # 引数がない場合はバランスモード
            echo "⚖️  バランスモードで起動（デフォルト）"
            exec python3 "$PYTHON_SCRIPT" -p "$DEFAULT_PROMPT"
        else
            exec python3 "$PYTHON_SCRIPT" "${ARGS[@]}"
        fi
        ;;
esac
