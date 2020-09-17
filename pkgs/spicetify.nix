{ buildGoModule, fetchFromGitHub, lib }:

buildGoModule rec {
  pname = "spicetify-cli";
  version = "0.9.6";

  src = fetchFromGitHub {
    owner = "khanhas";
    repo = "spicetify-cli";
    rev = "v${version}";
    sha256 = "1v29qscbrzx810pbgwspxfwcrl7kl3k9r04rb3l6kbs1s3rn3hmi";
  };

  vendorSha256 = "1q6vvy2xz2wm2wzpjk04hbfmsjm72wfa3kxfnnc8b4gxhdhw50q0";

  postInstall = ''
    cp -r jsHelper $out/bin
  '';

  meta = with lib; {
    description = "Make Spotify look good!";
    homepage = https://github.com/khanhas/spicetify-cli;
    maintainers = with maintainers; [ aaronjanse ];
  };
}
