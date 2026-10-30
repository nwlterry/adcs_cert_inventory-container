# AD CS certificate inventory (container)

On-prem console for an isolated network. The container serves the dashboard and `cert-inventory.json`. It does not contact a CA, DNS, or the public internet.

Live collection stays on a Windows workstation, with the [PowerShell collector](https://github.com/nwlterry/adcs_cert_inventory-powershell) or the [.NET collector](https://github.com/nwlterry/adcs_cert_inventory_dotnet). Copy the JSON they write into this container.

The image is Linux. AD CS (`certadm.dll`, `certutil`) is not in it and cannot be added.

## Build, then carry the image in

Build on a machine that can pull `mcr.microsoft.com` once:

```sh
sh build-image.sh
```

That writes `dist/ca-ledger-container.tar.gz`. Copy the file onto the isolated host and load it. No registry is required.

```sh
docker load -i ca-ledger-container.tar.gz
```

GitHub Actions also builds that archive on every push to `main` and attaches it to a version release.

## Run

Put the collector file at `./data/cert-inventory.json`, then:

```sh
docker compose up -d
```

Open `http://<this-host>:8787/` from another machine on the same isolated network. The page only reads the inventory from this container.

Without Compose:

```sh
docker run --rm --read-only --tmpfs /tmp:size=16m \
  -p 8787:8787 \
  -v /path/to/cert-inventory.json:/data/cert-inventory.json:ro \
  -e CA_LEDGER_LISTEN=http://+:8787/ \
  ca-ledger:0.3.0-beta.1
```

The file must be readable by uid `65532`. Inside the container the listener is `http://+:8787/`, which is what makes the published port reachable. On a Windows host, leave the collector on `http://127.0.0.1:8787/` unless you mean to listen on every interface.

Replace the JSON and restart the container to refresh the five-minute client status. The container does not probe clients. The collector does.

## Sample

To see the console before a real collection exists:

```sh
docker run --rm -p 8787:8787 \
  -e CA_LEDGER_DEMO=1 \
  ca-ledger:0.3.0-beta.1
```

That writes the built-in sample under `/data` and serves it. Do not treat those rows as the estate.

## What it serves

GET and HEAD only:

- `/` the dashboard
- `/cert-inventory.json` the mounted inventory

Nothing else. Client rows are still one certificate, then each CN or SAN client, then the collector’s last status: active, inactive, not in DNS, or not on the network. Several clients on one certificate are not a conflict.
