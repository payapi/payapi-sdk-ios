# PayApi SDK for iOS

Swift implementation of [PayApi Secure Form](https://payapi.io/apidoc/#api-Payments-PostSecureForm).

## Contents

Includes an easy-to-use PayApi SDK for any iOS application, working with Swift.
In order to use the SDK, please register for a free [PayApi user account](https://input.payapi.io)

## Installation

[CocoaPods](http://cocoapods.org/) is the recommended installation method.

```ruby
pod 'PayApiSDK'
```

## Usage

```swift
import PayApiSDK
```

### Initialization
Initialize SDK with your credentials (Public Id and PayApi key)
```swift
let secureForm = SecureForm(publicId: "SHOP_PUBLIC_ID", apiKey: "PROVIDED_API_KEY")
```

### Building a product data dictionary

```swift
let productData: [String: Any] = [
  "order": [
    "sumInCentsIncVat": 122,
    "sumInCentsExcVat": 100,
    "vatInCents": 22,
    "currency": "EUR",
    "referenceId": "ref123"
  ],
  "products": [
    [
      "quantity": 1,
      "title": "Black bling cap",
      "priceInCentsIncVat": 122,
      "priceInCentsExcVat": 100,
      "vatInCents": 22,
      "vatPercentage": 22
    ]
  ],
  "consumer": [
    "email": "support@payapi.io"
  ]
]
```

### Adding functionality to a button

Method to open the Secure Form on any UIButton TouchUpInside event

```swift
secureForm.addSecureFormToButton(button: myButton, message: productData)
```

## Questions?

Please contact support@payapi.io for any questions.
