function ssh-fingerprint -d "Gets fingerprint from an SSH pubkey" -a pubkey
    if test -f "$pubkey"
        ssh-keygen -lf $pubkey
    else
        ssh-keygen -lf (echo $pubkey | psub)
    end
end
