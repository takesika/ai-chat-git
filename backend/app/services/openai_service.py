from typing import AsyncGenerator, List, Optional

from openai import AsyncOpenAI

from app.config import get_settings
from app.models.chat import Message

settings = get_settings()
client = AsyncOpenAI(api_key=settings.openai_api_key)


async def generate_chat_response(
    messages: List[Message],
    system_prompt: Optional[str] = None,
) -> AsyncGenerator[str, None]:
    """Generate streaming chat response from OpenAI."""
    openai_messages = []

    # Add system prompt if provided
    if system_prompt:
        openai_messages.append({"role": "system", "content": system_prompt})

    # Convert messages to OpenAI format
    for msg in messages:
        openai_messages.append({"role": msg.role, "content": msg.content})

    try:
        stream = await client.chat.completions.create(
            model=settings.default_model,
            messages=openai_messages,
            stream=True,
        )

        async for chunk in stream:
            if chunk.choices[0].delta.content:
                yield chunk.choices[0].delta.content

    except Exception as e:
        yield f"[Error: {str(e)}]"


async def generate_title(first_message: str) -> str:
    """Generate a title for the conversation based on the first message."""
    try:
        response = await client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[
                {
                    "role": "system",
                    "content": "ユーザーのメッセージから会話のタイトルを10文字以内で生成してください。タイトルのみを出力してください。",
                },
                {"role": "user", "content": first_message},
            ],
            max_tokens=50,
        )
        return response.choices[0].message.content.strip()
    except Exception:
        return first_message[:20] + "..." if len(first_message) > 20 else first_message
