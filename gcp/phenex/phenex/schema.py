"""Schemas

Author: widnyana
Copyright (C) 2024 - wid@widnyana.web.id
"""
from typing import List

from pydantic import BaseModel


class InstanceByZone(BaseModel):
    zone: str
    names: List[str]


class ProjectVM(BaseModel):
    project_id: str
    zones: List[InstanceByZone]


class SpotVMGuard(BaseModel):
    spot_vms: List[ProjectVM]
