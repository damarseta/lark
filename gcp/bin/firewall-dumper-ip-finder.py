#!/usr/bin/env python

# This script mean to be used along with ./firewall-dumper.sh.
# it will process those json files to find IP_TO_FIND, then create 2 files to contains the result
# one is csv file, the other one is markdown file.
# required package
#
# (wtfpl) 2024 - widnyana


from __future__ import annotations
from typing import List, Optional
import glob
from pathlib import Path

import pandas as pd
from pydantic import BaseModel, RootModel

try:
    import orjson as json
except ImportError:
    import json

IP_TO_FIND = "<PUT THE IP HERE>"


class IpProto(BaseModel):
    IPProtocol: str
    ports: Optional[List[str]] = None


class LogConfig(BaseModel):
    enable: bool


class Firewall(BaseModel):
    allowed: Optional[List[IpProto]] = None
    denied: Optional[List[IpProto]] = None
    creationTimestamp: str
    description: str
    direction: str
    disabled: bool
    id: str
    kind: str
    logConfig: LogConfig
    name: str
    network: str
    priority: int
    selfLink: str
    sourceRanges: Optional[List[str]] = []
    targetTags: Optional[List[str]] = None
    destinationRanges: Optional[List[str]] = None


Firewalls = RootModel[List[Firewall]]


def main():
    files = glob.glob(Path.cwd().joinpath("out").joinpath("fw.*.json").__str__())

    founds = []
    for f in files:
        _, project, _ = f.split(".")

        with open(f, "rb") as fp:
            raw = json.loads(fp.read())
            data: Firewalls = Firewalls.model_validate(raw)

        for d in data.root:
            if d.sourceRanges:
                if IP_TO_FIND in [x for x in d.sourceRanges]:
                    print(f"found in firewall name: {d.name} in project {project}")
                    print(f"rule details: {d.allowed}")
                    print(d.targetTags)

                    allowed = ""
                    if d.allowed:
                        for a in d.allowed:
                            if a.ports:
                                allowed = ",".join(
                                    [f"`{a.IPProtocol}/{p}`" for p in a.ports]
                                )

                    founds.append(
                        {
                            "project": project,
                            "name": d.name,
                            "network": d.network,
                            "direction": d.direction,
                            "source_ranges": ", ".join(
                                [f"`{x}`" for x in d.sourceRanges]
                                if d.sourceRanges
                                else []
                            ),
                            "target_tags": ", ".join(
                                [f"`{x}`" for x in d.targetTags] if d.targetTags else []
                            ),
                            "allowed": allowed,
                            "destination_ranges": d.destinationRanges,
                            "self_link": d.selfLink,
                        }
                    )

    df = pd.DataFrame(founds)
    df.to_csv("founds.csv", index=False)

    with open("founds.csv", "r") as fp:
        from csv2md.table import Table

        table = Table.parse_csv(fp)
        md = table.markdown()

        with open("founds.md", "wb") as f:
            f.write(md.encode("utf-8"))


if __name__ == "__main__":
    main()
