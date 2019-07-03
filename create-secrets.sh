kubectl create secret generic github --from-literal=username=${USERNAME} --from-literal=token=${TOKEN}

kubectl create secret generic github-oauth --from-literal=CLIENT_ID=${CLIENT_ID} --from-literal=CLIENT_SECRET=${CLIENT_SECRET}

# kubectl create secret docker-registry docker-credentials \
#     --docker-username=${username}  \
#     --docker-password=${password} \
#     --docker-email=${email-address}

kubectl create secret docker-registry gcr-secret \
    --docker-server=https://gcr.io \
    --docker-username=_json_key \
    --docker-email=${SERVICE_ACCOUNT@PROJECT.iam.gserviceaccount.com} \
    --docker-password="$(cat kaniko-secret.json)"