import json
from typing import List

from fastapi import APIRouter, HTTPException
from sse_starlette.sse import EventSourceResponse

from app.models.chat import (
    ChatRequest,
    Conversation,
    ConversationResponse,
    SystemPromptRequest,
)
from app.services import chat_service, openai_service

router = APIRouter()


@router.post("/chat")
async def chat(request: ChatRequest):
    """Send a message and receive streaming response."""
    conversation_id = request.conversation_id

    # Create new conversation if not provided
    if not conversation_id:
        conversation_id = await chat_service.create_conversation(request.system_prompt)

    # Get conversation
    conversation = await chat_service.get_conversation(conversation_id)
    if not conversation:
        raise HTTPException(status_code=404, detail="Conversation not found")

    # Add user message
    await chat_service.add_message(conversation_id, "user", request.message)

    # Generate title if first message
    if not conversation.title:
        title = await openai_service.generate_title(request.message)
        await chat_service.update_title(conversation_id, title)

    # Refresh conversation to get updated messages
    conversation = await chat_service.get_conversation(conversation_id)

    # Determine system prompt
    system_prompt = request.system_prompt or conversation.system_prompt

    async def event_generator():
        full_response = ""

        # Send conversation ID first
        yield {
            "event": "conversation_id",
            "data": json.dumps({"conversation_id": conversation_id}),
        }

        # Stream response
        async for chunk in openai_service.generate_chat_response(
            conversation.messages, system_prompt
        ):
            full_response += chunk
            yield {"event": "message", "data": json.dumps({"content": chunk})}

        # Save assistant message
        await chat_service.add_message(conversation_id, "assistant", full_response)

        # Send done event
        yield {"event": "done", "data": json.dumps({"status": "complete"})}

    return EventSourceResponse(event_generator())


@router.get("/conversations", response_model=List[ConversationResponse])
async def get_conversations():
    """Get all conversations."""
    return await chat_service.get_conversations()


@router.get("/conversations/{conversation_id}")
async def get_conversation(conversation_id: str):
    """Get a specific conversation."""
    conversation = await chat_service.get_conversation(conversation_id)
    if not conversation:
        raise HTTPException(status_code=404, detail="Conversation not found")

    return {
        "id": conversation_id,
        "title": conversation.title,
        "messages": [
            {
                "role": msg.role,
                "content": msg.content,
                "timestamp": msg.timestamp.isoformat(),
            }
            for msg in conversation.messages
        ],
        "system_prompt": conversation.system_prompt,
        "created_at": conversation.created_at.isoformat(),
        "updated_at": conversation.updated_at.isoformat(),
    }


@router.delete("/conversations/{conversation_id}")
async def delete_conversation(conversation_id: str):
    """Delete a conversation."""
    success = await chat_service.delete_conversation(conversation_id)
    if not success:
        raise HTTPException(status_code=404, detail="Conversation not found")
    return {"status": "deleted"}


@router.put("/conversations/{conversation_id}/system-prompt")
async def update_system_prompt(conversation_id: str, request: SystemPromptRequest):
    """Update system prompt for a conversation."""
    success = await chat_service.update_system_prompt(
        conversation_id, request.system_prompt
    )
    if not success:
        raise HTTPException(status_code=404, detail="Conversation not found")
    return {"status": "updated"}
