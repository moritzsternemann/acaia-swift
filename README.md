# acaia-swift

*Interact with [Acaia smart scales](https://acaia.co/collections/coffee-scales) via Bluetooth in Swift*

> ⚠️ This project is a work in progress and not recommended for production use. It is only tested with a 2021 Acaia Lunar and currently doesn't support older generation scales.

## Overview

The `AcaiaProtocol` library implements decoding of received values and encoding of commands. Note that the Bluetooth communication itself is not implemented yet.

The following values can be decoded:
- Scale status (battery level, weight unit, weighing mode, etc.)
- Weight (including stable-indicator)
- Battery level update
- Timer update

The following commands can be encoded:
- *none*

## Credits

This project is heavily inspired by [lucapinello/pyacaia](https://github.com/lucapinello/pyacaia) and extended with my own findings from reverse-engineering the protocol.

## Contribute

Do you know anything more about the protocol? Have you found a bug? I am happy about all code contributions. Or just open an issue with a short description of your findings.
