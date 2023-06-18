#!/bin/bash
CLIENT_DIR="/velociraptor/clients"
CONFIG_PATCH='{"Frontend":{"public_path":"public","hostname":"VelociraptorServer","use_plain_http":true},"API":{"bind_address":"0.0.0.0"},"GUI":{"bind_address":"0.0.0.0","use_plain_http":true,"base_path":"/gui"},"Monitoring":{"bind_address":"0.0.0.0"},"Logging":{"output_directory":"./","separate_logs_per_component":true},"Client":{"server_urls":["https://VelociraptorServer:8000/"],"use_self_signed_ssl":false},"Datastore":{"location":"./","filestore_directory":"./"}}'

# Move binaries into place
cp /opt/velociraptor/linux/velociraptor . && chmod +x velociraptor
mkdir -p $CLIENT_DIR/linux && rsync -a /opt/velociraptor/linux/velociraptor /velociraptor/clients/linux/velociraptor_client
mkdir -p $CLIENT_DIR/mac && rsync -a /opt/velociraptor/mac/velociraptor_client /velociraptor/clients/mac/velociraptor_client
mkdir -p $CLIENT_DIR/windows && rsync -a /opt/velociraptor/windows/velociraptor_client* /velociraptor/clients/windows/

# If no existing server config, set it up
if [ ! -f server.config.yaml ]; then
	./velociraptor config generate > server.config.yaml --merge $CONFIG_PATCH
        #sed -i "s#https://localhost:8000/#$VELOX_CLIENT_URL#" server.config.yaml
	sed -i 's#/tmp/velociraptor#.#'g server.config.yaml
	./velociraptor --config server.config.yaml user add $VELOX_USER $VELOX_PASSWORD --role=$VELOX_ROLE
fi

# Re-generate client config in case server config changed
./velociraptor --config server.config.yaml config client > client.config.yaml

# Repack clients
./velociraptor config repack --exe clients/linux/velociraptor_client client.config.yaml clients/linux/velociraptor_client_repacked
./velociraptor config repack --exe clients/mac/velociraptor_client client.config.yaml clients/mac/velociraptor_client_repacked
./velociraptor config repack --exe clients/windows/velociraptor_client.exe client.config.yaml clients/windows/velociraptor_client_repacked.exe

# Start Velocoraptor
./velociraptor --config server.config.yaml frontend -v
