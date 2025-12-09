# AI Chat - プロジェクト仕様書

## プロジェクト概要

汎用AIチャットボットアプリケーション。ユーザーとAIの対話を通じて様々な質問に回答する。

## 技術スタック

### バックエンド
- **言語**: Python 3.11+
- **フレームワーク**: FastAPI
- **AI API**: OpenAI API (GPT-4o)
- **データベース**: MongoDB

### フロントエンド
- **フレームワーク**: Vue.js 3
- **ビルドツール**: Vite
- **スタイリング**: CSS (またはTailwind CSS)

### インフラ
- **デプロイ先**: AWS または GCP
- **コンテナ**: Docker対応推奨

## 機能要件

### コア機能
1. **チャット機能**
   - ユーザーがメッセージを送信し、AIから応答を受け取る
   - ストリーミング応答（リアルタイムで文字が表示される）

2. **会話履歴**
   - 会話履歴をMongoDBに保存
   - 過去の会話を参照可能
   - セッション単位で会話を管理

3. **システムプロンプト設定**
   - AIの性格や振る舞いをカスタマイズ可能
   - デフォルトのシステムプロンプトを設定可能

### 認証
- 認証機能なし（オープンアクセス）

## ディレクトリ構成

```
ai-chat/
├── backend/
│   ├── app/
│   │   ├── __init__.py
│   │   ├── main.py              # FastAPIエントリーポイント
│   │   ├── config.py            # 設定管理
│   │   ├── routers/
│   │   │   ├── __init__.py
│   │   │   └── chat.py          # チャットAPIエンドポイント
│   │   ├── services/
│   │   │   ├── __init__.py
│   │   │   ├── openai_service.py  # OpenAI API連携
│   │   │   └── chat_service.py    # チャットビジネスロジック
│   │   ├── models/
│   │   │   ├── __init__.py
│   │   │   └── chat.py          # データモデル定義
│   │   └── database/
│   │       ├── __init__.py
│   │       └── mongodb.py       # MongoDB接続
│   ├── requirements.txt
│   ├── Dockerfile
│   └── .env.example
├── frontend/
│   ├── src/
│   │   ├── main.js
│   │   ├── App.vue
│   │   ├── components/
│   │   │   ├── ChatWindow.vue   # チャット画面
│   │   │   ├── MessageList.vue  # メッセージ一覧
│   │   │   ├── MessageInput.vue # 入力欄
│   │   │   └── ChatHistory.vue  # 履歴サイドバー
│   │   ├── services/
│   │   │   └── api.js           # APIクライアント
│   │   └── stores/
│   │       └── chat.js          # 状態管理（Pinia）
│   ├── package.json
│   ├── vite.config.js
│   └── Dockerfile
├── docker-compose.yml
├── CLAUDE.md
└── README.md
```

## API設計

### エンドポイント

#### POST /api/chat
メッセージを送信し、AI応答を取得（ストリーミング）

**リクエスト:**
```json
{
  "message": "こんにちは",
  "conversation_id": "optional-conversation-id",
  "system_prompt": "optional-custom-prompt"
}
```

**レスポンス:** Server-Sent Events (SSE) でストリーミング

#### GET /api/conversations
会話履歴一覧を取得

**レスポンス:**
```json
{
  "conversations": [
    {
      "id": "conversation-id",
      "title": "会話タイトル",
      "created_at": "2025-01-01T00:00:00Z",
      "updated_at": "2025-01-01T00:00:00Z"
    }
  ]
}
```

#### GET /api/conversations/{id}
特定の会話の詳細を取得

#### DELETE /api/conversations/{id}
会話を削除

#### PUT /api/settings/system-prompt
システムプロンプトを更新

## データモデル

### Conversation
```python
{
    "_id": ObjectId,
    "title": str,              # 会話タイトル（最初のメッセージから自動生成）
    "messages": [
        {
            "role": "user" | "assistant" | "system",
            "content": str,
            "timestamp": datetime
        }
    ],
    "system_prompt": str,      # この会話で使用するシステムプロンプト
    "created_at": datetime,
    "updated_at": datetime
}
```

## 環境変数

```bash
# OpenAI
OPENAI_API_KEY=sk-xxx

# MongoDB
MONGODB_URI=mongodb://localhost:27017
MONGODB_DATABASE=ai_chat

# アプリケーション
DEFAULT_SYSTEM_PROMPT="あなたは親切なAIアシスタントです。"
DEFAULT_MODEL=gpt-4o
```

## 開発コマンド

### バックエンド
```bash
cd backend
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000
```

### フロントエンド
```bash
cd frontend
npm install
npm run dev
```

### Docker
```bash
docker-compose up -d
```

## コーディング規約

### Python
- フォーマッタ: Black
- リンター: Ruff
- 型ヒント: 必須
- docstring: Google形式

### JavaScript/Vue
- フォーマッタ: Prettier
- リンター: ESLint
- Composition API使用

## 注意事項

- APIキーは絶対にコードにハードコードしない
- `.env`ファイルはgitにコミットしない
- ストリーミング応答にはSSE（Server-Sent Events）を使用
- MongoDBへの接続は非同期（motor）を使用
- エラーハンドリングを適切に実装する
