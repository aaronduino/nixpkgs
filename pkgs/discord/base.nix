{ pname, version, src, binaryName, desktopName
, stdenv, fetchurl, makeDesktopItem, wrapGAppsHook
, alsaLib, atk, at-spi2-atk, at-spi2-core, cairo, cups, dbus, expat, fontconfig, freetype
, gdk-pixbuf, glib, gtk3, libnotify, libX11, libXcomposite, libXcursor, libXdamage, libuuid
, libXext, libXfixes, libXi, libXrandr, libXrender, libXtst, nspr, nss, libxcb
, pango, systemd, libXScrnSaver, libcxx, libpulseaudio
, xvfb_run
, callPackage, ... }:

let
  inherit binaryName;
  beautiful-discord = callPackage (import ./beautiful-discord.nix) {};
in stdenv.mkDerivation rec {
  inherit pname version src;

  nativeBuildInputs = [ wrapGAppsHook ];

  dontWrapGApps = true;

  libPath = stdenv.lib.makeLibraryPath [
    libcxx systemd libpulseaudio
    stdenv.cc.cc alsaLib atk at-spi2-atk at-spi2-core cairo cups dbus expat fontconfig freetype
    gdk-pixbuf glib gtk3 libnotify libX11 libXcomposite libuuid
    libXcursor libXdamage libXext libXfixes libXi libXrandr libXrender
    libXtst nspr nss libxcb pango systemd libXScrnSaver
   ];

  installPhase = ''
    mkdir -p $out/{bin,opt/${binaryName},share/pixmaps}
    mv * $out/opt/${binaryName}

    chmod +x $out/opt/${binaryName}/${binaryName}
    patchelf --set-interpreter ${stdenv.cc.bintools.dynamicLinker} \
        $out/opt/${binaryName}/${binaryName}

    wrapProgram $out/opt/${binaryName}/${binaryName} \
        "''${gappsWrapperArgs[@]}" \
        --prefix XDG_DATA_DIRS : "${gtk3}/share/gsettings-schemas/${gtk3.name}/" \
        --prefix LD_LIBRARY_PATH : ${libPath}

    ln -s $out/opt/${binaryName}/${binaryName} $out/bin/
    ln -s $out/opt/${binaryName}/discord.png $out/share/pixmaps/${pname}.png

    ln -s "${desktopItem}/share/applications" $out/share/

      mv $out/bin/Discord $out/bin/.Discord

    cat > $out/bin/discord <<EOF
    if [ ! -d \$HOME/.config/discord ]; then
      echo 'Ricing Discord!'
      echo -n "Downloading modules... "
      ${xvfb_run}/bin/xvfb-run $out/bin/.Discord &> /dev/null
      echo "DONE"
      echo -n "Unpacking modules... "
      ( ${xvfb_run}/bin/xvfb-run $out/bin/.Discord &> /dev/null ) & sleep 5 ; kill $!  &> /dev/null
      echo "DONE"
      echo -n "Ricing... "
      ${beautiful-discord}/bin/beautifuldiscord --css ${./custom.css} &> /dev/null
      echo "DONE"
    fi
    $out/bin/.Discord
    EOF

    chmod +x $out/bin/discord
  '';

  desktopItem = makeDesktopItem {
    name = pname;
    exec = "discord";
    icon = pname;
    inherit desktopName;
    genericName = meta.description;
    categories = "Network;InstantMessaging;";
    mimeType = "x-scheme-handler/discord";
  };

  passthru.updateScript = ./update-discord.sh;

  meta = with stdenv.lib; {
    description = "All-in-one cross-platform voice and text chat for gamers";
    homepage = "https://discordapp.com/";
    downloadPage = "https://discordapp.com/download";
    license = licenses.unfree;
    maintainers = with maintainers; [ ldesgoui MP2E tadeokondrak ];
    platforms = [ "x86_64-linux" ];
  };
}
