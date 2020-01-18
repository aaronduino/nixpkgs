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
index fbb92d5..26335e8 100644
--- a/beautifuldiscord/app.py
+++ b/beautifuldiscord/app.py
@@ -16,11 +16,13 @@ class DiscordProcess:
         self.processes = []
 
     def terminate(self):
+        return
         for process in self.processes:
             # terrible
             process.kill()
 
     def launch(self):
+        return
         with open(os.devnull, 'w') as f:
             subprocess.Popen([os.path.join(self.path, self.exe)], stdout=f, stderr=subprocess.STDOUT)
 
@@ -71,8 +73,8 @@ class DiscordProcess:
             # The modules are under ~/.config/discordcanary/0.0.xx/modules/discord_desktop_core
             # To get the version number we have to iterate over ~/.config/discordcanary and find the
             # folder with the highest version number
-            discord_version = os.path.basename(self.path).replace('-', ''')
-            config = os.path.expanduser(os.path.join(os.getenv('XDG_CONFIG_HOME', '~/.config'), discord_version))
+            # discord_version = os.path.basename(self.path).replace('-', ''')
+            config = os.path.expanduser(os.path.join(os.getenv('XDG_CONFIG_HOME', '~/.config'), 'discord'))
 
             versions_found = {}
             for subdirectory in os.listdir(config):
@@ -151,6 +153,7 @@ def discord_process():
         except (psutil.Error, OSError):
             pass
         else:
+            exe = exe.replace('.Discord-wrapped', 'Discord') # fix for nixos
             if exe.startswith('Discord') and not exe.endswith('Helper'):
                 entry = executables.get(exe)
 
@@ -212,7 +215,7 @@ def allow_https():
 def main():
     args = parse_args()
     try:
-        discord = discord_process()
+        discord = DiscordProcess(path=None, exe=None)
     except Exception as e:
         print(str(e))
         return
      ''
    )
  ];
  doCheck = false;
  propagatedBuildInputs = with python36Packages; [ psutil ];
}
