import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import * as api from '../services/api'

export const useChatStore = defineStore('chat', () => {
  // State
  const conversations = ref([])
  const currentConversationId = ref(null)
  const messages = ref([])
  const isLoading = ref(false)
  const isStreaming = ref(false)
  const streamingMessage = ref('')
  const systemPrompt = ref('')
  const error = ref(null)

  // Getters
  const currentConversation = computed(() => {
    return conversations.value.find(c => c.id === currentConversationId.value)
  })

  const hasMessages = computed(() => messages.value.length > 0)

  // Actions
  async function fetchConversations() {
    try {
      error.value = null
      conversations.value = await api.getConversations()
    } catch (e) {
      error.value = e.message
      console.error('Failed to fetch conversations:', e)
    }
  }

  async function loadConversation(conversationId) {
    try {
      error.value = null
      isLoading.value = true
      const conversation = await api.getConversation(conversationId)
      currentConversationId.value = conversationId
      messages.value = conversation.messages || []
      systemPrompt.value = conversation.system_prompt || ''
    } catch (e) {
      error.value = e.message
      console.error('Failed to load conversation:', e)
    } finally {
      isLoading.value = false
    }
  }

  function startNewConversation() {
    currentConversationId.value = null
    messages.value = []
    streamingMessage.value = ''
    error.value = null
  }

  async function sendMessage(content) {
    if (!content.trim() || isStreaming.value) return

    // Add user message
    messages.value.push({
      role: 'user',
      content: content,
      timestamp: new Date().toISOString(),
    })

    isStreaming.value = true
    streamingMessage.value = ''
    error.value = null

    await api.sendMessage(
      content,
      currentConversationId.value,
      systemPrompt.value || null,
      // onMessage
      (chunk) => {
        streamingMessage.value += chunk
      },
      // onConversationId
      (conversationId) => {
        currentConversationId.value = conversationId
      },
      // onDone
      () => {
        messages.value.push({
          role: 'assistant',
          content: streamingMessage.value,
          timestamp: new Date().toISOString(),
        })
        streamingMessage.value = ''
        isStreaming.value = false
        fetchConversations()
      },
      // onError
      (e) => {
        error.value = e.message
        isStreaming.value = false
        console.error('Failed to send message:', e)
      }
    )
  }

  async function deleteConversation(conversationId) {
    try {
      error.value = null
      await api.deleteConversation(conversationId)
      conversations.value = conversations.value.filter(c => c.id !== conversationId)
      if (currentConversationId.value === conversationId) {
        startNewConversation()
      }
    } catch (e) {
      error.value = e.message
      console.error('Failed to delete conversation:', e)
    }
  }

  async function updateSystemPrompt(prompt) {
    systemPrompt.value = prompt
    if (currentConversationId.value) {
      try {
        await api.updateSystemPrompt(currentConversationId.value, prompt)
      } catch (e) {
        console.error('Failed to update system prompt:', e)
      }
    }
  }

  return {
    // State
    conversations,
    currentConversationId,
    messages,
    isLoading,
    isStreaming,
    streamingMessage,
    systemPrompt,
    error,
    // Getters
    currentConversation,
    hasMessages,
    // Actions
    fetchConversations,
    loadConversation,
    startNewConversation,
    sendMessage,
    deleteConversation,
    updateSystemPrompt,
  }
})
