[back to resource list](https://github.com/sous-chefs/iis#resources)

---

# windows_certificate_binding

Binds a certificate to an HTTP port to enable TLS communication.

## Actions

- `:create` - creates or updates a binding.
- `:delete` - deletes a binding.

## Properties

- `cert_name` - name attribute. The thumbprint(hash) or subject that identifies the certificate to be bound.
- `name_kind` - indicates the type of cert_name. One of :subject (default) or :hash.
- `address` - the address to bind against. Default is 0.0.0.0 (all IP addresses). One of:
  - IP v4 address `1.2.3.4`
  - IP v6 address `[::1]`
  - Host name `www.foo.com`
- `port` - the port to bind against. Default is 443.
- `app_id` - the GUID that defines the application that owns the binding. Default is the values used by IIS.
- `store_name` - the store to locate the certificate in. One of:
  - MY (Personal)
  - CA (Intermediate Certification Authorities)
  - ROOT (Trusted Root Certification Authorities)
  - TRUSTEDPUBLISHER (Trusted Publishers)
  - CLIENTAUTHISSUER (Client Authentication Issuers)
  - REMOTE DESKTOP (Remote Desktop)
  - TRUSTEDDEVICES (Trusted Devices)
  - WEBHOSTING (Web Hosting)
  - AUTHROOT (Third-Party Root Certification Authorities)
  - TRUSTEDPEOPLE (Trusted People)
  - SMARTCARDROOT (Smart Card Trusted Roots)
  - TRUST (Enterprise Trust)

## Examples

```ruby
# Bind the first certificate matching the subject to the default TLS port
iis_certificate_binding "me.acme.com" do
end
```

```ruby
# Bind a cert from the CA store with the given hash to port 4334
iis_certificate_binding "me.acme.com" do
    cert_name    "d234567890a23f567c901e345bc8901d34567890"
    name_kind    :hash
    store_name    "CA"
    port        4334
end
```
