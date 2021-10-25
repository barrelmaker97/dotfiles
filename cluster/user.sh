# Create private key and CSR
openssl req -new -newkey rsa:2048 -nodes -keyout barrelmaker.key -out barrelmaker.csr -subj "/CN=barrelmaker"

# Convert CSR to base64 string
cat barrelmaker.csr | base64 | tr -d "\n"

# Get cert from CSR resource
kubectl get csr barrelmaker -o jsonpath='{.status.certificate}'| base64 -d > barrelmaker.crt

# Create user in kubectl
kubectl config set-credentials barrelmaker --client-key=barrelmaker.key --client-certificate=barrelmaker.crt --embed-certs=true

# Create cluster in kubectl
TODO

# Create context in kubectl
kubectl config set-context barrelmaker --cluster=kubernetes --user=barrelmaker --namespace=barrelmaker
