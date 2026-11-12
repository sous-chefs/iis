# frozen_string_literal: true

powershell_script 'ensure the WMSVC test certificate exists' do
  code "New-SelfSignedCertificate -DnsName 'WMSVC' -CertStoreLocation 'Cert:\\LocalMachine\\My' | Out-Null"
  not_if "Get-ChildItem Cert:\\LocalMachine\\My | Where-Object { $_.Subject -like '*WMSVC*' }"
end

iis_manager 'IIS Manager' do
  port                      19500
  enable_remote_management  true
  log_directory             'C:\\CustomPath'
end
