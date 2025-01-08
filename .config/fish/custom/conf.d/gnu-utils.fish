if not type -q gwhoami and not type -q gsed
    return
end

# these all broke the shell, bad.
set bads 'g[' gecho gprintf gtest gmktemp gtime gtrue gcat

set gcmds gbase64 gbasename gchcon gchgrp gchmod \
    gchown gchroot gcksum gcomm gcp gcsplit gcut gdate \
    gdd gdf gdir gdircolors gdirname gdu genv gexpand \
    gexpr gfactor gfalse gfmt gfold ggroups ghead ghostid \
    gid ginstall gjoin gkill glink gln glogname gls gmd5sum \
    gmkdir gmkfifo gmknod gmv gnice gnl gnohup gnproc \
    god gpaste gpathchk gpinky gpr gprintenv gptx gpwd \
    greadlink grm grmdir gruncon gseq gsha1sum gsha224sum \
    gsha256sum gsha384sum gsha512sum gshred gshuf gsleep gsort \
    gsplit gstat gstty gsum gsync gtac gtail gtee \
    gtimeout gtouch gtr gtruncate gtsort gtty guname \
    gunexpand guniq gunlink guptime gusers gvdir gwc gwho \
    gwhoami gyes

# findutils
set -a gcmds gfind gxargs glocate

# Not part of either coreutils or findutils, installed separately.
set -a gcmds gsed gtar gmake ggrep gawk gunits

# can be built optionally
set -a gcmds ghostname

for gcmd in $gcmds
    set actual_cmd (string sub --start=2 "$gcmd")

    if not type -q $gcmd
        continue
    end

    alias $actual_cmd $gcmd
end
