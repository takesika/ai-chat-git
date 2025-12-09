// Use environment variable or fallback to Cloud Run backend
const API_BASE_URL = import.meta.env.VITE_API_URL || 'https://ai-chat-backend-718923561974.asia-northeast1.run.app/api'

/**
 * Send a chat message and receive streaming response
 * @param {string} message - User message
 * @param {string|null} conversationId - Existing conversation ID
 * @param {string|null} systemPrompt - Custom system prompt
 * @param {function} onMessage - Callback for each message chunk
 * @param {function} onConversationId - Callback when conversation ID is received
 * @param {function} onDone - Callback when streaming is complete
 * @param {function} onError - Callback for errors
 */
export async function sendMessage(
  message,
  conversationId,
  systemPrompt,
  onMessage,
  onConversationId,
  onDone,
  onError
) {
  try {
    const response = await fetch(`${API_BASE_URL}/chat`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        message,
        conversation_id: conversationId,
        system_prompt: systemPrompt,
      }),
    })

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`)
    }

    const reader = response.body.getReader()
    const decoder = new TextDecoder()
    let buffer = ''

    while (true) {
      const { done, value } = await reader.read()
      if (done) break

      buffer += decoder.decode(value, { stream: true })
      const lines = buffer.split('\n')
      buffer = lines.pop() || ''

      for (const line of lines) {
        if (line.startsWith('event:')) {
          const eventType = line.slice(6).trim()
          continue
        }
        if (line.startsWith('data:')) {
          const data = line.slice(5).trim()
          if (!data) continue

          try {
            const parsed = JSON.parse(data)
            if (parsed.conversation_id) {
              onConversationId(parsed.conversation_id)
            } else if (parsed.content) {
              onMessage(parsed.content)
            } else if (parsed.status === 'complete') {
              onDone()
            }
          } catch (e) {
            // Skip invalid JSON
          }
        }
      }
    }
  } catch (error) {
    onError(error)
  }
}

/**
 * Get all conversations
 * @returns {Promise<Array>} List of conversations
 */
export async function getConversations() {
  const response = await fetch(`${API_BASE_URL}/conversations`)
  if (!response.ok) {
    throw new Error(`HTTP error! status: ${response.status}`)
  }
  return response.json()
}

/**
 * Get a specific conversation
 * @param {string} conversationId - Conversation ID
 * @returns {Promise<Object>} Conversation details
 */
export async function getConversation(conversationId) {
  const response = await fetch(`${API_BASE_URL}/conversations/${conversationId}`)
  if (!response.ok) {
    throw new Error(`HTTP error! status: ${response.status}`)
  }
  return response.json()
}

/**
 * Delete a conversation
 * @param {string} conversationId - Conversation ID
 * @returns {Promise<Object>} Delete result
 */
export async function deleteConversation(conversationId) {
  const response = await fetch(`${API_BASE_URL}/conversations/${conversationId}`, {
    method: 'DELETE',
  })
  if (!response.ok) {
    throw new Error(`HTTP error! status: ${response.status}`)
  }
  return response.json()
}

/**
 * Update system prompt for a conversation
 * @param {string} conversationId - Conversation ID
 * @param {string} systemPrompt - New system prompt
 * @returns {Promise<Object>} Update result
 */
export async function updateSystemPrompt(conversationId, systemPrompt) {
  const response = await fetch(
    `${API_BASE_URL}/conversations/${conversationId}/system-prompt`,
    {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ system_prompt: systemPrompt }),
    }
  )
  if (!response.ok) {
    throw new Error(`HTTP error! status: ${response.status}`)
  }
  return response.json()
}
