DEBUG_DYNAMIC_STRING_VALUE="Hello"

def get_dynamic_string() -> str:
    return DEBUG_DYNAMIC_STRING_VALUE

def set_dynamic_string(value: str) -> None:
    global DEBUG_DYNAMIC_STRING_VALUE
    DEBUG_DYNAMIC_STRING_VALUE = value
