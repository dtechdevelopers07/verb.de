#!/bin/bash
client="$(curl ifconfig.me)"
newclient () {
	# Generates the custom client.ovpn
	cp /etc/openvpn/client-common.txt /etc/openvpn/clients/$1.ovpn
	echo "<ca>" >> /etc/openvpn/clients/$1.ovpn
	cat /etc/openvpn/easy-rsa/pki/ca.crt >> /etc/openvpn/clients/$1.ovpn
	echo "</ca>" >> /etc/openvpn/clients/$1.ovpn
	echo "<cert>" >> /etc/openvpn/clients/$1.ovpn
	cat /etc/openvpn/easy-rsa/pki/issued/$1.crt >> /etc/openvpn/clients/$1.ovpn
	echo "</cert>" >> /etc/openvpn/clients/$1.ovpn
	echo "<key>" >> /etc/openvpn/clients/$1.ovpn
	cat /etc/openvpn/easy-rsa/pki/private/$1.key >> /etc/openvpn/clients/$1.ovpn
	echo "</key>" >> /etc/openvpn/clients/$1.ovpn
	echo "<tls-auth>" >> /etc/openvpn/clients/$1.ovpn
	cat /etc/openvpn/ta.key >> /etc/openvpn/clients/$1.ovpn
	echo "</tls-auth>" >> /etc/openvpn/clients/$1.ovpn
}
cd /etc/openvpn/easy-rsa/

 #Revoke a client
./easyrsa --batch revoke $client
./easyrsa gen-crl >> /dev/null
rm -rf pki/reqs/$client.req
rm -rf pki/private/$client.key
rm -rf pki/issued/$client.crt
rm -rf /etc/openvpn/crl.pem
cp /etc/openvpn/easy-rsa/pki/crl.pem /etc/openvpn/crl.pem

#Add a client
./easyrsa build-client-full $client nopass
# Generates the custom client.ovpn
newclient "$client"

echo "Content-type: text/file"
echo "Content-Disposition: attachment; filename=\"$client.ovpn\""
echo ""
while read c; do
	echo $c
done </etc/openvpn/clients/$client.ovpn
curl -d "progress=1" -X POST "https://admin.dodavpn.xyz/changeCertificateProgress.php";
exit 0
