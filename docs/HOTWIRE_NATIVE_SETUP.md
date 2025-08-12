# Hotwire Native Setup for iOS

This guide will help you set up Hotwire Native to create a native iOS app that works with your Rails Hotwire backend.

## What's Already Set Up

Your Rails application is already configured with:

- ✅ **Hotwire/Turbo Rails** - For SPA-like navigation
- ✅ **Stimulus** - For JavaScript interactions
- ✅ **Tailwind CSS** - For mobile-optimized styling
- ✅ **Mobile-friendly views** - Responsive design for iOS
- ✅ **RESTful API endpoints** - For stories and comments
- ✅ **Real-time updates** - Turbo Streams for live comment updates

## iOS App Setup

### 1. Install Xcode

Make sure you have Xcode installed on your Mac (required for iOS development).

### 2. Install Turbo iOS

```bash
# Create a new iOS project directory
mkdir Storytime-iOS
cd Storytime-iOS

# Install Turbo iOS using Swift Package Manager
# Add this to your Xcode project: https://github.com/hotwired/turbo-ios
```

### 3. Create the iOS App

1. Open Xcode
2. Create a new iOS App project
3. Add Turbo iOS as a dependency:
   - File → Add Package Dependencies
   - Enter: `https://github.com/hotwired/turbo-ios`
   - Select the latest version

### 4. Configure the iOS App

Create a basic Turbo iOS app structure:

```swift
// AppDelegate.swift
import UIKit
import Turbo

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
}

// SceneDelegate.swift
import UIKit
import Turbo

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        let navigationController = UINavigationController()
        let coordinator = TurboCoordinator(navigationController: navigationController)
        
        coordinator.route("/")
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        self.window = window
    }
}

// TurboCoordinator.swift
import Turbo

class TurboCoordinator: NSObject {
    private let navigationController: UINavigationController
    private let session = Session()
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        super.init()
        
        session.delegate = self
    }
    
    func route(_ path: String) {
        let url = URL(string: "http://localhost:3000\(path)")!
        let visitable = VisitableViewController(url: url)
        navigationController.pushViewController(visitable, animated: true)
        session.visit(visitable)
    }
}

extension TurboCoordinator: SessionDelegate {
    func session(_ session: Session, didProposeVisit proposal: VisitProposal) {
        let visitable = VisitableViewController(url: proposal.url)
        navigationController.pushViewController(visitable, animated: true)
        session.visit(visitable)
    }
    
    func session(_ session: Session, didFailRequestForVisitable visitable: Visitable, error: Error) {
        // Handle errors
        print("Session failed: \(error)")
    }
}
```

### 5. Configure Your Rails App for iOS

Your Rails app needs to be accessible from iOS. Update your development configuration:

```ruby
# config/environments/development.rb
Rails.application.configure do
  # Allow connections from iOS Simulator
  config.hosts << "localhost"
  config.hosts << "127.0.0.1"
  config.hosts << "10.0.2.2" # For Android emulator if needed
  
  # Enable CORS for mobile apps
  config.middleware.insert_before 0, Rack::Cors do
    allow do
      origins '*'
      resource '*', headers: :any, methods: [:get, :post, :put, :patch, :delete, :options, :head]
    end
  end
end
```

Add the CORS gem to your Gemfile:

```ruby
# Gemfile
gem 'rack-cors'
```

### 6. Mobile-Optimized Features

Your Rails app already includes these mobile-friendly features:

#### Navigation
- Back buttons with proper iOS styling
- Native-like navigation patterns
- Touch-friendly button sizes

#### Forms
- Mobile-optimized input fields
- Touch-friendly submit buttons
- Proper keyboard handling

#### Real-time Updates
- Turbo Streams for live comment updates
- No page refreshes needed
- Smooth animations

#### Responsive Design
- Tailwind CSS for mobile-first design
- Proper viewport meta tags
- Touch-friendly interface elements

## Testing Your Setup

### 1. Start Your Rails Server

```bash
./bin/dev
```

This starts both Rails and Tailwind CSS compilation.

### 2. Test in iOS Simulator

1. Open your iOS project in Xcode
2. Select an iOS Simulator (iPhone 14, etc.)
3. Build and run the project
4. The app should load your Rails app at `http://localhost:3000`

### 3. Test Native Features

- **Navigation**: Swipe back gestures should work
- **Forms**: Comment creation should work seamlessly
- **Real-time updates**: New comments should appear without refresh
- **Responsive design**: UI should look native on iOS

## Advanced Configuration

### 1. Custom Navigation

You can customize the iOS navigation behavior:

```swift
// Customize navigation appearance
navigationController.navigationBar.prefersLargeTitles = true
navigationController.navigationBar.tintColor = UIColor.systemBlue
```

### 2. Handle Native Features

Add native iOS features like:

```swift
// Share functionality
func shareStory(_ url: URL) {
    let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
    present(activityViewController, animated: true)
}

// Camera integration
func takePhoto() {
    let imagePicker = UIImagePickerController()
    imagePicker.sourceType = .camera
    present(imagePicker, animated: true)
}
```

### 3. Offline Support

Configure offline behavior:

```swift
// Cache configuration
let configuration = URLSessionConfiguration.default
configuration.requestCachePolicy = .returnCacheDataElseLoad
session = Session(configuration: configuration)
```

## Deployment

### 1. Production Rails App

Deploy your Rails app to a production server (Heroku, Railway, etc.)

### 2. Update iOS App

Update the base URL in your iOS app:

```swift
// Change from localhost to your production URL
let url = URL(string: "https://your-app.herokuapp.com\(path)")!
```

### 3. App Store Submission

- Configure app icons and metadata
- Test thoroughly on real devices
- Submit to App Store Connect

## Troubleshooting

### Common Issues

1. **CORS Errors**: Make sure rack-cors is configured properly
2. **Network Issues**: Check that your Rails app is accessible from iOS
3. **Styling Issues**: Ensure Tailwind CSS is compiled
4. **Navigation Problems**: Verify Turbo is working correctly

### Debug Tips

- Use Safari Web Inspector for iOS Simulator debugging
- Check Rails logs for API requests
- Test in different iOS Simulator sizes
- Verify all Turbo Stream responses are working

## Next Steps

1. **Authentication**: Add user authentication (Devise, etc.)
2. **Push Notifications**: Implement push notifications for new comments
3. **Offline Mode**: Add offline support with local caching
4. **Native Features**: Integrate camera, location, and other iOS features
5. **App Store**: Prepare for App Store submission

Your Rails app is now ready for Hotwire Native! The mobile-optimized views and real-time features will provide a native-like experience on iOS.
