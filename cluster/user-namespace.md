# User and Namespace Creation
## Create private key and CSR (User)
```bash
openssl req -new -newkey rsa:2048 -nodes -keyout myuser.key -out myuser.csr -subj "/CN=myuser"
```

## Convert CSR to base64 string (Admin)
```bash
cat myuser.csr | base64 | tr -d "\n"
```

## Create and approve CSR (Admin)
Use example `csr.yaml` in this directory with base64 string from previous step

## Get cert from CSR resource (Admin)
```bash
kubectl get csr myuser -o jsonpath='{.status.certificate}'| base64 -d > myuser.crt
```

## Create user in kubectl (User)
```bash
kubectl config set-credentials myuser --client-key=myuser.key --client-certificate=myuser.crt --embed-certs=true
```

## Create cluster in kubectl (User)
```bash
kubectl config set-cluster kubernetes --server=https://192.168.15.10:16443 --certificate-authority=/cluster/ca/cert/file.crt --embed-certs=true
```

## Create context in kubectl (User)
```bash
kubectl config set-context myuser --cluster=kubernetes --user=myuser --namespace=myuser
```
