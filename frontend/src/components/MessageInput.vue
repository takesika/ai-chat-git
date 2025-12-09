<script setup>
import { ref } from 'vue'
import { useChatStore } from '../stores/chat'

const chatStore = useChatStore()
const message = ref('')
const textareaRef = ref(null)

function handleSubmit() {
  if (!message.value.trim() || chatStore.isStreaming) return

  chatStore.sendMessage(message.value)
  message.value = ''

  // Reset textarea height
  if (textareaRef.value) {
    textareaRef.value.style.height = 'auto'
  }
}

function handleKeydown(event) {
  // Submit on Enter (without Shift)
  if (event.key === 'Enter' && !event.shiftKey) {
    event.preventDefault()
    handleSubmit()
  }
}

function autoResize(event) {
  const textarea = event.target
  textarea.style.height = 'auto'
  textarea.style.height = Math.min(textarea.scrollHeight, 200) + 'px'
}
</script>

<template>
  <div class="message-input-container">
    <div class="input-wrapper">
      <textarea
        ref="textareaRef"
        v-model="message"
        class="message-input"
        placeholder="メッセージを入力..."
        rows="1"
        :disabled="chatStore.isStreaming"
        @keydown="handleKeydown"
        @input="autoResize"
      ></textarea>
      <button
        class="send-button"
        :disabled="!message.trim() || chatStore.isStreaming"
        @click="handleSubmit"
      >
        <svg
          xmlns="http://www.w3.org/2000/svg"
          width="20"
          height="20"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
          stroke-linecap="round"
          stroke-linejoin="round"
        >
          <line x1="22" y1="2" x2="11" y2="13"></line>
          <polygon points="22 2 15 22 11 13 2 9 22 2"></polygon>
        </svg>
      </button>
    </div>
    <div class="input-hint">
      Enterで送信 / Shift+Enterで改行
    </div>
  </div>
</template>

<style scoped>
.message-input-container {
  padding: 16px 24px 24px;
  background-color: #16213e;
}

.input-wrapper {
  display: flex;
  gap: 12px;
  align-items: flex-end;
  background-color: #2d2d44;
  border-radius: 12px;
  padding: 12px;
}

.message-input {
  flex: 1;
  background: none;
  border: none;
  color: #e0e0e0;
  font-size: 15px;
  line-height: 1.5;
  resize: none;
  outline: none;
  max-height: 200px;
}

.message-input::placeholder {
  color: #888;
}

.message-input:disabled {
  opacity: 0.6;
}

.send-button {
  width: 40px;
  height: 40px;
  border-radius: 8px;
  background-color: #48bb78;
  border: none;
  color: #fff;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: background-color 0.2s, opacity 0.2s;
  flex-shrink: 0;
}

.send-button:hover:not(:disabled) {
  background-color: #38a169;
}

.send-button:disabled {
  background-color: #4a5568;
  cursor: not-allowed;
  opacity: 0.6;
}

.input-hint {
  text-align: center;
  color: #666;
  font-size: 12px;
  margin-top: 8px;
}
</style>
