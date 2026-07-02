# FaceOnLive — ID Recognition SDK for iOS

On-device ID document recognition (OCR, MRZ, and portrait extraction) for iOS. Scan passports, national ID cards, and driver's licenses entirely on the device.

> Part of the [FaceOnLive](https://faceonlive.com) on-premises biometric SDK suite.

## Features
- Extract text fields, MRZ, and the portrait photo from an ID.
- On-device and offline — no data leaves the phone.
- Camera and photo-library input; structured JSON output.

## Requirements
| | |
|---|---|
| Min iOS | 13.0+ |
| Language | Swift |
| IDE | Xcode 14+ |
| Framework | `idsdk.framework` (included) |

## Setup
1. Open the project in **Xcode**.
2. Get a license key — free trial at **https://faceonlive.com**.
3. In `IDCardRecognition/ViewController.swift`, replace `<YOUR_LICENSE_KEY>` in `IDSDK.setActivation(...)`.
4. Build and run on a device.

## Quick start
```swift
var ret = IDSDK.setActivation("<YOUR_LICENSE_KEY>")
if ret == SDK_SUCCESS.rawValue {
    ret = IDSDK.initSDK()
}

let json = IDSDK.idcardRecognition(image)   // JSON string with recognized fields
```

## API reference
| Method | Description | Returns |
|---|---|---|
| `setActivation(license)` | Activate with your license key. | `SDK_SUCCESS` or error |
| `initSDK()` | Load the recognition models. | `SDK_SUCCESS` or error |
| `idcardRecognition(image)` | Recognize an ID document in the image. | JSON string, or `nil` |

**Result JSON:** `Document Name`, `Issuing State Code`, `Full Name`, `MRZ`, and an `Images` object with base64 `Portrait` and `Document` crops.

## License & support
Requires a valid license key — get one at **[faceonlive.com](https://faceonlive.com)**. Never commit your key. Questions: contact@faceonlive.com

## 📦 Full SDK download
This repository contains the source/demo code only. Download the complete SDK — engine libraries and models, with full project structure — from the [Releases](../../releases) page and extract it over this project.
