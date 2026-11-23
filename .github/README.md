[![GitHub Release](https://img.shields.io/github/v/release/claration/Feather?include_prereleases)](https://github.com/claration/Feather/releases)
[![GitHub Downloads (all assets, all releases)](https://img.shields.io/github/downloads/claration/Feather/total)](https://github.com/claration/Feather/releases)
[![GitHub License](https://img.shields.io/github/license/claration/Feather?color=%23C96FAD)](https://github.com/claration/Feather/blob/main/LICENSE)
[![Sponsor Me](https://img.shields.io/static/v1?label=Sponsor&message=%E2%9D%A4&logo=GitHub&color=%23fe8e86)](https://github.com/sponsors/khcrysalis)

<div align="center">

<img title="Feather" alt="Feather" height="180" src="landing.png">

Sideloading app meant for developer certificates.

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="demo-dark.png"><source media="(prefers-color-scheme: light)" srcset="demo-light.png"><img alt="Feather" src="demo-light.png"></picture></p>


</div>

## Features

- User friendly, and clean UI.
- Sign and install applications.
- Supports [AltStore](https://faq.altstore.io/distribute-your-apps/make-a-source#apps) repositories.
- View detailed information about apps and your certificates.
- Configurable signing options mainly for modifying the app, such as appearance and allowing support for the files app.
  - This includes patching apps for compatibility and Liquid Glass.
- Tweak support for advanced users, using [Ellekit](https://github.com/tealbathingsuit/ellekit) for injection. 
  - Supports injecting `.deb` and `.dylib` files.
- Actively maintained: always ensuring most apps get installed properly.
- No tracking or analytics, ensuring user privacy.
- Of course, open source and free.

## Download

Visit [releases](https://github.com/claration/Feather/releases) and get the latest `.ipa`.

<a href="https://celloserenity.github.io/altdirect/?url=https://raw.githubusercontent.com/claration/Feather/refs/heads/main/app-repo.json" target="_blank">
   <img src="https://github.com/CelloSerenity/altdirect/blob/main/assets/png/AltSource_Blue.png?raw=true" alt="Add AltSource" width="200">
</a>
<a href="https://github.com/claration/Feather/releases/latest/download/Feather.ipa" target="_blank">
   <img src="https://github.com/CelloSerenity/altdirect/blob/main/assets/png/Download_Blue.png?raw=true" alt="Download .ipa" width="200">
</a>

## Translating

Feather now has translation support, all localizations are located in `Feather/Resources/Localizable.xcstrings`.

To add a new language, open Xcode and use the interface to add/contribute to languages.

To properly contribute and test potentially test localizations, you can head over to the [contributing guide](./CONTRIBUTING.md).

## Sponsors

| Thanks to all my [sponsors](https://github.com/sponsors/claration)!! |
|:--------------------------------------------------------------------:|
| <img src="https://sponsors.claration.dev/sponsors.png">              |
| _**"samara is cute" - Vendicated**_                                  |

## Acknowledgements

- [Samara](https://github.com/claration) - The maker
- [idevice](https://github.com/jkcoxson/idevice) - Backend for builds with this included, used for communication with `installd`.
- [*.backloop.dev](https://backloop.dev/) - localhost with public CA signed SSL certificate
- [Vapor](https://github.com/vapor/vapor) - A server-side Swift HTTP web framework.
- [Zsign](https://github.com/zhlynn/zsign) - Allowing to sign on-device, reimplimented to work on other platforms such as iOS.
- [LiveContainer](https://github.com/LiveContainer/LiveContainer) - Fixes/some help
- [Nuke](https://github.com/kean/Nuke) - Image caching.
- [Asspp](https://github.com/Lakr233/Asspp) - Some code for setting up the http server.
- [plistworker](https://github.com/palera1n/plistworker) - Hosted on https://api.palera.in, This repository is the new repository for plistserver (now plistworker), the original repository is going to be abandoned due to the current owner not wanting to transfer because of the stars, even though I asked them to fork it in the first place, and it being primarily used for [Feather](https://github.com/claration/feather)'s userbase.

## License 

This project is licensed under the GPL-3.0 license. You can see the full details of the license [here](https://github.com/claration/Feather/blob/main/LICENSE). It's under this specific license because I wanted to make a project that is transparent to the user thats related to certificate paired sideloading, before this project there weren't any open source projects that filled in this gap.

By contributing to this project, you agree to license your code under the GPL-3.0 license as well (including agreeing to license exceptions), ensuring that your work, like all other contributions, remains freely accessible and open.
