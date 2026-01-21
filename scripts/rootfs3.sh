podman run --rm -it -v "$(pwd)/built":/built  --security-opt apparmor=unconfined --security-opt=unmask=/proc/\* --security-opt seccomp=buildd_seccomp.json --cap-add=cap_sys_admin --pids-limit=-1 -w /built  localhost/debian-sbuild mmdebstrap \
  --skip=output/dev \
  --variant=buildd \
  --setup-hook='mkdir -p "$1/etc/apt/keyrings"' \
  --setup-hook='copy-in debian-trixie-loong64.gpg /etc/apt/keyrings/' \
  --setup-hook='sed -i "s@signed-by=@signed-by=$1@" "$1/etc/apt/sources.list"' \
  --mode=unshare \
  --customize-hook='rm "$1"/etc/resolv.conf' \
  --customize-hook='rm "$1"/etc/hostname' \
  --customize-hook='chmod 1777 "$1"/tmp' \
  --customize-hook='mkdir -p "$1/etc/apt/apt.conf.d" && /bin/echo -e "APT::Install-Recommends 0;\nAcquire::PDiffs \"false\";\nAcquire::Languages \"none\";\nDPkg::Options {\"--force-unsafe-io\";};\nAcquire::CompressionTypes::Order { \"gz\"; \"bz2\"; }" > "$1/etc/apt/apt.conf.d/80_sbuild"' \
  --extract-hook='sed -i "s@signed-by=$1@signed-by=@" "$1/etc/apt/sources.list"' \
  "" 1.tar.zst \
  "deb [arch=all] http://deb.debian.org/debian trixie main contrib" \
  "deb [signed-by=/etc/apt/keyrings/debian-trixie-loong64.gpg] http://deb.internal.apernet.io/debian-loong64 trixie main contrib" \
  "deb-src http://deb.debian.org/debian trixie main contrib non-free non-free-firmware" \
  "deb-src [signed-by=/etc/apt/keyrings/debian-trixie-loong64.gpg] http://deb.internal.apernet.io/debian-loong64 trixie main contrib"
