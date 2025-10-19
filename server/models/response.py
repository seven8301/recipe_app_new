from pydantic import BaseModel
from typing import Any, Optional


class ResponseModel(BaseModel):
    code: int
    message: str
    data: Optional[Any] = None

    @staticmethod
    def success_with_data(data: Any, message: str = "success") -> "ResponseModel":
        return ResponseModel(
            code=0,
            message=message,
            data=data
        )

    @staticmethod
    def success_no_data(message: str = "success") -> "ResponseModel":
        return ResponseModel(
            code=0,
            message=message,
            data=None
        )

    @staticmethod
    def common_error(message: str = "error") -> "ResponseModel":
        return ResponseModel(
            code=-1,
            message=message,
            data=None
        )

    @staticmethod
    def server_error(message: str = "error",code:int = -2) -> "ResponseModel":
        return ResponseModel(
            code=code,
            message=message,
            data=None
        )