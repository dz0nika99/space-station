# Space Station - Native Swift iOS Game

A native Swift iOS implementation of the classic Space Station game, originally created in Python/Pygame and Flutter. This version faithfully replicates all the original gameplay mechanics, controls, and behavior from the Pygame version while providing a smooth native iOS experience with SpriteKit.

## Features

- **Classic Gameplay**: Control a spaceship to defend against alien invaders
- **Multiple Alien Types**: Yellow (500pts), Green (300pts), Red (100pts) aliens
- **Obstacle Barriers**: Destructible blocks provide cover and strategy
- **Special Aliens**: Bonus aliens that occasionally appear from the sides (500pts)
- **Lives System**: Start with 3 lives, lose one when hit by alien lasers
- **Scoring System**: Points for destroying different alien types
- **Audio**: Background music, laser sounds, and explosion effects
- **Touch Controls**: Intuitive touch controls optimized for mobile
- **Victory/Loss Conditions**: Win by destroying all aliens, lose by running out of lives or letting aliens reach you

## Controls

### Touch Controls (Primary)
- **Left Half Screen**: Move spaceship left
- **Right Half Top**: Move spaceship right
- **Bottom 20%**: Shoot lasers
- **Tap on Home/Game Over/Victory Screen**: Start new game

### Visual Elements
- **Score**: Displayed in top-left corner
- **Lives**: Spaceship icons showing remaining lives (top-right)
- **Animated Home Screen**: Displays when game is not active

## Game Mechanics

### Player
- Spaceship moves horizontally at the bottom of the screen
- Fires white lasers upward with cooldown
- Has bobbing animation for visual appeal
- Cannot move outside screen boundaries

### Aliens
- Arranged in a 7x11 grid formation
- Move horizontally as a group, dropping down when reaching screen edges
- Different colors have different point values
- Randomly shoot lasers downward
- Bob up and down for visual effect

### Obstacles
- Orange blocks form barriers in front of the player
- Can be destroyed by both player and alien lasers
- Aliens destroy blocks when they collide with them

### Special Features
- **Extra Aliens**: Occasionally spawn from left or right side for bonus points
- **Collision Detection**: Physics-based collision system
- **Audio Feedback**: Sound effects for all major actions
- **Background Music**: Continuous gameplay soundtrack

## Technical Implementation

### Architecture
- **UIKit + SpriteKit**: Native iOS game framework for optimal performance
- **MVC Pattern**: Model-View-Controller architecture
- **Physics-Based Collisions**: SpriteKit physics engine for accurate collision detection
- **Resource Management**: Proper asset loading and memory management

### Key Classes
- `GameScene`: Main game scene managing all game logic
- `Player`: Player spaceship with movement and shooting
- `Alien`: Enemy aliens with different types and behaviors
- `Laser`: Projectiles for both player and aliens
- `Block`: Obstacle barriers
- `Extra`: Bonus aliens

## Requirements

- iOS 14.0+
- Xcode 14.0+
- Swift 5.7+

## Building and Running

**Note:** This is a native iOS application that requires Xcode to build and run. Swift Package Manager cannot build iOS apps with UIKit and SpriteKit frameworks.

### Using Xcode (Required)

1. **Open the project in Xcode:**
```bash
cd space_station_native
open SpaceStation.xcodeproj
```

2. **Select a target device:**
   - Choose an iOS Simulator (iPhone or iPad)
   - Or connect a physical iOS device

3. **Build and run:**
   - Press `⌘+R` or click the Run button
   - The app will launch in landscape orientation

### Requirements for Building

- **Xcode 14.0+** with iOS SDK
- **macOS** (iOS development requires macOS)
- **iOS 14.0+** compatible device or simulator

### Troubleshooting

If you encounter build errors:
1. Clean the build folder: `⌘+Shift+K`
2. Clean derived data: Xcode → Product → Clean Build Folder
3. Restart Xcode
4. Ensure you're using a recent version of Xcode

## Project Structure

```
space_station_native/
├── Package.swift                    # Swift Package Manager configuration
├── SpaceStation/
│   ├── Sources/
│   │   ├── AppDelegate.swift        # Application lifecycle
│   │   ├── SceneDelegate.swift      # Scene lifecycle
│   │   ├── Controllers/
│   │   │   └── GameViewController.swift  # Main game view controller
│   │   ├── Models/
│   │   │   ├── Player.swift         # Player spaceship logic
│   │   │   ├── Alien.swift          # Alien enemy logic
│   │   │   ├── Laser.swift          # Projectile logic
│   │   │   ├── Block.swift          # Obstacle logic
│   │   │   └── Extra.swift          # Bonus alien logic
│   │   ├── Views/
│   │   │   └── GameScene.swift      # Main SpriteKit scene
│   │   └── Utilities/
│   │       ├── GameSceneDelegate.swift  # Scene delegate protocol
│   │       └── PhysicsCategory.swift    # Physics collision categories
│   └── Resources/
│       ├── Base.lproj/
│       │   ├── Main.storyboard       # Main interface
│       │   └── LaunchScreen.storyboard  # Launch screen
│       ├── Info.plist               # App configuration
│       ├── Audio/                   # Sound effects and music
│       ├── Graphics/                # Sprite images
│       └── Fonts/                   # Custom fonts
```

## Assets

The game uses the following assets from the original Python version:
- **Graphics**: Spaceship, aliens (red/green/yellow), background, extra alien, home screen
- **Audio**: Laser sound, explosion sound, background music
- **Fonts**: Pixeled.ttf for retro-style text

## Differences from Original

While maintaining all core gameplay mechanics, this Swift version includes:
- **Native Performance**: Optimized for iOS with SpriteKit
- **Touch-First Controls**: Designed primarily for touch interaction
- **iOS Integration**: Proper app lifecycle, pause/resume, orientation handling
- **Modern Swift**: Uses current Swift language features and best practices

## Future Enhancements

Potential improvements for future versions:
- iPad support with adjusted layouts
- Additional alien patterns and behaviors
- Power-ups and special abilities
- Leaderboards and achievements
- Multiple difficulty levels
- Customizable controls

## Implementation Notes

This Swift implementation has been carefully reverse-engineered from the original Python/Pygame version to ensure complete feature parity:

- **Game Mechanics**: All alien movement patterns, collision detection, scoring, and win/lose conditions match exactly
- **Controls**: Touch controls replicate the Pygame mouse/touch behavior
- **Timing**: All timers, cooldowns, and animation timings use the same values as the original
- **Visual Layout**: Alien grid positioning, obstacle placement, and UI element positioning match the original
- **Audio**: Sound effects and background music playback with original volume levels
- **Game States**: Home screen, gameplay, victory, and game over states behave identically

### Key Technical Mappings

| Pygame Component | Swift/SpriteKit Equivalent |
|------------------|---------------------------|
| `pygame.sprite.Group` | Arrays of custom classes |
| `pygame.time.get_ticks()` | `Date.timeIntervalSinceReferenceDate * 1000` |
| `pygame.mixer.Sound` | `AVAudioPlayer` |
| Surface blitting | `SKNode` positioning and `SKSpriteNode` |
| Rectangle collision | SpriteKit physics contacts |
| Event-driven updates | Frame-based `update()` method |

## Credits

Original game concept and assets from the Python/Pygame version.
Native Swift implementation maintains all original gameplay while optimizing for iOS platforms.
