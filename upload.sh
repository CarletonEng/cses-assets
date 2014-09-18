#! /bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"

api="${1:-http://localhost:8080}"

if [ "$2" ]; then
	user="$2"
	read -sp "Password: " pass
else
	user="1"
	pass="passwd"
fi

tok="$(curl -kXPOST -H"Content-Type: application/json" \
	--data-binary "{\"user\":\"$user\",\"pass\":\"$pass\"}" \
	"$api/auth" | sed -rzne 's/.*"token"\s*:\s*"([0-9A-F]+\$[0-9A-F]+)".*/\1/p'
)"

find -not -path '*/.*' -type f | while read f; do
	mime="$(file -bi "$f")"
	echo "Uploading $f ($mime)"
	curl -kXPUT -H"Authorization: Bearer $tok" -H"Content-Type: $mime" \
	     --data-binary "@$f" "$api/blob"
done
