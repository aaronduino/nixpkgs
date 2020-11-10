{ lib, stdenv, spicetify-cli, spotify, spotify-unwrapped

  # Path to folder containing `user.css` and `color.ini`. For examples, see:
  # https://github.com/morpheusthewhite/spicetify-themes
, theme ? null
}:

let
  themeOrDefault = if theme != null then theme else "${spicetify-cli.src}/Themes/SpicetifyDefault";

  spotify-spiced = stdenv.mkDerivation {
    pname = "spotify-spiced";
    inherit (spotify-unwrapped) version;

    src = spotify-unwrapped;

    patchPhase = ''
      for f in ./bin/spotify ./share/spotify/spotify; do
        sed -i "s#${spotify-unwrapped}#$out#g" "$f"
      done
    '';

    buildPhase = ''
      mkdir -p /tmp/spicetify-config
      export XDG_CONFIG_HOME=/tmp/spicetify-config
      ${spicetify-cli}/bin/spicetify-cli config spotify_path "$(pwd)/share/spotify"
      ${spicetify-cli}/bin/spicetify-cli config prefs_path /dev/null
      cp -r ${themeOrDefault} /tmp/spicetify-config/spicetify/Themes/SpicetifyDefault
      ${spicetify-cli}/bin/spicetify-cli backup apply
    '';

    installPhase = ''
      mkdir -p $out
      cp -r ./* $out
    '';

    meta = with lib; {
      description = "Wrapper to apply custom theme to Spotify using spicetify-cli";
      homepage = "https://github.com/khanhas/spicetify-cli/";
      license = licenses.unfree;
      maintainers = with maintainers; [ aaronjanse ];
    };
  };

in spotify.override { spotify-unwrapped = spotify-spiced; }
