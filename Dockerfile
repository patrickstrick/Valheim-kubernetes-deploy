FROM registry.access.redhat.com/ubi8/ubi-minimal:latest

LABEL org.opencontainers.image.title="Valheim dedicated server container" \
    org.opencontainers.image.authors="Patrick Strick" \
    org.opencontainers.image.source="https://github.com/patrickstrick/Valheim-kubernetes-deploy"

# UPDATE_ON_RESTART="If set to 1, check for available updates on startup and install when found."
# SERVER_NAME="The server name to be displayed in the multiplayer browser menu. Example: ValheimServer"
# SERVER_PORT="The server port to bind on. Example: 2456"
# SERVER_WORLD="The server's world name. Example: Valhalla"
# SERVER_PASSWORD="The server's password. Example: secret"

ENV UPDATE_ON_RESTART=1 \
    SERVER_NAME="ValheimServer" \
    SERVER_PORT="2456" \
    SERVER_WORLD="Valhalla" \
    SERVER_PASSWORD="secret"

# Install Steam dependancies and Configure Valheim directories and entrypoint file
RUN microdnf update \
    && microdnf install glibc.i686 libstdc++.i686 shadow-utils wget tar gzip \
    && microdnf clean all \
    && useradd -u 1001 --create-home valheim --shell /bin/bash --comment valheim \
    && mkdir -p /home/valheim/server /home/valheim/.config/unity3d/IronGate /data /home/valheim/steamcmd \
    && chown -R valheim:0 /home/valheim \
    && chown valheim:0 /data \
    && chmod -R g=u /home/valheim \
    && chmod -R g=u /data \
    && ln -s /data /home/valheim/.config/unity3d/IronGate/Valheim

# Copy entrypoint.sh
COPY --chown=valheim:0 entrypoint.sh /home/valheim/

# Make entrypoint.sh executable
RUN chmod +x /home/valheim/entrypoint.sh

# Change to user valheim (as uid for OpenShift) and set working directory to user's home for further commands
USER 1001
WORKDIR /home/valheim

# Install Steam and Valheim dedicated server
RUN wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz \
    && tar -xzf steamcmd_linux.tar.gz --directory steamcmd \
    && rm steamcmd_linux.tar.gz \
    && steamcmd/steamcmd.sh +quit \
    && steamcmd/steamcmd.sh +login anonymous +force_install_dir /home/valheim/server +app_update 896660 +quit

# Open ports Valheim server needs
EXPOSE 2456/udp 2457/udp 2458/udp

# Run script when container starts to update Valheim if needed and run server.
ENTRYPOINT ["/home/valheim/entrypoint.sh"]
CMD SteamAppId=892970 \
    LD_LIBRARY_PATH="/home/valheim/server/linux64/" \
    /home/valheim/server/valheim_server.x86_64 \
    -name ${SERVER_NAME} \
    -world ${SERVER_WORLD} \
    -password ${SERVER_PASSWORD} \
    -public 1 \
    -port ${SERVER_PORT}
