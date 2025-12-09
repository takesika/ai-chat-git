<script setup>
import { ref, watch, nextTick } from 'vue'
import { useChatStore } from '../stores/chat'

const chatStore = useChatStore()
const messagesContainer = ref(null)

function scrollToBottom() {
  nextTick(() => {
    if (messagesContainer.value) {
      messagesContainer.value.scrollTop = messagesContainer.value.scrollHeight
    }
  })
}

watch(
  () => chatStore.messages.length,
  () => scrollToBottom()
)

watch(
  () => chatStore.streamingMessage,
  () => scrollToBottom()
)
</script>

<template>
  <div ref="messagesContainer" class="message-list">
    <div
      v-for="(message, index) in chatStore.messages"
      :key="index"
      class="message"
      :class="message.role"
    >
      <div class="message-avatar">
        <span v-if="message.role === 'user'">U</span>
        <span v-else>AI</span>
      </div>
      <div class="message-content">
        <div class="message-role">
          {{ message.role === 'user' ? 'あなた' : 'アシスタント' }}
        </div>
        <div class="message-text">{{ message.content }}</div>
      </div>
    </div>

    <div v-if="chatStore.isStreaming" class="message assistant streaming">
      <div class="message-avatar">
        <span>AI</span>
      </div>
      <div class="message-content">
        <div class="message-role">アシスタント</div>
        <div class="message-text">
          {{ chatStore.streamingMessage }}
          <span class="cursor">▊</span>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.message-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.message {
  display: flex;
  gap: 12px;
  padding: 16px;
  border-radius: 12px;
}

.message.user {
  background-color: #2d2d44;
}

.message.assistant {
  background-color: #1a1a2e;
}

.message-avatar {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 14px;
  font-weight: bold;
  flex-shrink: 0;
}

.message.user .message-avatar {
  background-color: #4a5568;
  color: #e0e0e0;
}

.message.assistant .message-avatar {
  background-color: #48bb78;
  color: #fff;
}

.message-content {
  flex: 1;
  min-width: 0;
}

.message-role {
  font-size: 12px;
  color: #888;
  margin-bottom: 4px;
}

.message-text {
  color: #e0e0e0;
  font-size: 15px;
  line-height: 1.6;
  white-space: pre-wrap;
  word-break: break-word;
}

.streaming .cursor {
  animation: blink 1s infinite;
  color: #48bb78;
}

@keyframes blink {
  0%, 50% {
    opacity: 1;
  }
  51%, 100% {
    opacity: 0;
  }
}
</style>
