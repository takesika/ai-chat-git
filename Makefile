.PHONY: init init-backend init-frontend dev dev-backend dev-frontend build build-backend build-frontend deploy stop logs clean help \
        gcp-auth gcp-deploy gcp-deploy-backend gcp-deploy-frontend gcp-logs gcp-delete

# =============================================================================
# 設定
# =============================================================================

GCP_PROJECT_ID := gen-lang-client-0902338213
GCP_REGION := asia-northeast1
BACKEND_SERVICE := ai-chat-backend
FRONTEND_SERVICE := ai-chat-frontend
BACKEND_IMAGE := $(GCP_REGION)-docker.pkg.dev/$(GCP_PROJECT_ID)/ai-chat/backend
FRONTEND_IMAGE := $(GCP_REGION)-docker.pkg.dev/$(GCP_PROJECT_ID)/ai-chat/frontend

# =============================================================================
# 初期化
# =============================================================================

## すべての初期化を実行
init: init-backend init-frontend
	@echo "✅ 初期化完了"

## バックエンドの初期化
init-backend:
	@echo "🔧 バックエンド初期化中..."
	cd backend && python3 -m venv venv
	cd backend && . venv/bin/activate && pip install --upgrade pip && pip install -r requirements.txt
	@if [ ! -f backend/.env ]; then cp backend/.env.example backend/.env; echo "📝 backend/.env を作成しました。OPENAI_API_KEY を設定してください。"; fi

## フロントエンドの初期化
init-frontend:
	@echo "🔧 フロントエンド初期化中..."
	cd frontend && npm install

# =============================================================================
# 開発サーバー起動
# =============================================================================

## バックエンドとフロントエンドの開発サーバーを起動（別ターミナルで実行推奨）
dev:
	@echo "💡 別々のターミナルで 'make dev-backend' と 'make dev-frontend' を実行してください"
	@echo "   または 'make dev-backend &' でバックグラウンド実行後に 'make dev-frontend' を実行"

## バックエンド開発サーバー起動 (http://localhost:8000)
dev-backend:
	@echo "🚀 バックエンド開発サーバー起動中..."
	@echo "   API: http://localhost:8000"
	@echo "   Docs: http://localhost:8000/docs"
	cd backend && . venv/bin/activate && uvicorn app.main:app --reload --port 8000

## フロントエンド開発サーバー起動 (http://localhost:5173)
dev-frontend:
	@echo "🚀 フロントエンド開発サーバー起動中..."
	@echo "   URL: http://localhost:5173"
	cd frontend && npm run dev

# =============================================================================
# ビルド
# =============================================================================

## すべてのビルドを実行
build: build-frontend
	@echo "✅ ビルド完了"

## バックエンドの構文チェック
build-backend:
	@echo "🔨 バックエンド構文チェック中..."
	cd backend && . venv/bin/activate && python -c "from app.main import app; print('✅ バックエンド OK')"

## フロントエンドのビルド
build-frontend:
	@echo "🔨 フロントエンドビルド中..."
	cd frontend && npm run build
	@echo "✅ フロントエンド OK (出力: frontend/dist/)"

# =============================================================================
# Docker デプロイ
# =============================================================================

## Docker Composeでデプロイ
deploy:
	@if [ ! -f .env ]; then cp .env.example .env; echo "📝 .env を作成しました。OPENAI_API_KEY を設定してください。"; exit 1; fi
	@echo "🐳 Docker Compose でデプロイ中..."
	docker compose up -d --build
	@echo ""
	@echo "✅ デプロイ完了"
	@echo "   フロントエンド: http://localhost:3000"
	@echo "   バックエンドAPI: http://localhost:8000"
	@echo "   API Docs: http://localhost:8000/docs"

## Docker Compose停止
stop:
	@echo "🛑 Docker Compose 停止中..."
	docker compose down

## Dockerログ表示
logs:
	docker compose logs -f

## Docker個別ログ表示
logs-backend:
	docker compose logs -f backend

logs-frontend:
	docker compose logs -f frontend

