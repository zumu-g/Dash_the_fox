# Changelog

All notable changes to Dash the Fox will be documented in this file.

## [1.0.0] - 2026-02-05

### Added
- Initial release of Dash the Fox
- Main menu with animated fox preview and PLAY button
- Playable fox character (Dash) with:
  - Orange body, head, ears, and bushy tail
  - White snout and black nose
  - Physics-based movement
- Single level with:
  - 7 platforms at various heights
  - 10 collectible coins with bobbing animation
  - 5 patrolling purple slime enemies
  - Goal flag at the end
- Touch controls:
  - Left arrow button for moving left
  - Right arrow button for moving right
  - Jump button for jumping
- HUD displaying:
  - Coin count
  - Lives (3 hearts)
- Camera system that follows the player
- Win screen when reaching the goal
- Game Over screen when losing all lives
- Retry functionality

### Technical
- Built with SpriteKit and SwiftUI
- Swift Playgrounds compatible (.swiftpm format)
- Targets iOS 15.0+
- Supports iPad and iPhone
- Physics-based collision detection

## Development History

### Initial Complex Version (Removed)
The game was initially developed with extensive features including:
- 6 themed levels
- Multiple enemy types (Spiky, Slime, Bat, Snake, Ghost, Fireball, Boss)
- Power-ups (Speed Boost, Double Jump, Shield, Magnet, Invincibility, Time Freeze)
- Platform types (Normal, Moving, Falling, Bouncy, Icy, Crumbling)
- Shop with 6 fox skins
- Achievements system
- Weather effects
- Checkpoints and trampolines

This version was too complex for Swift Playgrounds and was simplified to ensure compatibility.

### Simplified Version (Current)
The codebase was completely rewritten to be clean, simple, and compatible with Swift Playgrounds while maintaining the core fun gameplay experience.
