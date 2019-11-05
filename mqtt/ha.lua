core.register_fetches("auth", function(txn)
  local identity_api = 'https://api.identity.plus/v1'
  local sn = txn.sf:ssl_c_serial()
  serial = tonumber(txn.c:hex(sn), 16)

  local cmd = 'curl -sk -X GET -H "Content-Type: application/json" -d \'{"Identity-Inquiry": {"serial-number": '..serial..'}}\' --cacert <path-to-ca-certificate>/plus.pem --key <path-to-client-key>/client.key --cert <path-to-client-certificate>/client.crt '..identity_api

  local output = io.popen(cmd)
  local result = output:read()
  output:close()

  if string.find(result, "OK 0001") == nil then
    txn:Error("Invalid certificate: "..serial)
    return "invalid"
  else
    txn:Info("Valid certificate: "..serial)
    return "mqtt"
  end
end)
