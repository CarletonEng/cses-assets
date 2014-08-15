#! /bin/bash

api="${1:-http://localhost:8080}"
user="${2:-1}"
pass="${3:-passwd}"

tok="$(curl -XPOST -H"Content-Type: application/json" \
	--data-binary "{\"user\":\"$user\",\"pass\":\"$pass\"}" \
	"$api/auth" | sed -rzne 's/.*"token"\s*:\s*"([0-9A-F]+\$[0-9A-F]+)".*/\1/p'
)"

find -not -path '*/.*' -type f | while read f; do
	mime="$(file -bi "$f")"
	echo "Uploading $f ($mime)"
	curl -XPUT -H"Authorization: Bearer $tok" -H"Content-Type: $mime" \
	     --data-binary "@$f" "$api/blob"
done
