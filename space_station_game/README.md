# Space Station Game - Flutter

A complete Flutter port of the classic Space Invaders game, optimized for mobile and tablet deployment on TestFlight.

## Features

- Classic Space Invaders gameplay
- Touch controls optimized for mobile/tablet
- Smooth 60 FPS gameplay
- Audio effects and background music
- Bobbing animation effects
- Lives and scoring system
- Multiple alien types with different point values
- Obstacle blocks for cover
- Extra alien bonus ships

## Game Controls

### Touch Controls (Mobile/Tablet)

- **Left half of screen**: Move spaceship left
- **Right half of screen (upper portion)**: Move spaceship right
- **Bottom 20% of screen**: Shoot laser
- **Drag**: Continuous movement

### Home Screen

- Tap anywhere to start the game

## Project Structure

```
space_station_game/
├── assets/
│   ├── audio/          # Sound effects and music
│   ├── graphics/       # Game sprites and backgrounds
│   └── font/           # Custom pixel font
├── lib/
│   └── main.dart       # Main game implementation
├── ios/                # iOS configuration
├── android/            # Android configuration
└── pubspec.yaml        # Flutter dependencies
```

## Testing Locally

### iOS Simulator

```bash
flutter run --debug
```

### Android Emulator

```bash
flutter run --debug
```

## TestFlight Deployment

### Prerequisites

1. Apple Developer Program membership ($99/year)
2. Xcode installed on macOS
3. Flutter development environment

### Step 1: Configure Bundle ID

Update the bundle identifier in `ios/Runner/Info.plist`:

```xml
<key>CFBundleIdentifier</key>
<string>com.yourcompany.spacestation</string>
```

### Step 2: Configure App in App Store Connect

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Create a new app
3. Set Bundle ID to match the one in Info.plist
4. Configure TestFlight testing

### Step 3: Code Signing

1. Open the project in Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```
2. Select the Runner target
3. Go to Signing & Capabilities
4. Select your development team
5. Let Xcode create the necessary certificates and profiles

### Step 4: Build for TestFlight

```bash
flutter build ios --release
```

### Step 5: Archive and Upload

1. Open the project in Xcode
2. Product → Archive
3. Once archived, click "Distribute App"
4. Select "TestFlight & App Store"
5. Follow the prompts to upload to TestFlight

### Step 6: Invite Testers

1. In App Store Connect, go to your app
2. Select TestFlight → Testers
3. Add tester emails
4. Send invitations

## Game Mechanics

- **Player**: Spaceship that can move left/right and shoot lasers
- **Aliens**: Move in formation, shoot lasers, move down when hitting screen edges
- **Obstacles**: Orange blocks that provide cover
- **Extra Alien**: Bonus ship that appears occasionally
- **Lives**: 3 lives, lose one when hit by alien laser
- **Scoring**: Points for destroying aliens (yellow: 500, green: 300, red: 100, extra: 500)
- **Victory**: Destroy all aliens to win
- **Game Over**: Lose all lives or let aliens reach the bottom

## Technical Details

- **Framework**: Flutter
- **Language**: Dart
- **Target Platforms**: iOS (TestFlight), Android
- **Orientation**: Landscape only
- **Audio**: audioplayers package
- **Game Loop**: 60 FPS using Timer
- **Collision Detection**: Rectangle-based collision system
- **Animations**: Sine wave bobbing effects

## Troubleshooting

### Common Issues

1. **Code Signing Errors**: Ensure you have a valid Apple Developer account and certificates
2. **Bundle ID Mismatch**: Make sure the bundle ID matches between Xcode and App Store Connect
3. **Audio Not Playing**: Check device volume and ensure audio files are in the correct assets folder
4. **Performance Issues**: The game is optimized for 60 FPS, but older devices may experience slowdown

### Build Issues

```bash
# Clean and rebuild
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter build ios --release
```

## License

This project maintains the same license as the original Space Station game.
