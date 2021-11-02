# User and Namespace Creation
## Create private key and CSR (User)
Run
```bash
openssl req -new -newkey rsa:2048 -nodes -keyout myuser.key -out myuser.csr -subj "/CN=myuser"
```
then provide the `myuser.csr` file to the cluster admin.

## Convert CSR to base64 string (Admin)
Run
```bash
cat myuser.csr | base64 | tr -d "\n"
```
to convert the CSR to a string that can be placed in a CertificateSigningRequest object.

## Create and approve CSR (Admin)
Use example `csr-myuser.yaml` in the examples directory with base64 string from previous step to create
a CertificateSigningRequest object. Then approve the CSR using
```bash
kubectl certificate approve myuser
```

## Get cert from CSR resource (Admin)
```bash
kubectl get csr myuser -o jsonpath='{.status.certificate}'| base64 -d > myuser.crt
```

## Create User Namespace (Admin)
Create a namespace for the user, including a RoleBinding, ResourceQuota, and LimitRange using the example
`namespace-myuser.yaml` in the examples directory.

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
