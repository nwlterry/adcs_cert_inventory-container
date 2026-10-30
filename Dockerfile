# On-prem CA Ledger console.
# Build this where the Microsoft base images can be pulled, then carry the
# saved tar onto the isolated network. The running container does not call out.
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY src/ src/
COPY dashboard/ dashboard/
RUN dotnet publish src/CertInventory/CertInventory.csproj \
    -c Release \
    -r linux-x64 \
    --self-contained true \
    -p:PublishSingleFile=false \
    -o /out

FROM mcr.microsoft.com/dotnet/runtime-deps:8.0
RUN mkdir -p /data \
    && if ! getent group 65532 >/dev/null; then groupadd --gid 65532 caledger; fi \
    && if ! getent passwd 65532 >/dev/null; then useradd --uid 65532 --gid 65532 --no-create-home --shell /usr/sbin/nologin caledger; fi \
    && chown 65532:65532 /data
WORKDIR /opt/ca-ledger
COPY --from=build /out/ ./
COPY docker/entrypoint.sh /opt/ca-ledger/entrypoint.sh
RUN chmod 755 /opt/ca-ledger/entrypoint.sh \
    && chmod -R a+rX /opt/ca-ledger
USER 65532:65532
EXPOSE 8787
VOLUME ["/data"]
ENV DOTNET_EnableDiagnostics=0 \
    CA_LEDGER_LISTEN=http://+:8787/ \
    CA_LEDGER_OUTPUT=/data/cert-inventory.json
ENTRYPOINT ["/opt/ca-ledger/entrypoint.sh"]
