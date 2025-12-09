# AI Chat

OpenAI GPT-4oを使用した汎用AIチャットボットアプリケーション。

## 機能

- リアルタイムストリーミング応答
- 会話履歴の保存・管理
- システムプロンプトのカスタマイズ
- ダークテーマUI

## 技術スタック

| レイヤー | 技術 |
|----------|------|
| フロントエンド | Vue.js 3, Pinia, Vite |
| バックエンド | FastAPI, Python 3.11 |
| データベース | MongoDB |
| AI | OpenAI API (GPT-4o) |
| インフラ | Docker, nginx |

## セットアップ

### 前提条件

- Docker & Docker Compose
- OpenAI APIキー

### Docker で起動（推奨）

```bash
# リポジトリをクローン
git clone <repository-url>
cd ai-chat

# 環境変数を設定
cp .env.example .env
# .env ファイルを編集して OPENAI_API_KEY を設定

# 起動
docker compose up -d

# ブラウザでアクセス
open http://localhost:3000
```

### ローカル開発

#### バックエンド

```bash
cd backend

# 仮想環境を作成・有効化
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# 依存関係をインストール
pip install -r requirements.txt

# 環境変数を設定
cp .env.example .env
# .env ファイルを編集

# MongoDBを起動（別ターミナル）
docker run -d -p 27017:27017 mongo:7

# サーバーを起動
uvicorn app.main:app --reload --port 8000
```

#### フロントエンド

```bash
cd frontend

# 依存関係をインストール
npm install

# 開発サーバーを起動
npm run dev

# ブラウザでアクセス
open http://localhost:5173
```

## API エンドポイント

| メソッド | パス | 説明 |
|----------|------|------|
| POST | `/api/chat` | メッセージ送信（SSEストリーミング） |
| GET | `/api/conversations` | 会話一覧取得 |
| GET | `/api/conversations/{id}` | 会話詳細取得 |
| DELETE | `/api/conversations/{id}` | 会話削除 |
| PUT | `/api/conversations/{id}/system-prompt` | システムプロンプト更新 |
| GET | `/health` | ヘルスチェック |

APIドキュメント: http://localhost:8000/docs (Swagger UI)

## プロジェクト構成

```
ai-chat/
├── backend/
│   ├── app/
│   │   ├── main.py           # FastAPIエントリーポイント
│   │   ├── config.py         # 設定管理
│   │   ├── routers/          # APIルーター
│   │   ├── services/         # ビジネスロジック
│   │   ├── models/           # データモデル
│   │   └── database/         # DB接続
│   ├── requirements.txt
│   └── Dockerfile
├── frontend/
│   ├── src/
│   │   ├── components/       # Vueコンポーネント
│   │   ├── stores/           # Pinia ストア
│   │   └── services/         # APIクライアント
│   ├── package.json
│   └── Dockerfile
├── docker-compose.yml
└── README.md
```

## 環境変数

| 変数名 | 説明 | デフォルト |
|--------|------|------------|
| `OPENAI_API_KEY` | OpenAI APIキー | (必須) |
| `MONGODB_URI` | MongoDB接続URI | `mongodb://localhost:27017` |
| `MONGODB_DATABASE` | データベース名 | `ai_chat` |
| `DEFAULT_SYSTEM_PROMPT` | デフォルトシステムプロンプト | `あなたは親切なAIアシスタントです。` |
| `DEFAULT_MODEL` | 使用するOpenAIモデル | `gpt-4o` |

## 使い方

1. アプリケーションを起動
2. メッセージを入力して送信（Enterキー）
3. AIからのストリーミング応答を確認
4. 左サイドバーで会話履歴を管理

## ライセンス

MIT