logs-mongodb:
	docker compose logs -f mongodb

# =============================================================================
# Google Cloud Run デプロイ
# =============================================================================

## GCP認証・初期設定
gcp-auth:
	@echo "🔐 GCP認証・設定中..."
	gcloud auth login
	gcloud config set project $(GCP_PROJECT_ID)
	gcloud config set run/region $(GCP_REGION)
	@echo "📦 Artifact Registry リポジトリ作成中..."
	-gcloud artifacts repositories create ai-chat \
		--repository-format=docker \
		--location=$(GCP_REGION) \
		--description="AI Chat Docker images"
	gcloud auth configure-docker $(GCP_REGION)-docker.pkg.dev
	@echo "✅ GCP設定完了"

## Cloud Runに全サービスをデプロイ
gcp-deploy: gcp-deploy-backend gcp-deploy-frontend
	@echo ""
	@echo "✅ Cloud Run デプロイ完了"
	@echo ""
	@echo "📋 サービスURL確認:"
	@gcloud run services describe $(BACKEND_SERVICE) --format='value(status.url)' 2>/dev/null || echo "   Backend: デプロイ中..."
	@gcloud run services describe $(FRONTEND_SERVICE) --format='value(status.url)' 2>/dev/null || echo "   Frontend: デプロイ中..."
	@echo ""
	@echo "⚠️  注意: MongoDBはCloud Runでは動作しません。"
	@echo "   MongoDB Atlas等の外部サービスを使用し、MONGODB_URI環境変数を設定してください。"

## バックエンドをCloud Runにデプロイ
gcp-deploy-backend:
	@echo "🚀 バックエンドをCloud Runにデプロイ中..."
	@echo "   イメージビルド・プッシュ..."
	gcloud builds submit ./backend \
		--tag $(BACKEND_IMAGE):latest \
		--project $(GCP_PROJECT_ID)
	@echo "   Cloud Runにデプロイ..."
	gcloud run deploy $(BACKEND_SERVICE) \
		--image $(BACKEND_IMAGE):latest \
		--platform managed \
		--region $(GCP_REGION) \
		--allow-unauthenticated \
		--set-env-vars "MONGODB_URI=$${MONGODB_URI:-mongodb://localhost:27017}" \
		--set-env-vars "MONGODB_DATABASE=$${MONGODB_DATABASE:-ai_chat}" \
		--set-env-vars "OPENAI_API_KEY=$${OPENAI_API_KEY}" \
		--set-env-vars "DEFAULT_SYSTEM_PROMPT=$${DEFAULT_SYSTEM_PROMPT:-あなたは親切なAIアシスタントです。}" \
		--set-env-vars "DEFAULT_MODEL=$${DEFAULT_MODEL:-gpt-4o}" \
		--memory 512Mi \
		--timeout 300
	@echo "✅ バックエンドデプロイ完了"

## フロントエンドをCloud Runにデプロイ
gcp-deploy-frontend:
	@echo "🚀 フロントエンドをCloud Runにデプロイ中..."
	@# バックエンドURLを取得してビルド時に埋め込む
	$(eval BACKEND_URL := $(shell gcloud run services describe $(BACKEND_SERVICE) --format='value(status.url)' 2>/dev/null))
	@echo "   バックエンドURL: $(BACKEND_URL)"
	@echo "   イメージビルド・プッシュ..."
	gcloud builds submit ./frontend \
		--tag $(FRONTEND_IMAGE):latest \
		--project $(GCP_PROJECT_ID)
	@echo "   Cloud Runにデプロイ..."
	gcloud run deploy $(FRONTEND_SERVICE) \
		--image $(FRONTEND_IMAGE):latest \
		--platform managed \
		--region $(GCP_REGION) \
		--allow-unauthenticated \
		--memory 256Mi \
		--timeout 60
	@echo "✅ フロントエンドデプロイ完了"

## Cloud Runのログを表示
gcp-logs:
	@echo "📋 Cloud Run ログ表示（Ctrl+Cで終了）"
	gcloud run services logs read $(BACKEND_SERVICE) --region $(GCP_REGION) --limit 100

