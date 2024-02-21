"""Configuration utils

Author: widnyana
Copyright (C) 2023 - wid@widnyana.web.id
"""
import os
import pathlib
from pathlib import PurePath
from typing import Optional, Union

from loguru import logger
from pydantic_yaml import parse_yaml_raw_as
from ruamel.yaml import YAML

from .schema import SpotVMGuard, ProjectVM, InstanceByZone

CONFIG_NAME = "phenex.autostart-spot-vm.yaml"
WORKING_DIR = os.getcwd()


def load_config(config_file: Optional[str] = None) -> Union[SpotVMGuard, bool]:
    if not config_file:
        config_file = PurePath(WORKING_DIR).joinpath(CONFIG_NAME)

    logger.info(f"trying to load config from {config_file}")
    if not pathlib.Path(config_file).is_file():
        logger.info("config file does not exist. creating sample config file")
        create_config(config_file)
        return False

    with open(config_file, 'r') as f:
        data = f.read()
        config = parse_yaml_raw_as(SpotVMGuard, data)

    return config


def create_config(destination: str):
    """create sample config file"""

    configs = SpotVMGuard(
        spot_vms=[
            ProjectVM(
                project_id="scared-of-commitments-445566",
                zones=[InstanceByZone(zone="asia-southeast2-c", names=["random-vm-name", "random-vm-name-2"])],
            ),
            ProjectVM(
                project_id="incompetent-bastard-112233",
                zones=[
                    InstanceByZone(zone="asia-southeast2-c", names=["random-vm-name"]),
                    InstanceByZone(zone="asia-southeast2-a", names=["random-vm-name"]),
                    InstanceByZone(zone="asia-southeast2-b", names=["random-vm-name"]),
                ],
            ),
        ]
    )

    y = YAML()
    with open(destination, 'w') as f:
        y.dump(configs.dict(), f)
