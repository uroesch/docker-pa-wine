# Changelog

## 0.7.0 (2019-04-29)

* Release improved logo
* Enable sound using host PulseAudio server and a bind mount to a shared UNIX socket
* Add instructions for using PulseAudio for sound to `README.md`
* Remove Winetricks cache download as it's extremely large and not always necessary

## 0.6.1 (2019-04-25)

* Add logo first draft
* Improve license formatting
* Add `license.md` with reference to `LICENSE`

## 0.6.0 (2019-04-25)

### Dockerfile

* Use wine-stable v4.0 instead of wine-staging for more consistent builds
* Remove multi-stages as not using any other targets for builds
* Add Open Container Initiative (OCI) labels
* Add build date and git revision arguments with build hook to generate values on each auto-build on Docker Hub

### Scripts

* Check for `.Xauthority` magic cookie file in both env and user home

### Documentation

* Add `CHANGELOG.md`
* Add `LICENSE`
* Reduce size of `README.md` and improve readability
* Various linting improvements