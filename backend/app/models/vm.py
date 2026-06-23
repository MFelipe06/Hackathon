from pydantic import BaseModel
from typing import Optional
from datetime import date

class VMRequest(BaseModel):
    student_name: str
    course_type: str          # linux-admin | dev-web | data-science | cybersecurity
    vm_count: int = 1
    end_date: date
    ssh_public_key: str

class VMResponse(BaseModel):
    status: str               # provisioning | ready | failed
    vm_names: list[str]
    vm_ips: list[str]
    course_type: str
    end_date: str
    message: Optional[str] = None
