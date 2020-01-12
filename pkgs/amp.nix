{ stdenv
, fetchFromGitHub
, rustPlatform
, openssl
, pkgconfig
, python3
, xorg
, cmake
, libgit2
, darwin
, curl
}:

rustPlatform.buildRustPackage rec {
  pname = "amp";
  # The latest release (0.5.2) does not compile, so we use a git snapshot instead.
  version = "unstable-2019-06-09";

  src = fetchFromGitHub {
    owner = "jmacdonald";
    repo = pname;
    rev = "cc74f0e2e1da010de2527c42c25696a8f0f9bb85";
    sha256 = "1zkhfinrplplgay0yzpwz655gjhfwp29ld1wlkyj8pj69y51vh14";
  };

  cargoSha256 = "0rk5c8knx8swqzmj7wd18hq2h5ndkzvcbq4lzggpavkk01a8hlb1";

  nativeBuildInputs = [ cmake pkgconfig ];
  buildInputs = [ openssl python3 xorg.libxcb libgit2 ] ++ stdenv.lib.optionals stdenv.isDarwin
    (with darwin.apple_sdk.frameworks; [ curl Security AppKit ]);

  # Tests need to write to the theme directory in HOME.
  preCheck = "export HOME=`mktemp -d`";

  meta = with stdenv.lib; {
    description = "A modern text editor inspired by Vim";
    homepage = "https://amp.rs";
    license = [ licenses.gpl3 ];
    maintainers = [ maintainers.sb0 ];
    platforms = platforms.unix;
  };
}
