## Discord
- write BeautifulDiscord derivation
- overlay discord, add `fixupPhase`
  - wrap binary to on first run:
  - run headless
  - apply patches via BD
  - run actual discord exec

## Spotify
- write spicetify-cli derivation
- overlay spotify, add `fixupPhase`
  - apply patches via spicetify-cli

## Signal
- overlay, add `fixupPhase`
  - run `sed` script on `app.asar`
