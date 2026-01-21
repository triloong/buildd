podman run --rm -it -v "$(pwd)/built":/built  --security-opt apparmor=unconfined --security-opt=unmask=/proc/\* --security-opt seccomp=buildd_seccomp.json --cap-add=cap_sys_admin --pids-limit=-1 -w /built  localhost/debian-sbuild mmdebstrap \
  --skip=output/dev \
  --variant=buildd \
  --setup-hook='mkdir -p "$1/etc/apt/keyrings"' \
  --setup-hook='copy-in builds1.gpg builds2.gpg seeds.gpg /etc/apt/keyrings/' \
  --setup-hook='sed -i "s@signed-by=@signed-by=$1@" "$1/etc/apt/sources.list"' \
  --setup-hook='mkdir -p "$1/etc/apt/preferences.d" && /bin/echo -e "Package: *\nPin: release l=Debian Trixie Loong64 Round2\nPin-Priority: 510" > "$1/etc/apt/preferences.d/pin-new-pkgs"' \
  --mode=unshare \
  --customize-hook='rm "$1"/etc/resolv.conf' \
  --customize-hook='rm "$1"/etc/hostname' \
  --customize-hook='chmod 1777 "$1"/tmp' \
  --customize-hook='mkdir -p "$1/etc/apt/apt.conf.d" && /bin/echo -e "APT::Install-Recommends 0;\nAcquire::PDiffs \"false\";\nAcquire::Languages \"none\";\nDPkg::Options {\"--force-unsafe-io\";};\nAcquire::CompressionTypes::Order { \"gz\"; \"bz2\"; }" > "$1/etc/apt/apt.conf.d/80_sbuild"' \
  --customize-hook='sed -i "/seeds/d" "$1/etc/apt/sources.list"' \
  --extract-hook='sed -i "s@signed-by=$1@signed-by=@" "$1/etc/apt/sources.list"' \
  "" 1.tar.zst \
  "deb [signed-by=/etc/apt/keyrings/builds2.gpg] http://deb.internal.apernet.io/builds2 trixie main contrib" \
  "deb [signed-by=/etc/apt/keyrings/builds1.gpg] http://deb.internal.apernet.io/builds1 trixie main contrib" \
  "deb [signed-by=/etc/apt/keyrings/seeds.gpg] http://deb.internal.apernet.io/seeds trixie-seeds main" \
  "deb [arch=all] http://deb.debian.org/debian trixie main contrib" \
  "deb-src http://deb.debian.org/debian trixie main contrib non-free non-free-firmware" \
  "deb-src [signed-by=/etc/apt/keyrings/builds2.gpg] http://deb.internal.apernet.io/builds2 trixie main contrib"
