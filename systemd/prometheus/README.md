# Prometheus Ecosystem

The binary were taken from [https://prometheus.io/download/](https://prometheus.io/download/)

And all the binary were expected to live in `/opt/prometheus/*`

## User

User and Group were created with `/sbin/nologin`, and no `$HOME`. All systemd unit listed inside this directory will run as `prometheus` user, and `prometheus` group.

### Adding User

```sh
useradd \
    --no-create-home \
    --shell /sbin/nologin \
    prometheus
```

## systemd

The naming is as follow:

- `prometheus.service`
- `prometheus-alertmanager.service`
- `prometheus-mongodbexporter.service`
- `prometheus-nodeexporter.service`
- `prometheus-pushgateway.service`

### Port Bindings

- prometheus
  - `*:9090/tcp`
- alertmanager
  - `*:9093/tcp`
  - `*:9094/tcp`
  - `*:9094/udp`
- node_exporter
  - `*:9100/tcp`
- pushgateway
  - `*:9091/tcp`

## Important Paths

- `/opt/prometheus/` : home for all the binaries,
- `/etc/prometheus/` : path for storing configs consumed by alertmanager, and prometheus were placed here,
- `/var/lib/prometheus/` : path of data storage for alertmanager, and prometheus
