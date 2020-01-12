with import <nixpkgs> {};

stdenv.mkDerivation rec {
  name = "glslviewer-${version}";
  version = "2018-01-31";

  src = fetchFromGitHub {
    owner = "hsoft";
    repo = "dupeguru";
    rev = "9eb15509c190dc5713f68eccced179eb069e6e34";
    sha256 = "1bykpp68hdxjlxvi1xicyb6822mz69q0adz24faaac372pls4bk0";
  };

  # nativeBuildInputs = [ pkgconfig ensureNewerSourcesForZipFilesHook ];
  buildInputs = (
    with pkgs; [
      qt5.qtbase
      glfw3
      pkgconfig
      libGLU
      python36
    ]
  ) ++ (
    with pkgs.xorg; [
      libXrandr
      libXxf86vm
      libXcursor
      libXinerama
      libXdamage
    ]
  ) ++ (
    with python36.pkgs; [
      python
      setuptools
      wrapPython
    ]
  );
  #   ++ stdenv.lib.optional stdenv.isDarwin Cocoa;
  # pythonPath = with python36.pkgs; [ requests ];

  # Makefile has /usr/local/bin hard-coded for 'make install'
  #  \
  #     --replace '/usr/bin/clang++' 'clang++'
  preConfigure = ''
    substituteInPlace Makefile \
        --replace '/usr/local' "$out"
    substituteInPlace Makefile \
        --replace '{DESTDIR}' "out"
    substituteInPlace Makefile \
        --replace 'NO_VENV ?=' "NO_VENV = 1"
    substituteInPlace Makefile \
        --replace '-m compileall' '--prefix=$out --install-dir=$out -m compileall'
  

  '';

  # substituteInPlace Makefile \
  #     --replace 'python setup.py install' "python setup.py install --prefix=$out"

  preInstall = ''
    mkdir -p $out/bin $(toPythonPath "$out")
    export PYTHONPATH=$PYTHONPATH:$(toPythonPath "$out")
  '';

  postInstall = ''
    wrapPythonPrograms
  '';

  meta = with stdenv.lib; {
    description = "Find duplicate files";
    homepage = https://dupeguru.voltaicideas.net/;
    license = licenses.gplv3;
    platforms = platforms.linux; # can support darwin with more work afaik
    maintainers = [ maintainers.hopefully_somebody ];
  };
}
