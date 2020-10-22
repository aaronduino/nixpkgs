{ stdenv, autoPatchelfHook, ffmpeg_3, fetchurl, bash, jdk, kmod, pkgs }:

stdenv.mkDerivation {
  name = "energia";
  version = "1.8.10E23";

  src = fetchurl {
    url = "http://energia.nu/downloads/downloadv4.php?file=energia-1.8.10E23-linux64.tar.xz";
    sha256 = "065vii9x9b7x4bj1b97grz2vwd4xam1lprsbgsfagry3adf3bshv";
  };

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = with pkgs; [
    libav xorg.libX11 xorg.libXtst ncurses5.dev zlib libusb-compat-0_1 python27
    ffmpeg libGL pango glib gobject-introspection gtk3 gtk2 gdk-pixbuf atk kmod bash
  ];

  buildPhase = ''
    sed -i "s#{runtime.tools.dslite-9.2.0.1793-e1.path}#$out/hardware/tools/DSLite#g" hardware/energia/msp430/platform.txt
    mkdir -p $out
    cp -r ./* $out
    echo ${ffmpeg_3.out}
    ln -s ${ffmpeg_3.out}/lib/libavcodec.so* $out/lib
    ln -s ${ffmpeg_3.out}/lib/libavcodec.so $out/lib/libavcodec.so.53
    ln -s ${ffmpeg_3.out}/lib/libavcodec.so $out/lib/libavcodec.so.54
    ln -s ${ffmpeg_3.out}/lib/libavcodec.so $out/lib/libavcodec.so.55
    ln -s ${ffmpeg_3.out}/lib/libavcodec.so $out/lib/libavcodec.so.56
    ln -s ${ffmpeg_3.out}/lib/libavcodec.so $out/lib/libavcodec-ffmpeg.so.56
    ln -s ${ffmpeg_3.out}/lib/libavcodec.so $out/lib/libavcodec-ffmpeg.so.57
    ln -s ${ffmpeg_3.out}/lib/libavcodec.so $out/lib/libavcodec-ffmpeg.so.58
    ln -s ${ffmpeg_3.out}/lib/libavformat.so* $out/lib
    ln -s ${ffmpeg_3.out}/lib/libavformat.so $out/lib/libavformat.so.53
    ln -s ${ffmpeg_3.out}/lib/libavformat.so $out/lib/libavformat.so.54
    ln -s ${ffmpeg_3.out}/lib/libavformat.so $out/lib/libavformat.so.55
    ln -s ${ffmpeg_3.out}/lib/libavformat.so $out/lib/libavformat.so.56
    ln -s ${ffmpeg_3.out}/lib/libavformat.so $out/lib/libavformat-ffmpeg.so.56
    ln -s ${ffmpeg_3.out}/lib/libavformat.so $out/lib/libavformat-ffmpeg.so.57
    ln -s ${ffmpeg_3.out}/lib/libavformat.so $out/lib/libavformat-ffmpeg.so.58
    ls $out/lib
  '';

  installPhase = ''
    mkdir $out/bin
    cat << EOF > $out/bin/energia
    #!${bash}/bin/bash
    for LIB in \
      $out/java/jre/lib/rt.jar \
      $out/java/jre/lib/tools.jar \
      $out/lib/*.jar \
      ;
    do
        CLASSPATH="\$CLASSPATH:\$LIB"
    done
    export CLASSPATH
    export LD_LIBRARY_PATH=$out/lib:\$LD_LIBRARY_PATH
    ${jdk}/bin/java "-DAPP_DIR=$out" processing.app.Base "\$@"
    EOF
    chmod +x $out/bin/energia
    mkdir -p "$out/etc/udev/rules.d"
    cat << EOF > $out/etc/udev/rules.d/71-ti-permissions.rules
    SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="0403",ATTRS{idProduct}=="a6d0",MODE:="0666"
    SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="0403",ATTRS{idProduct}=="a6d1",MODE:="0666"
    SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="0403",ATTRS{idProduct}=="6010",MODE:="0666"
    SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="1cbe",ATTRS{idProduct}=="00fd",MODE:="0666"
    SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="1cbe",ATTRS{idProduct}=="00ff",MODE:="0666"
    SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="0451",ATTRS{idProduct}=="bef1",MODE:="0666"
    SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="0451",ATTRS{idProduct}=="bef2",MODE:="0666"
    SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="0451",ATTRS{idProduct}=="bef3",MODE:="0666"
    SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="0451",ATTRS{idProduct}=="bef4",MODE:="0666"
    SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="0451",ATTRS{idProduct}=="f432",MODE:="0666"
    SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="0d28",ATTRS{idProduct}=="0204",MODE:="0666"
    KERNEL=="hidraw*",ATTRS{busnum}=="*",ATTRS{idVendor}=="0d28",ATTRS{idProduct}=="0204",MODE:="0666"
    ATTRS{idVendor}=="0451",ATTRS{idProduct}=="bef0",ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTRS{idVendor}=="0c55",ATTRS{idProduct}=="0220",ENV{ID_MM_DEVICE_IGNORE}="1"
    KERNEL=="ttyACM[0-9]*",MODE:="0666"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0451", ATTRS{idProduct}=="c32a", MODE="0660", GROUP="dialout", RUN+="${kmod}/bin/modprobe ftdi-sio" RUN+="${bash}/bin/sh -c 'echo 0451 c32a > /sys/bus/usb-serial/drivers/ftdi_sio/new_id'"
    EOF
  '';
}
