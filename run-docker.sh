docker build -t velo .

docker run -it \
    -e "VELOX_USER=admin" \
    -e "VELOX_PASSWORD=admin" \
    -e "VELOX_ROLE=administrator" \
    -e "VELOX_SERVER_URL=http://172.17.0.2/" \
    -e "VELOX_FRONTEND_HOSTNAME=VelociraptorServer" \
    --entrypiont /velociraptor/entrypoint.sh velo