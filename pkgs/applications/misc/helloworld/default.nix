{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "hellowor;d";
  version = "2.10";

  src = builtins.toFile "main.c" ''
    #include <stdio.h>
    int main(void) {
        printf("Hello, world!\n");
        return 0;
    }
  '';

  phases = [ "buildPhase" ];
  buildPhase = ''
    mkdir -p $out/bin
    gcc -o $out/bin/helloworld $src
  '';

  doCheck = true;

  meta = with stdenv.lib; {
    description = "A simple C program that prints \"Hello, world!\".";
    maintainers = [ maintainers.aaronjanse ];
    platforms = platforms.all;
  };
}