gcp-logs-backend:
	gcloud run services logs read $(BACKEND_SERVICE) --region $(GCP_REGION) --follow

gcp-logs-frontend:
	gcloud run services logs read $(FRONTEND_SERVICE) --region $(GCP_REGION) --follow

## Cloud Runサービスを削除
gcp-delete:
	@echo "🗑️ Cloud Runサービスを削除中..."
	-gcloud run services delete $(BACKEND_SERVICE) --region $(GCP_REGION) --quiet
	-gcloud run services delete $(FRONTEND_SERVICE) --region $(GCP_REGION) --quiet
	@echo "✅ 削除完了"

## Cloud Runサービス一覧
gcp-status:
	@echo "📋 Cloud Run サービス状態"
	@echo ""
	@echo "Backend:"
	@gcloud run services describe $(BACKEND_SERVICE) --region $(GCP_REGION) --format='table(status.url, status.conditions[0].status)' 2>/dev/null || echo "   未デプロイ"
	@echo ""
	@echo "Frontend:"
	@gcloud run services describe $(FRONTEND_SERVICE) --region $(GCP_REGION) --format='table(status.url, status.conditions[0].status)' 2>/dev/null || echo "   未デプロイ"

# =============================================================================
# クリーンアップ
# =============================================================================

## ビルド成果物を削除
clean:
	@echo "🧹 クリーンアップ中..."
	rm -rf frontend/dist
	rm -rf backend/__pycache__ backend/app/__pycache__ backend/app/**/__pycache__
	@echo "✅ クリーンアップ完了"

## すべてを削除（node_modules, venv, Dockerボリューム含む）
clean-all: clean
	@echo "🧹 完全クリーンアップ中..."
	rm -rf frontend/node_modules
	rm -rf backend/venv
	docker compose down -v 2>/dev/null || true
	@echo "✅ 完全クリーンアップ完了"

# =============================================================================
# ヘルプ
# =============================================================================

## ヘルプを表示
help:
	@echo ""
	@echo "AI Chat - Makefile コマンド一覧"
	@echo "================================"
	@echo ""
	@echo "初期化:"
	@echo "  make init            すべての初期化を実行"
	@echo "  make init-backend    バックエンドの初期化"
	@echo "  make init-frontend   フロントエンドの初期化"
	@echo ""
	@echo "開発サーバー:"
	@echo "  make dev-backend     バックエンド開発サーバー起動 (localhost:8000)"
	@echo "  make dev-frontend    フロントエンド開発サーバー起動 (localhost:5173)"
	@echo ""
	@echo "ビルド:"
	@echo "  make build           すべてのビルドを実行"
	@echo "  make build-backend   バックエンドの構文チェック"
	@echo "  make build-frontend  フロントエンドのビルド"
	@echo ""
	@echo "Docker デプロイ（ローカル）:"
	@echo "  make deploy          Docker Composeでデプロイ (localhost:3000)"
	@echo "  make stop            Docker Compose停止"
	@echo "  make logs            Dockerログ表示"
	@echo ""
	@echo "Cloud Run デプロイ（GCP）:"
	@echo "  make gcp-auth        GCP認証・初期設定"
	@echo "  make gcp-deploy      全サービスをCloud Runにデプロイ"
	@echo "  make gcp-deploy-backend   バックエンドのみデプロイ"
	@echo "  make gcp-deploy-frontend  フロントエンドのみデプロイ"
	@echo "  make gcp-status      サービス状態確認"
	@echo "  make gcp-logs        Cloud Runログ表示"
	@echo "  make gcp-delete      Cloud Runサービス削除"
	@echo ""
	@echo "クリーンアップ:"
	@echo "  make clean           ビルド成果物を削除"
	@echo "  make clean-all       すべてを削除（node_modules, venv含む）"
	@echo ""
	@echo "GCP設定:"
	@echo "  プロジェクトID: $(GCP_PROJECT_ID)"
	@echo "  リージョン: $(GCP_REGION)"
	@echo ""
