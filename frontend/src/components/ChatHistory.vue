<script setup>
import { useChatStore } from '../stores/chat'

const chatStore = useChatStore()

function formatDate(dateString) {
  const date = new Date(dateString)
  return date.toLocaleDateString('ja-JP', {
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  })
}
</script>

<template>
  <div class="chat-history">
    <div class="history-header">
      <h2>会話履歴</h2>
      <button class="new-chat-btn" @click="chatStore.startNewConversation">
        + 新規チャット
      </button>
    </div>

    <div class="conversation-list">
      <div
        v-for="conversation in chatStore.conversations"
        :key="conversation.id"
        class="conversation-item"
        :class="{ active: conversation.id === chatStore.currentConversationId }"
        @click="chatStore.loadConversation(conversation.id)"
      >
        <div class="conversation-title">
          {{ conversation.title || '新しい会話' }}
        </div>
        <div class="conversation-meta">
          <span class="conversation-date">{{ formatDate(conversation.updated_at) }}</span>
          <button
            class="delete-btn"
            @click.stop="chatStore.deleteConversation(conversation.id)"
            title="削除"
          >
            ×
          </button>
        </div>
      </div>

      <div v-if="chatStore.conversations.length === 0" class="no-conversations">
        会話履歴がありません
      </div>
    </div>
  </div>
</template>

<style scoped>
.chat-history {
  display: flex;
  flex-direction: column;
  height: 100%;
  padding: 16px;
}

.history-header {
  margin-bottom: 16px;
}

.history-header h2 {
  color: #e0e0e0;
  font-size: 14px;
  margin: 0 0 12px 0;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.new-chat-btn {
  width: 100%;
  padding: 12px;
  background-color: #4a5568;
  color: #fff;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-size: 14px;
  transition: background-color 0.2s;
}

.new-chat-btn:hover {
  background-color: #5a6578;
}

.conversation-list {
  flex: 1;
  overflow-y: auto;
}

.conversation-item {
  padding: 12px;
  margin-bottom: 8px;
  background-color: #2d2d44;
  border-radius: 8px;
  cursor: pointer;
  transition: background-color 0.2s;
}

.conversation-item:hover {
  background-color: #3d3d54;
}

.conversation-item.active {
  background-color: #4a5568;
}

.conversation-title {
  color: #e0e0e0;
  font-size: 14px;
  margin-bottom: 4px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.conversation-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.conversation-date {
  color: #888;
  font-size: 12px;
}

.delete-btn {
  background: none;
  border: none;
  color: #888;
  cursor: pointer;
  font-size: 16px;
  padding: 2px 6px;
  border-radius: 4px;
  opacity: 0;
  transition: opacity 0.2s, color 0.2s;
}

.conversation-item:hover .delete-btn {
  opacity: 1;
}

.delete-btn:hover {
  color: #ff6b6b;
}

.no-conversations {
  color: #888;
  text-align: center;
  padding: 20px;
  font-size: 14px;
}
</style>
