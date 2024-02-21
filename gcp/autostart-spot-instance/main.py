#!/usr/bin/env python3
"""Main Entrypoint

Author: widnyana
Copyright (C) 2024 - wid@widnyana.web.id
"""
import sys

from google.cloud import compute_v1
from google.cloud.compute_v1 import InstancesClient
from google.cloud.compute_v1.services.instances.pagers import ListPager
from loguru import logger

from configs import load_config
from logs import configure_logger
from schema import ProjectVM
from utils import wait_for_extended_operation


def ensure_started(client: InstancesClient, project_id: str, zone: str, vm_name: str) -> bool:
    logger.info(f"instance {vm_name} is not running. Starting...")
    try:
        operation = client.start(
            project=project_id, zone=zone, instance=vm_name
        )

        wait_for_extended_operation(operation, "instance start")

    except Exception as e:
        logger.error(f"got error: {e}")
        return False

    return True


def check_vms(client: InstancesClient, cfg: ProjectVM):
    logger.info("listing SPOT compute instances")

    for z in cfg.zones:
        request = compute_v1.ListInstancesRequest(
            project=cfg.project_id,
            zone=z.zone,
            filter=f"scheduling.provisioning_model={compute_v1.Scheduling.ProvisioningModel.SPOT.name}"
        )

        page_result: ListPager = client.list(request=request)
        for response in page_result:
            if response.name not in z.names:
                logger.debug(f"Instance {response.name} is not included. Skipping")
                continue

            if response.status.casefold() != "running".casefold():
                ensure_started(client, cfg.project_id, z.zone, response.name)


if __name__ == '__main__':
    configure_logger()

    config = load_config()
    if not config:
        logger.info("please recheck your configuration file")
        sys.exit()

    compute_api = compute_v1.InstancesClient()
    for p in config.spot_vms:
        check_vms(compute_api, p)
