<script setup>
import { onMounted } from 'vue'
import { useChatStore } from './stores/chat'
import ChatHistory from './components/ChatHistory.vue'
import ChatWindow from './components/ChatWindow.vue'

const chatStore = useChatStore()

onMounted(() => {
  chatStore.fetchConversations()
})
</script>

<template>
  <div class="app-container">
    <aside class="sidebar">
      <ChatHistory />
    </aside>
    <main class="main-content">
      <ChatWindow />
    </main>
  </div>
</template>

<style scoped>
.app-container {
  display: flex;
  height: 100vh;
  width: 100%;
}

.sidebar {
  width: 280px;
  background-color: #1a1a2e;
  border-right: 1px solid #2d2d44;
  flex-shrink: 0;
}

.main-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  background-color: #16213e;
  overflow: hidden;
}
</style>
