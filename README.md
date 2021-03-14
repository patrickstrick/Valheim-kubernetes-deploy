# Valheim-kubernetes-deploy

Inspiration from https://github.com/cbrgm/valheim-docker.
Deployes Valheim dedicated game server to Kubernetes with ports exposed as node ports.
This is what I use for my server. You may need to modify it for your own use.

## Files

### Dockerfile

To build container image of Valheim dedicated server

### entrypoint.sh

Is run when container starts.
Updates Valheim server on start if an update is available.

### cron_restart.yaml

Restarts server by destroying the pod every day at 5am.
This allows the server to check for updates.

### deploy.yaml

Creates the deployment for the pod with one replica.
Persistent local storage for save/world files.
Exposes game server's ports as node ports.  

**NOTE** The container image linked in the deployment is manually updated by me, and might not be up to date with the contents of this repo.
You should build your own container from the Dockerfile and push it to your own container registry.
Then update the deploy.yaml to point to your registry location.

### Mods
Work in progress
Sources:  
* https://valheim.thunderstore.io/package/denikson/BepInExPack_Valheim/
* https://www.nexusmods.com/valheim/mods/300
