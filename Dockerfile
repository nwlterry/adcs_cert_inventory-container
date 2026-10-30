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
RUN groupadd --gid 65532 app \
    && useradd --uid 65532 --gid 65532 --no-create-home --shell /usr/sbin/nologin app \
    && mkdir -p /data \
    && chown app:app /data
WORKDIR /opt/ca-ledger
COPY --from=build /out/ ./
COPY docker/entrypoint.sh /opt/ca-ledger/entrypoint.sh
RUN chmod 755 /opt/ca-ledger/entrypoint.sh \
    && chmod -R a+rX /opt/ca-ledger
USER app
EXPOSE 8787
VOLUME ["/data"]
ENV DOTNET_EnableDiagnostics=0 \
    CA_LEDGER_LISTEN=http://+:8787/ \
    CA_LEDGER_OUTPUT=/data/cert-inventory.json
ENTRYPOINT ["/opt/ca-ledger/entrypoint.sh"]
