# Reproduction for cert issues running curl under nix

This repository contains `default.nix` which builds a derivation that runs `curl` to fetch a URL.
The URL is fetched over HTTPS and the certificate is not trusted by the system.

The CA certificate provided in the `ca-cert.pem` file is used to verify the certificate and establish trust with the server.

The URL for tests is `https://nix-test.zebradil.dev:8443/payload.txt`. It returns a simple text file.

## Reproduction with bare curl

First, without the custom CA certificate, the curl command fails:

```console
$ curl https://nix-test.zebradil.dev:8443/payload.txt
curl: (60) SSL certificate problem: unable to get local issuer certificate
More details here: https://curl.se/docs/sslcerts.html

curl failed to verify the legitimacy of the server and therefore could not
establish a secure connection to it. To learn more about this situation and
how to fix it, please visit the webpage mentioned above.
```

Now, with the custom CA certificate, the curl command succeeds:

```console
$ curl https://nix-test.zebradil.dev:8443/payload.txt --cacert ca-cert.pem
This is a downloadable file
```

## Reproduction with nix-build

Without any additional configuration, the nix-build fails:

```console
$ nix-build
warning: found empty hash, assuming 'sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA='
these 2 derivations will be built:
  /nix/store/5rsh6iy12zsykphxpf12r69399npigms-payload.txt.drv
  /nix/store/q94r8i9wjjg1j1bqfj3qx4i9h5060rhn-test-fetchurl.drv
building '/nix/store/5rsh6iy12zsykphxpf12r69399npigms-payload.txt.drv'...

trying https://nix-test.zebradil.dev:8443/payload.txt
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
curl: (60) SSL certificate problem: unable to get local issuer certificate
More details here: https://curl.se/docs/sslcerts.html

curl failed to verify the legitimacy of the server and therefore could not
establish a secure connection to it. To learn more about this situation and
how to fix it, please visit the webpage mentioned above.
error: cannot download payload.txt from any mirror
error: builder for '/nix/store/5rsh6iy12zsykphxpf12r69399npigms-payload.txt.drv' failed with exit code 1;
       last 12 log lines:
       >
       > trying https://nix-test.zebradil.dev:8443/payload.txt
       >   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
       >                                  Dload  Upload   Total   Spent    Left  Speed
       >   0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
       > curl: (60) SSL certificate problem: unable to get local issuer certificate
       > More details here: https://curl.se/docs/sslcerts.html
       >
       > curl failed to verify the legitimacy of the server and therefore could not
       > establish a secure connection to it. To learn more about this situation and
       > how to fix it, please visit the webpage mentioned above.
       > error: cannot download payload.txt from any mirror
       For full logs, run 'nix log /nix/store/5rsh6iy12zsykphxpf12r69399npigms-payload.txt.drv'.
error: 1 dependencies of derivation '/nix/store/q94r8i9wjjg1j1bqfj3qx4i9h5060rhn-test-fetchurl.drv' failed to build
```

Now, trying to set the `SSL_CERT_FILE` environment variable to the path of the custom CA certificate:

```console
$ SSL_CERT_FILE=ca-cert.pem nix-build
warning: found empty hash, assuming 'sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA='
these 2 derivations will be built:
  /nix/store/5rsh6iy12zsykphxpf12r69399npigms-payload.txt.drv
  /nix/store/q94r8i9wjjg1j1bqfj3qx4i9h5060rhn-test-fetchurl.drv
building '/nix/store/5rsh6iy12zsykphxpf12r69399npigms-payload.txt.drv'...

trying https://nix-test.zebradil.dev:8443/payload.txt
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
curl: (60) SSL certificate problem: unable to get local issuer certificate
More details here: https://curl.se/docs/sslcerts.html

curl failed to verify the legitimacy of the server and therefore could not
establish a secure connection to it. To learn more about this situation and
how to fix it, please visit the webpage mentioned above.
error: cannot download payload.txt from any mirror
error: builder for '/nix/store/5rsh6iy12zsykphxpf12r69399npigms-payload.txt.drv' failed with exit code 1;
       last 12 log lines:
       >
       > trying https://nix-test.zebradil.dev:8443/payload.txt
       >   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
       >                                  Dload  Upload   Total   Spent    Left  Speed
       >   0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
       > curl: (60) SSL certificate problem: unable to get local issuer certificate
       > More details here: https://curl.se/docs/sslcerts.html
       >
       > curl failed to verify the legitimacy of the server and therefore could not
       > establish a secure connection to it. To learn more about this situation and
       > how to fix it, please visit the webpage mentioned above.
       > error: cannot download payload.txt from any mirror
       For full logs, run 'nix log /nix/store/5rsh6iy12zsykphxpf12r69399npigms-payload.txt.drv'.
error: 1 dependencies of derivation '/nix/store/q94r8i9wjjg1j1bqfj3qx4i9h5060rhn-test-fetchurl.drv' failed to build
```

The `SSL_CERT_FILE` environment variable is not respected by the `curl` command.

Next, trying to set the `NIX_SSL_CERT_FILE` environment variable:

```console
$ NIX_SSL_CERT_FILE=ca-cert.pem nix-build
warning: found empty hash, assuming 'sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA='
these 2 derivations will be built:
  /nix/store/5rsh6iy12zsykphxpf12r69399npigms-payload.txt.drv
  /nix/store/q94r8i9wjjg1j1bqfj3qx4i9h5060rhn-test-fetchurl.drv
building '/nix/store/5rsh6iy12zsykphxpf12r69399npigms-payload.txt.drv'...

trying https://nix-test.zebradil.dev:8443/payload.txt
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
curl: (60) SSL certificate problem: unable to get local issuer certificate
More details here: https://curl.se/docs/sslcerts.html

curl failed to verify the legitimacy of the server and therefore could not
establish a secure connection to it. To learn more about this situation and
how to fix it, please visit the webpage mentioned above.
error: cannot download payload.txt from any mirror
error: builder for '/nix/store/5rsh6iy12zsykphxpf12r69399npigms-payload.txt.drv' failed with exit code 1;
       last 12 log lines:
       >
       > trying https://nix-test.zebradil.dev:8443/payload.txt
       >   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
       >                                  Dload  Upload   Total   Spent    Left  Speed
       >   0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
       > curl: (60) SSL certificate problem: unable to get local issuer certificate
       > More details here: https://curl.se/docs/sslcerts.html
       >
       > curl failed to verify the legitimacy of the server and therefore could not
       > establish a secure connection to it. To learn more about this situation and
       > how to fix it, please visit the webpage mentioned above.
       > error: cannot download payload.txt from any mirror
       For full logs, run 'nix log /nix/store/5rsh6iy12zsykphxpf12r69399npigms-payload.txt.drv'.
error: 1 dependencies of derivation '/nix/store/q94r8i9wjjg1j1bqfj3qx4i9h5060rhn-test-fetchurl.drv' failed to build
```

The result is the same.

Both `SSL_CERT_FILE` and `NIX_SSL_CERT_FILE` environment variables are not respected by the `curl` command when run from a nix derivation.
