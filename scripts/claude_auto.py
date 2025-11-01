#!/usr/bin/env python3
import subprocess
import time
import re
import sys

class ClaudeAutoResponder:
    def __init__(self, check_interval=20, auto_prompt_interval=60, debug=False, initial_prompt=None):
        self.session_name = "claude-auto"
        self.check_interval = check_interval
        self.auto_prompt_interval = auto_prompt_interval
        self.debug = debug
        self.initial_prompt = initial_prompt
        self.last_response_time = 0
        self.last_prompt_time = 0
        self.auto_prompt_text = """
- 日本語で進めてください
- 引き続き docs/features/ 配下にある実装計画を読み取ってチェックリスト形式で実装をしてください
- ベストプラクティスに沿って実装をしてください
- 実装が完了をしたらチェックリストを更新してください
- テストコードやlintなどは完全に全て通るまで実装をつづけてください
- 定期的にpushしてください
- すべてのチェックリストが完了したら docs/closed/にドキュメントを移動してください"""

    def tmux_cmd(self, cmd):
        """tmuxコマンドを実行"""
        full_cmd = f"tmux {cmd}"
        result = subprocess.run(full_cmd, shell=True, capture_output=True, text=True)
        return result.stdout

    def get_pane_content(self):
        """tmuxペインの内容を取得"""
        return self.tmux_cmd(f"capture-pane -t {self.session_name} -p -S -100")

    def send_keys(self, keys, send_enter=True):
        """tmuxに文字列を送信"""
        # 改行を空白に置換（Claude Codeは複数行を1行として扱う）
        text = keys.replace('\n', ' ')

        self.debug_print(f"Sending text: {text[:100]}..." if len(text) > 100 else f"Sending text: {text}")

        # シングルクォートでエスケープ
        escaped = text.replace("'", "'\"'\"'")

        # テキストを送信（-- でオプション解析を終了）
        self.tmux_cmd(f"send-keys -t {self.session_name} -- '{escaped}'")

        # エンターキーを送信
        if send_enter:
            time.sleep(0.2)  # 少し待ってからエンター
            self.tmux_cmd(f"send-keys -t {self.session_name} C-m")
            self.debug_print("Enter key sent")

    def debug_print(self, message):
        """デバッグメッセージを出力"""
        if self.debug:
            print(f"[DEBUG] {message}")

    def detect_and_respond(self, content):
        """選択肢を検出して応答"""
        # より柔軟なパターンマッチング
        permission_patterns = [
            r'Do you want to',  # "Do you want to proceed?", "Do you want to create", etc.
            r'Would you like to',
            r'Should I',
            r'Continue\?',
            r'Proceed\?',
            r'❯\s*\d+\.',  # 選択肢の矢印記号（❯ 1. Yes）
        ]

        has_permission_prompt = False
        for pattern in permission_patterns:
            if re.search(pattern, content, re.IGNORECASE):
                has_permission_prompt = True
                self.debug_print(f"Permission prompt detected: {pattern}")
                break

        if not has_permission_prompt:
            self.debug_print("No permission prompt found")
            return False

        current_time = time.time()
        if current_time - self.last_response_time < 5:
            self.debug_print("Too soon since last response")
            return False

        # より柔軟な選択肢検出パターン
        # 例: "1. Yes", "❯ 1. Yes", "  1. Yes"
        options = re.findall(r'^\s*[❯►]?\s*(\d+)[\.\)]\s+(.+)$', content, re.MULTILINE)
        option_count = len(options)

        if option_count == 0:
            self.debug_print("No options found in content")
            # デバッグモードの場合、最後の30行を表示
            if self.debug:
                lines = content.split('\n')
                print("=== Last 30 lines of content ===")
                for line in lines[-30:]:
                    print(repr(line))
                print("=== End of content ===")
            return False

        print(f"\n{'='*80}")
        print(f"[検出] {option_count}個の選択肢を発見:")
        for num, text in options:
            marker = "❯" if num == "1" else " "
            print(f"  {marker} {num}. {text.strip()}")
        print(f"{'='*80}")

        if option_count == 2:
            response = '1'
            print(f"[実行] 2択のため → オプション1を選択 (Yes)")
        elif option_count == 3:
            response = '2'
            print(f"[実行] 3択のため → オプション2を選択 (Yes, and don't ask again)")
        else:
            response = '1'
            print(f"[警告] 予期しない選択肢数: {option_count} → デフォルトで1を選択")

        self.send_keys(response)
        self.last_response_time = current_time
        print(f"[送信] '{response}' ✓")
        print(f"{'='*80}\n")
        return True

    def should_send_auto_prompt(self, content):
        """自動プロンプトを送信すべきか判定"""
        current_time = time.time()

        # 最後のプロンプト送信から十分な時間が経過しているか
        if current_time - self.last_prompt_time < self.auto_prompt_interval:
            idle_time = int(current_time - self.last_prompt_time)
            self.debug_print(f"Not enough time since last prompt ({idle_time}s/{self.auto_prompt_interval}s)")
            return False

        # 最後の応答から十分な時間が経過しているか
        if current_time - self.last_response_time < self.auto_prompt_interval:
            idle_time = int(current_time - self.last_response_time)
            self.debug_print(f"Not enough time since last response ({idle_time}s/{self.auto_prompt_interval}s)")
            return False

        # 許可プロンプトが表示されている場合は送信しない
        permission_patterns = [
            r'Do you want to proceed\?',
            r'Would you like to continue\?',
            r'Should I proceed\?',
            r'Continue\?',
            r'Proceed\?'
        ]

        for pattern in permission_patterns:
            if re.search(pattern, content, re.IGNORECASE):
                self.debug_print(f"Permission prompt detected, not sending auto prompt")
                return False

        # Claude Codeが処理中か確認
        busy_patterns = [
            r'⏺',  # Claude Code tool execution indicator
            r'⎿',  # Tool result indicator
            r'✻',  # Thinking/processing (Herding, Dilly-dallying, Cogitating, etc.)
            r'✢',  # Alternative thinking indicator
            r'✳',  # Alternative thinking indicator
            r'Loading',
            r'Processing',
            r'Thinking',
            r'Working',
            r'Executing',
            r'Building',
            r'Testing',
            r'Compiling',
            r'\.\.\.',  # "..." indicates processing
            r'⠋|⠙|⠹|⠸|⠼|⠴|⠦|⠧|⠇|⠏',  # Spinner characters
            r'esc to interrupt',  # Claude Code processing indicator
        ]

        # busy パターンは最後の20行だけをチェック（過去の履歴を無視）
        lines = content.strip().split('\n')
        recent_content = '\n'.join(lines[-20:]) if len(lines) > 20 else content

        for pattern in busy_patterns:
            if re.search(pattern, recent_content):
                self.debug_print(f"Busy pattern detected: {pattern}")
                return False

        # プロンプト入力待ち状態か確認
        lines = content.strip().split('\n')

        # Claude Codeのプロンプト行を探す（">" で始まる行）
        prompt_line_found = False
        for line in reversed(lines[-10:]):  # 最後の10行をチェック
            stripped = line.strip()
            # ">" だけの行、または "> " で始まる行
            if stripped == '>' or stripped.startswith('> '):
                prompt_line_found = True
                self.debug_print(f"Idle state detected: prompt line found ('{stripped}')")
                break

        if prompt_line_found:
            return True

        # 最後の行をチェック（フォールバック）
        if lines:
            last_line = lines[-1].strip()

            # プロンプト記号のみ、または短い（5文字以下）場合はアイドル
            prompt_indicators = ['>', '❯', '$', '#', ':', '»', '›']
            if last_line in prompt_indicators or len(last_line) <= 5:
                self.debug_print(f"Idle state detected (last line: '{last_line}')")
                return True

            # 完了メッセージを含む場合もアイドル
            completed_indicators = [
                'completed', 'finished', 'done', 'success', 'failed', 'error',
                '完了', '終了', '成功', '失敗', 'エラー', 'すべて', 'all'
            ]
            if any(indicator in last_line.lower() for indicator in completed_indicators):
                self.debug_print(f"Completion indicator detected: '{last_line}'")
                return True

        self.debug_print(f"No idle state detected (last line: '{lines[-1] if lines else 'N/A'}')")
        return False

    def send_auto_prompt(self):
        """自動プロンプトを送信"""
        print(f"\n{'='*80}")
        print(f"[自動実行] アイドル状態を検出")
        print(f"[送信予定]")
        for line in self.auto_prompt_text.split('\n'):
            print(f"  {line}")
        print(f"{'='*80}")

        self.send_keys(self.auto_prompt_text)
        self.last_prompt_time = time.time()
        self.last_response_time = time.time()  # 応答時刻も更新

        print(f"[送信完了] ✓")
        print(f"{'='*80}\n")

    def check_tmux_installed(self):
        """tmuxがインストールされているか確認"""
        result = subprocess.run("which tmux", shell=True, capture_output=True)
        if result.returncode != 0:
            print("❌ エラー: tmuxがインストールされていません")
            print("   インストール: brew install tmux")
            sys.exit(1)

    def wait_for_claude_ready(self, timeout=10):
        """Claude Codeが起動して入力可能になるまで待つ"""
        print("[起動] Claude Codeの起動を待機中...")
        start_time = time.time()

        while time.time() - start_time < timeout:
            content = self.get_pane_content()

            # Claude Codeのプロンプトが表示されているか確認
            # 通常は ">" または "❯" などのプロンプト記号が表示される
            if re.search(r'[>❯]\s*$', content, re.MULTILINE):
                self.debug_print("Claude Code ready (prompt detected)")
                return True

            # "Welcome" や初期化メッセージが表示されていればOK
            if re.search(r'(Welcome|Claude Code|Ready)', content, re.IGNORECASE):
                time.sleep(1)  # 念のため1秒待つ
                self.debug_print("Claude Code ready (welcome message detected)")
                return True

            time.sleep(0.5)

        # タイムアウトしても続行（ベストエフォート）
        print("[警告] Claude Codeの起動確認がタイムアウトしましたが続行します")
        return False

    def start(self):
        # tmux確認
        self.check_tmux_installed()

        # 既存セッションがあれば削除
        self.tmux_cmd(f"kill-session -t {self.session_name} 2>/dev/null")

        print("=" * 80)
        print("🤖 Claude Code 自動応答システム")
        print("=" * 80)
        print(f"📺 tmuxセッション: {self.session_name}")
        print(f"⏱️  選択肢チェック間隔: {self.check_interval}秒")
        print(f"⏱️  自動プロンプト間隔: {self.auto_prompt_interval}秒")
        print(f"🐛 デバッグモード: {'ON' if self.debug else 'OFF'}")
        print(f"📋 応答ルール:")
        print(f"   • 2択 → 1を選択 (Yes)")
        print(f"   • 3択 → 2を選択 (Yes, and don't ask again)")
        print(f"💬 自動プロンプト:")
        print(f"   • アイドル状態が{self.auto_prompt_interval}秒続いた場合")
        print(f"   • 送信内容:")
        for line in self.auto_prompt_text.split('\n'):
            print(f"     {line}")

        if self.initial_prompt:
            print(f"📝 初期プロンプト:")
            for line in self.initial_prompt.split('\n'):
                print(f"     {line}")

        print("=" * 80)
        print()

        # tmuxセッション作成 & Claude Code起動
        print("[起動] tmuxセッションを作成中...")
        self.tmux_cmd(f"new-session -d -s {self.session_name}")

        print("[起動] Claude Codeを起動中...")
        self.send_keys("claude code")

        # Claude Code起動を待つ
        self.wait_for_claude_ready()

        # 初期プロンプトがあれば送信
        if self.initial_prompt:
            print()
            print("[起動] 初期プロンプトを送信中...")
            print(f"[送信内容]")
            for line in self.initial_prompt.split('\n'):
                print(f"  {line}")

            self.send_keys(self.initial_prompt)
            print("[送信完了] ✓")
            print()

        print()
        print("=" * 80)
        print("✅ 自動監視を開始しました")
        print("=" * 80)
        print()
        print("📺 Claude画面を見るには別ターミナルで:")
        print(f"    tmux attach -t {self.session_name}")
        print()
        print("⌨️  デタッチして戻るには:")
        print("    Ctrl+B → D")
        print()
        print("🛑 このスクリプトを停止するには:")
        print("    Ctrl+C")
        print()
        print("=" * 80)
        print()

        print("[起動] 監視を開始します")
        if self.debug:
            print("[デバッグ] デバッグ情報が表示されます")
        print()

        # 初期プロンプト送信時刻を記録
        self.last_prompt_time = time.time()
        self.last_response_time = time.time()

        last_check_time = time.time()

        try:
            while True:
                time.sleep(1)

                current_time = time.time()

                # 定期チェック
                if current_time - last_check_time >= self.check_interval:
                    timestamp = time.strftime('%H:%M:%S')
                    idle_time = int(current_time - max(self.last_prompt_time, self.last_response_time))
                    print(f"[チェック] バッファをスキャン中... ({timestamp}) [アイドル: {idle_time}s]")

                    content = self.get_pane_content()

                    # 選択肢検出
                    if self.detect_and_respond(content):
                        pass
                    # 自動プロンプト送信
                    elif self.should_send_auto_prompt(content):
                        self.send_auto_prompt()

                    last_check_time = current_time

        except KeyboardInterrupt:
            print("\n[中断] ユーザーによる停止")
            print(f"[クリーンナップ] tmuxセッションを削除中...")
            self.tmux_cmd(f"kill-session -t {self.session_name} 2>/dev/null")
            print(f"[完了] クリーンナップ完了 ✓")

