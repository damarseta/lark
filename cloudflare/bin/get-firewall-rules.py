#!/usr/bin/env python
from __future__ import annotations
import CloudFlare
from pathlib import Path
import json

# required package: https://github.com/cloudflare/python-cloudflare
# get your token from here: https://developers.cloudflare.com/fundamentals/api/get-started/create-token/
# custom rulesets API: https://developers.cloudflare.com/waf/custom-rules/custom-rulesets/create-api/

TOKEN = "<PUT YOUR TOKEN HERE>"

cwd = Path.cwd()
out_path = cwd.joinpath("out").joinpath("cf")
#: all the output will be placed here
out_path.mkdir(mode=0o755, parents=True, exist_ok=True)


cf = CloudFlare.CloudFlare(token=TOKEN)

#: getting all of accessible zones
zones_raw = cf.zones.get(params={"per_page": 1000})
if not zones_raw:
    print("No zones found")
    exit(1)

zones = []
for zone in zones_raw:
    zone_id = zone["id"]
    zone_name = zone["name"]

    with open(out_path.joinpath(f"zone.{zone_id}.{zone_name}.json"), "w") as fp:
        fp.write(json.dumps(zone, indent=2))

    zones.append(
        {
            "id": zone_id,
            "name": zone_name,
        }
    )

    print(f"zone_id: {zone_id} | {zone_name}")

    #: Get all of accessible WAF - Custom Rule for available zones
    #: and dump it as json file
    r = cf.zones.firewall.rules.get(zone_id)
    if not r:
        print(f"no custom rulesets for {zone_id} - {zone_name}")
    else:
        print(json.dumps(r, indent=2))

    with open(
        out_path.joinpath(f"zone.{zone_id}.{zone_name}.rulesets.json"), "w"
    ) as fp:
        fp.write(json.dumps(r, indent=2))

    print("****" * 20)

print("Done")
print(f"Find the results in this directory: {out_path}")

