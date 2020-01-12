{ writeText, python36Packages, fetchFromGitHub, ... }:

python36Packages.buildPythonApplication rec {
  pname = "beautifuldiscord";
  version = "1.0";
  src = fetchFromGitHub {
    owner = "leovoel";
    repo = "BeautifulDiscord";
    rev = "3b77e91b4c62e431e579fa594746753b3cd7fd69";
    sha256 = "0l2lg4ana942dgymjj4knglqsj1q1ixvmc9q30y73wcgjg97iq10";
  };
  patches = [
    (
      writeText "fix-executable-finder.patch" ''
        diff --git a/beautifuldiscord/app.py b/beautifuldiscord/app.py
        index fbb92d5..a53c02d 100644
        --- a/beautifuldiscord/app.py
        +++ b/beautifuldiscord/app.py
        @@ -72,7 +72,7 @@ class DiscordProcess:
                     # To get the version number we have to iterate over ~/.config/discordcanary and find the
                     # folder with the highest version number
                     discord_version = os.path.basename(self.path).replace('-', ''')
        -            config = os.path.expanduser(os.path.join(os.getenv('XDG_CONFIG_HOME', '~/.config'), discord_version))
        +            config = os.path.expanduser(os.path.join(os.getenv('XDG_CONFIG_HOME', '~/.config'), 'discord'))
 
                     versions_found = {}
                     for subdirectory in os.listdir(config):
        @@ -151,6 +151,7 @@ def discord_process():
                 except (psutil.Error, OSError):
                     pass
                 else:
        +            exe = exe.replace('.Discord-wrapped', 'Discord') # fix for nixos
                     if exe.startswith('Discord') and not exe.endswith('Helper'):
                         entry = executables.get(exe)
      ''
    )
  ];
  doCheck = false;
  propagatedBuildInputs = with python36Packages; [ psutil ];
}
