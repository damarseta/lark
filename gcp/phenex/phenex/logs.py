"""Logging library

Author: widnyana
Copyright (C) 2024 - wid@widnyana.web.id
"""
import sys

from loguru import logger


def configure_logger():
    config = {
        "handlers": [
            {"sink": sys.stdout, "format": "{time} - [{level}] - {message}"},
        ],
        "extra": {"app": "phenex"},
    }

    logger.remove()
    logger.configure(**config)
