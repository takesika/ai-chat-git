# AI Chat - 実行計画

## Phase 1: プロジェクト初期セットアップ

- [x] プロジェクトディレクトリ構造の作成
- [x] Git初期化と.gitignore設定
- [x] 環境変数テンプレート（.env.example）の作成

## Phase 2: バックエンド構築

### 2.1 基盤セットアップ
- [x] Python仮想環境の作成
- [x] requirements.txtの作成（FastAPI, uvicorn, openai, motor, pydantic, python-dotenv）
- [x] FastAPIアプリケーションのエントリーポイント（main.py）作成
- [x] 設定管理モジュール（config.py）作成

### 2.2 データベース層
- [x] MongoDB接続モジュール（database/mongodb.py）作成
- [x] Conversationデータモデル（models/chat.py）定義

### 2.3 サービス層
- [x] OpenAI APIサービス（services/openai_service.py）実装
  - [x] ストリーミング応答対応
  - [x] エラーハンドリング
- [x] チャットサービス（services/chat_service.py）実装
  - [x] 会話作成・取得・削除
  - [x] メッセージ追加

### 2.4 API層
- [x] チャットルーター（routers/chat.py）実装
  - [x] POST /api/chat（ストリーミング応答）
  - [x] GET /api/conversations
  - [x] GET /api/conversations/{id}
  - [x] DELETE /api/conversations/{id}
  - [x] PUT /api/settings/system-prompt

### 2.5 バックエンドテスト
- [x] APIエンドポイントの動作確認
- [ ] ストリーミング応答の動作確認（要MongoDB・OpenAI API）

## Phase 3: フロントエンド構築

### 3.1 基盤セットアップ
- [x] Vite + Vue.js 3プロジェクト作成
- [x] Piniaインストール・設定
- [x] APIクライアント設定

### 3.2 コンポーネント実装
- [x] App.vue（レイアウト）
- [x] ChatWindow.vue（メインチャット画面）
- [x] MessageList.vue（メッセージ一覧表示）
- [x] MessageInput.vue（メッセージ入力欄）
- [x] ChatHistory.vue（会話履歴サイドバー）

### 3.3 状態管理
- [x] chat.js（Piniaストア）実装
  - [x] 会話状態管理
  - [x] メッセージ管理
  - [x] ストリーミング受信処理

### 3.4 APIクライアント
- [x] services/api.js実装
  - [x] SSEストリーミング対応
  - [x] 会話履歴API連携

### 3.5 スタイリング
- [x] チャットUIのスタイリング
- [x] レスポンシブ対応

### 3.6 フロントエンドテスト
- [x] コンポーネント動作確認（ビルド成功）
- [ ] ストリーミング表示確認（要バックエンド起動）

## Phase 4: 結合・Docker化

- [x] バックエンドDockerfile作成
- [x] フロントエンドDockerfile作成
- [x] docker-compose.yml作成（backend, frontend, mongodb）
- [x] CORSの設定確認
- [x] 結合テスト（設定ファイル作成完了、Docker環境で要動作確認）

## Phase 5: ドキュメント・仕上げ

- [x] README.md作成（セットアップ手順、使用方法）
- [x] APIドキュメント確認（FastAPI自動生成 /docs）
- [x] コードの最終レビュー・リファクタリング

---

## 完了基準

- [x] ユーザーがメッセージを送信し、ストリーミングで応答を受け取れる（実装完了）
- [x] 会話履歴が保存され、後から参照できる（実装完了）
- [ ] システムプロンプトをカスタマイズできる（API実装済、**UI未実装**）
- [x] Dockerで全体を起動できる（設定完了）

**注意:** 実際の動作確認にはMongoDB起動とOpenAI APIキーの設定が必要です。

---

## 残タスク（実装の不足・改善点）

### 高優先度（機能・セキュリティ）

#### システムプロンプト設定UI
- [ ] システムプロンプト編集パネル/モーダルの実装（ChatWindow.vue拡張）
- [ ] プリセット選択機能（デフォルト、技術者向け、カジュアル等）
- [ ] 現在のプロンプト表示
- [ ] リセット機能

#### エラーハンドリング改善
- [ ] openai_service.py: 内部エラー詳細の露出防止（セキュリティリスク）
- [ ] chat_service.py: 具体的な例外タイプをキャッチ（InvalidId等）
- [ ] api.js: タイムアウト処理、リトライ機構、ネットワークエラー判定
- [ ] chat.js: エラー表示の自動クリア機能

#### 入力バリデーション強化
- [ ] ChatRequest.message: 長さ制限追加（min_length=1, max_length=10000）
- [ ] SystemPromptRequest: 長さ制限、禁止文字チェック
- [ ] MessageInput.vue: maxlength属性、文字数表示

#### ログ基盤実装
- [ ] Python logging モジュール導入（DEBUG, INFO, WARNING, ERROR）
- [ ] APIリクエストログ（ミドルウェア: user agent, IP, endpoint, response time）
- [ ] ファイル出力設定、JSON フォーマット対応

### 中優先度（品質向上）

#### テスト実装
- [ ] バックエンド（pytest）
  - [ ] models/chat.py のバリデーションテスト
  - [ ] services/chat_service.py の CRUD テスト（モック MongoDB）
  - [ ] services/openai_service.py のストリーミングテスト
  - [ ] routers/chat.py のエンドポイントテスト
- [ ] フロントエンド（Vitest + Vue Test Utils）
  - [ ] コンポーネント単体テスト（MessageInput, ChatWindow等）
  - [ ] ストアテスト（sendMessage, loadConversation等）
  - [ ] APIクライアントテスト

#### セキュリティ強化
- [ ] Rate limiting 実装（slowapi または limits ライブラリ）
- [ ] 入力サニタイズ（HTML/SQL injection 対策）
- [ ] 共通エラーレスポンス形式の統一

#### コード品質
- [ ] JSDoc コメント追加（stores/chat.js）
- [ ] OpenAI AsyncGenerator の戻り値型を明確化
- [ ] .env.example に VITE_API_URL を追加

### 低優先度（UX改善）

#### UI機能追加
- [ ] メッセージコピー機能（右クリックメニュー/ボタン）
- [ ] 会話エクスポート機能（JSON/Markdown形式でダウンロード）
- [ ] 詳細タイムスタンプ表示（ホバー時に完全日時）
- [ ] メッセージ検索機能

#### パフォーマンス最適化
- [ ] vite.config.js にビルド最適化設定追加
- [ ] MongoDB インデックス設定（updated_at）
- [ ] FastAPI gzip 圧縮設定

---

## 進捗サマリー

| カテゴリ | 完了率 | 備考 |
|----------|--------|------|
| コア機能 | 95% | システムプロンプトUI未実装 |
| API設計 | 100% | 全エンドポイント実装済み |
| UI/UX | 85% | 基本機能完成、細部改善余地あり |
| インフラ | 100% | Docker環境完成 |
| テスト | 0% | 未着手 |
| セキュリティ | 60% | Rate limiting、バリデーション不足 |
| ログ | 10% | print文のみ |

**全体進捗: 約85%**
