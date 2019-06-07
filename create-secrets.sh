kubectl create secret generic github --from-literal=username=${USERNAME} --from-literal=token=${TOKEN}

kubectl create secret generic url --from-literal=url=${URL}

kubectl create secret generic github-oauth --from-literal=CLIENT_ID=${CLIENT_ID} --from-literal=CLIENT_SECRET=${CLIENT_SECRET}