if __name__ == '__main__':
    import argparse

    parser = argparse.ArgumentParser(
        description='Claude Code 自動応答システム - docs/features/配下の実装計画を自動実装',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
使用例:
  # デフォルトの自動プロンプトで起動
  %(prog)s

  # カスタム初期プロンプトで起動
  %(prog)s -p "docs/features/を実装してください"

  # 間隔をカスタマイズ
  %(prog)s --interval 10 --prompt-interval 120

  # デバッグモードで実行
  %(prog)s --debug

  # 全てカスタマイズ
  %(prog)s -p "実装を開始してください" -i 5 --prompt-interval 30 -d

応答ルール:
  • "Do you want to proceed?" で2択 → 1を選択 (Yes)
  • "Do you want to proceed?" で3択 → 2を選択 (Yes, and don't ask again)
  • アイドル状態が続いた場合 → 自動プロンプト送信

デフォルト自動プロンプト内容:
  - 日本語で
  - 引き続き docs/features/ 配下にある実装計画を読み取ってチェックリスト形式で実装をしてください
  - ベストプラクティスに沿って実装をしてください
  - テストコードやlintなどは完全に全て通るまで実装をつづけてください

tmux操作:
  tmux attach -t claude-auto            # Claude画面を見る
  Ctrl+B → D                            # デタッチ（戻る）
  tmux kill-session -t claude-auto      # セッション削除
        """
    )
    parser.add_argument('--interval', '-i', type=int, default=20,
                       help='選択肢チェック間隔（秒） (デフォルト: 20)')
    parser.add_argument('--prompt-interval', type=int, default=60,
                       help='自動プロンプト送信間隔（秒） (デフォルト: 60)')
    parser.add_argument('--debug', '-d', action='store_true',
                       help='デバッグモードを有効にする')
    parser.add_argument('--prompt', '-p', type=str, default=None,
                       help='起動時に送信する初期プロンプト（省略時は手動入力待ち）')
    args = parser.parse_args()

    responder = ClaudeAutoResponder(
        check_interval=args.interval,
        auto_prompt_interval=args.prompt_interval,
        debug=args.debug,
        initial_prompt=args.prompt
    )

    responder.start()
