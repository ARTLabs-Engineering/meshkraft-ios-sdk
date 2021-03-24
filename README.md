# Meshkraft

ART Labs introduces tailor-made AR-commerce. A specially designed, effortless, 3D-powered boost for eCommerce.

## Installation
### CocoaPods

To integrate Meshkraft into your Xcode project using [CocoaPods](https://cocoapods.org), add it to your `Podfile`:

```ruby
pod 'Meshkraft'
```

Then, run the following command:

```bash
$ pod install
```
## Usage
### Initialization

1. Import `Meshkraft` framework header in your `AppDelegate`

    ```swift
    import Meshkraft
    ```

2. Add the following to your `AppDelegate` `application:didFinishLaunchingWithOptions:` method.
    
    ```swift
    Meshkraft.setApiKey("YOUR_API_KEY")
    ```

    Make sure to replace `YOUR_API_KEY` with your application token.

### Code Implementation

Import `Meshkraft` framework header

```swift
import Meshkraft
```

#### AR Session

Start an AR session with product SKU:

```swift
Meshkraft.meshkraft().startARSession(productSKU: "YOUR_PRODUCT_SKU")
```

To receive model loading status notifications , conform to `MeshkraftDelegate` protocol:

```swift
Meshkraft.meshkraft().delegate = self
```

```swift
extension ViewController : MeshkraftDelegate {
    
    func modelLoadStarted() {
        print("load started")
        activityIndicator.startAnimating()
    }
    
    func modelLoadFinished() {
        print("load finished")
        activityIndicator.stopAnimating()
    }
    
    func modelLoadFailed(message: String) {
        print("load failed message: \(message)")
        activityIndicator.stopAnimating()
    }
    
}
```

#### Model URL

Get AR model URL with product SKU:
Get the `modelURL` from the completion block, check the `errorMessage` for any possible errors.
```swift
Meshkraft.meshkraft().getModelURL(productSKU: "YOUR_PRODUCT_SKU", completion: {(modelUrl, errorMessage) in
    print("modelUrl: \(modelUrl ?? "")")
    print("errorMessage: \(errorMessage ?? "")")
})
```

#### Device Support

You can check if AR is supported on the device:

```swift
Meshkraft.isARSupported()
```










