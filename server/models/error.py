from fastapi import HTTPException

exception_dict = {
    1000: "Invalid input",
    1001: "Invalid token",
    1002: "Invalid user",
    1003: "Invalid password",
    1004: "Invalid email",
    1005: "Invalid phone number",
    1006: "Invalid address",
    1007: "Invalid city",
    1008: "Invalid state",
    1009: "Invalid zip code",
    1011: "Invalid date",
    1012: "Invalid time",
    1013: "Not found",
}

class BusinessException(HTTPException):
    def __init__(self, status_code: int, detail: str = None):
        if detail is None:
            detail = exception_dict.get(status_code, "Unknown error")
        if isinstance(detail, str):
            super().__init__(status_code=status_code, detail=detail)
        self.status_code = status_code
        self.detail = detail