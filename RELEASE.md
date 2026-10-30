On-prem console image for an isolated network. Load it with `docker load -i ca-ledger-container.tar.gz`. It serves the dashboard and `cert-inventory.json`. It does not contact a CA.

Live collection stays on Windows, using the PowerShell or .NET collector. Mount the JSON they write at `/data/cert-inventory.json`.

This is a beta. Confirm a lab probe before treating a host as down.
