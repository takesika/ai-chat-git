from datetime import datetime
from typing import List, Optional

from bson import ObjectId

from app.config import get_settings
from app.database.mongodb import get_database
from app.models.chat import Conversation, Message, ConversationResponse

settings = get_settings()


async def create_conversation(
    system_prompt: Optional[str] = None,
) -> str:
    """Create a new conversation and return its ID."""
    db = get_database()
    conversation = {
        "title": "",
        "messages": [],
        "system_prompt": system_prompt or settings.default_system_prompt,
        "created_at": datetime.utcnow(),
        "updated_at": datetime.utcnow(),
    }
    result = await db.conversations.insert_one(conversation)
    return str(result.inserted_id)


async def get_conversation(conversation_id: str) -> Optional[Conversation]:
    """Get a conversation by ID."""
    db = get_database()
    try:
        doc = await db.conversations.find_one({"_id": ObjectId(conversation_id)})
        if doc:
            doc["_id"] = str(doc["_id"])
            return Conversation(**doc)
    except Exception:
        pass
    return None


async def get_conversations() -> List[ConversationResponse]:
    """Get all conversations."""
    db = get_database()
    cursor = db.conversations.find().sort("updated_at", -1)
    conversations = []
    async for doc in cursor:
        conversations.append(
            ConversationResponse(
                id=str(doc["_id"]),
                title=doc.get("title", ""),
                created_at=doc["created_at"],
                updated_at=doc["updated_at"],
            )
        )
    return conversations


async def add_message(
    conversation_id: str,
    role: str,
    content: str,
) -> None:
    """Add a message to a conversation."""
    db = get_database()
    message = {
        "role": role,
        "content": content,
        "timestamp": datetime.utcnow(),
    }
    await db.conversations.update_one(
        {"_id": ObjectId(conversation_id)},
        {
            "$push": {"messages": message},
            "$set": {"updated_at": datetime.utcnow()},
        },
    )


async def update_title(conversation_id: str, title: str) -> None:
    """Update conversation title."""
    db = get_database()
    await db.conversations.update_one(
        {"_id": ObjectId(conversation_id)},
        {"$set": {"title": title}},
    )


async def delete_conversation(conversation_id: str) -> bool:
    """Delete a conversation."""
    db = get_database()
    try:
        result = await db.conversations.delete_one({"_id": ObjectId(conversation_id)})
        return result.deleted_count > 0
    except Exception:
        return False


async def update_system_prompt(conversation_id: str, system_prompt: str) -> bool:
    """Update system prompt for a conversation."""
    db = get_database()
    try:
        result = await db.conversations.update_one(
            {"_id": ObjectId(conversation_id)},
            {"$set": {"system_prompt": system_prompt}},
        )
        return result.modified_count > 0
    except Exception:
        return False
