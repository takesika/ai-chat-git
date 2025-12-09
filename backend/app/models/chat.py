from datetime import datetime
from typing import List, Literal, Optional

from pydantic import BaseModel, Field


class Message(BaseModel):
    """Chat message model."""

    role: Literal["user", "assistant", "system"]
    content: str
    timestamp: datetime = Field(default_factory=datetime.utcnow)


class Conversation(BaseModel):
    """Conversation model."""

    id: Optional[str] = Field(default=None, alias="_id")
    title: str = ""
    messages: List[Message] = Field(default_factory=list)
    system_prompt: str = ""
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        populate_by_name = True


class ChatRequest(BaseModel):
    """Chat request model."""

    message: str
    conversation_id: Optional[str] = None
    system_prompt: Optional[str] = None


class ConversationResponse(BaseModel):
    """Conversation list item response."""

    id: str
    title: str
    created_at: datetime
    updated_at: datetime


class SystemPromptRequest(BaseModel):
    """System prompt update request."""

    system_prompt: str
