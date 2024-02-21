"""Utility functions

Author: widnyana
Copyright (C) 2024 - wid@widnyana.web.id
"""
import sys
from typing import Any

from google.api_core.extended_operation import ExtendedOperation
from loguru import logger


def wait_for_extended_operation(
        operation: ExtendedOperation, verbose_name: str = "operation", timeout: int = 300
) -> Any:
    """
    Waits for the extended (long-running) operation to complete.

    If the operation is successful, it will return its result.
    If the operation ends with an error, an exception will be raised.
    If there were any warnings during the execution of the operation
    they will be printed to sys.stderr.

    Args:
        operation: a long-running operation you want to wait on.
        verbose_name: (optional) a more verbose name of the operation,
            used only during error and warning reporting.
        timeout: how long (in seconds) to wait for operation to finish.
            If None, wait indefinitely.

    Returns:
        Whatever the operation.result() returns.

    Raises:
        This method will raise the exception received from `operation.exception()`
        or RuntimeError if there is no exception set, but there is an `error_code`
        set for the `operation`.

        In case of an operation taking longer than `timeout` seconds to complete,
        a `concurrent.futures.TimeoutError` will be raised.

    stolen from: https://github.com/GoogleCloudPlatform/python-docs-samples/blob/161448f276cd6fbe697c83e2ec55c4828e9143fa/compute/client_library/snippets/instances/start.py#L32
    """
    result = operation.result(timeout=timeout)

    if operation.error_code:
        logger.error(
            f"Error during {verbose_name}: [Code: {operation.error_code}]: {operation.error_message}",
            file=sys.stderr,
            flush=True,
        )
        logger.error(f"Operation ID: {operation.name}", file=sys.stderr, flush=True)
        raise operation.exception() or RuntimeError(operation.error_message)

    if operation.warnings:
        logger.warning(f"Warnings during {verbose_name}:\n", file=sys.stderr, flush=True)
        for warning in operation.warnings:
            logger.warning(f" - {warning.code}: {warning.message}", file=sys.stderr, flush=True)

    return result
