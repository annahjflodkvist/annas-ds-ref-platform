param (

)

task cert_up {
    # generate an rsa key
    openssl genrsa -out ./0_certs/root-ca/root-ca-key.pem 2048
    openssl req -x509 -new -nodes -key ./0_certs/root-ca/root-ca-key.pem -days 3650 -sha256 -out ./0_certs/root-ca/root-ca.pem -subj "/CN=kube-ca"
    Import-Certificate -FilePath "./0_certs/root-ca/root-ca.pem" -CertStoreLocation cert:\CurrentUser\Root
}

