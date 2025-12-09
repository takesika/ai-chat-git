<script setup>
import { useChatStore } from '../stores/chat'
import MessageList from './MessageList.vue'
import MessageInput from './MessageInput.vue'

const chatStore = useChatStore()
</script>

<template>
  <div class="chat-window">
    <header class="chat-header">
      <h1>AI Chat</h1>
      <div v-if="chatStore.currentConversation" class="current-conversation">
        {{ chatStore.currentConversation.title || '新しい会話' }}
      </div>
    </header>

    <div class="chat-content">
      <div v-if="chatStore.isLoading" class="loading">
        読み込み中...
      </div>

      <div v-else-if="!chatStore.hasMessages && !chatStore.isStreaming" class="welcome">
        <h2>AIアシスタントへようこそ</h2>
        <p>質問やお手伝いできることがあれば、メッセージを入力してください。</p>
      </div>

      <MessageList v-else />
    </div>

    <div v-if="chatStore.error" class="error-message">
      {{ chatStore.error }}
    </div>

    <MessageInput />
  </div>
</template>

<style scoped>
.chat-window {
  display: flex;
  flex-direction: column;
  height: 100%;
}

.chat-header {
  padding: 16px 24px;
  background-color: #1a1a2e;
  border-bottom: 1px solid #2d2d44;
}

.chat-header h1 {
  color: #e0e0e0;
  font-size: 20px;
  margin: 0;
}

.current-conversation {
  color: #888;
  font-size: 14px;
  margin-top: 4px;
}

.chat-content {
  flex: 1;
  overflow-y: auto;
  padding: 24px;
}

.loading {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100%;
  color: #888;
}

.welcome {
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  height: 100%;
  text-align: center;
  color: #e0e0e0;
}

.welcome h2 {
  font-size: 24px;
  margin-bottom: 12px;
}

.welcome p {
  color: #888;
  font-size: 16px;
}

.error-message {
  padding: 12px 24px;
  background-color: #ff6b6b20;
  color: #ff6b6b;
  font-size: 14px;
}
</style>
