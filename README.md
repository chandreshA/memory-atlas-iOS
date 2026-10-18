# Memory Atlas

Memory Atlas is a local-first iOS app for preserving personal memories and exploring the connections between them.

The current app supports creating text-based memories, browsing them chronologically, and opening individual memories to read their full content. The longer-term vision brings journal entries, photographs, places, and books together in a timeline and interactive map.

> In active development. The text-memory foundation is implemented; photo capture, maps, book integration, and other features below are planned, not yet available.

## Available Today

- Create a memory with a title, date, and optional journal note
- Persist memories locally using Core Data, without an account
- Browse memories newest-first by memory date, with month headings
- Open a read-only detail screen showing a memory's full date, title, and optional journal note
- Handle loading, empty, saving, and failure states, including retrying a failed timeline load
- Use an archival visual style with forest greens, parchment textures, floral borders, and ink-wash artwork
- Support Dynamic Type layouts and accessibility labels, with decorative artwork hidden from VoiceOver
- Exercise repository and view-model behavior with XCTest

Editing and deletion are the next steps in completing the core memory flow; neither is implemented yet.

## The Idea

Our lives are connected by more than dates.

A particular book may remind us of a trip. A photograph may belong to a larger chapter of life. Returning to a familiar place can reveal how much has changed.

Memory Atlas is designed to make those connections visible.

## Technology and Engineering Goals

Memory Atlas is also a portfolio project focused on production-minded iOS engineering.

| Area | Current implementation | Planned work |
| --- | --- | --- |
| User interface | SwiftUI timeline, creation form, and memory detail | Editing, media, and map screens |
| UIKit interoperability | Not yet implemented | MapKit through `UIViewRepresentable` |
| Concurrency | Async/await repository operations and view-model workflows | Networking and image loading |
| Networking | Not yet implemented | Book search and metadata API |
| Persistence | Core Data | Local file storage for imported images |
| Architecture | MVVM with an injected repository protocol | Extend abstractions as features require them |
| Unit testing | XCTest for persistence and view models | Coverage for new feature behavior |
| UI testing | XCUITest target with template tests only | Critical user-flow tests; currently deferred |
| Accessibility | Dynamic Type adaptations, labels, and identifiers | Broader VoiceOver verification and a non-map alternative |
| State management | Explicit timeline and memory-creation states | Equivalent handling for future features |

## Architecture

The current implementation separates presentation, domain data, and persistence:

```text
SwiftUI views and view models
    ↓
MemoryRepository protocol / Memory domain model
    ↓
CoreDataMemoryRepository
    ↓
Core Data
```

- **Presentation:** `TimelineViewModel` loads timeline data; `CreateMemoryViewModel` validates input and coordinates saving. SwiftUI views render their state.
- **Domain:** `Memory` represents a memory independently of Core Data. `MemoryRepository` defines async fetch and save operations.
- **Data:** `CoreDataMemoryRepository` uses an injected managed object context, maps persisted entities into domain values, and fetches memories newest-first by memory date.
- **Composition:** `MemoryAtlasApp` creates the persistence stack and injects dependencies.

Tests use in-memory Core Data stores and repository doubles. Networking, image storage, and location dependencies will be introduced when those features are built; they are not part of the current architecture yet.

## Privacy

Personal memories deserve careful handling.

The current app stores text memories on the device, requires no account, and does not request health data.

For planned features:

- Photo import will be limited to photographs explicitly selected by the user.
- Exported archives will remain under the user's control.
- Any future cloud synchronization will be optional.

## Roadmap

### Completed Foundation and Text Capture

- [x] Establish MVVM and repository-based dependency injection
- [x] Define the core memory model
- [x] Configure Core Data persistence
- [x] Add unit and UI test targets (feature UI tests remain outstanding)
- [x] Implement loading, empty, and error-state components
- [x] Create text-based memories with validation and saving feedback
- [x] Display memories chronologically with month headings
- [x] Add repository and view-model unit tests
- [x] Establish the archival visual design for the timeline and creation form
- [x] MA-009: Open a read-only memory detail screen from the timeline

### Next: Complete the Core Memory Flow

- [ ] Edit existing memories
- [ ] Delete memories with confirmation

### Portfolio MVP: Remaining Features

- [ ] Import selected photographs
- [ ] Store and display imported images locally
- [ ] Add search and filtering
- [ ] Attach locations to memories
- [ ] Display memories on a map using UIKit interoperability
- [ ] Provide an accessible list alternative
- [ ] Search for books using a remote API
- [ ] Attach books to memories
- [ ] Add XCTest coverage for new persistence, networking, and view-model behavior
- [ ] Add XCUITest coverage for critical user flows (currently deferred)
- [ ] Verify accessibility and performance across the completed experience

### Later Releases

- [ ] Add map clustering and time-range filtering
- [ ] Create Memory Threads
- [ ] Surface related memories
- [ ] Add On This Day
- [ ] Add Then & Now
- [ ] Export a portable memory archive

## Testing Strategy

Current XCTest coverage includes:

- In-memory Core Data save/fetch behavior, descending memory-date ordering, and optional notes
- Timeline initial, loading, loaded, empty, and failure states
- Memory-creation validation, whitespace normalization, selected dates, injected IDs and timestamps, saving state, and repository failures

Run the `MemoryAtlasTests` tests from Xcode's Test navigator. No live API or external account is required for these tests.

Memory detail also has SwiftUI previews for a populated memory, a title-only memory, and long content at an accessibility text size. These are visual checks, not automated test coverage.

The XCUITest target currently contains template launch/performance tests, not feature-flow coverage. Creating, editing, searching, and deleting flows will receive UI tests as that work is scheduled. Accessibility identifiers are already used in the current screens.

Networking, image-storage, and location tests will use isolated dependencies rather than rely on live services.

## Getting Started

1. Clone the repository:

```bash
git clone https://github.com/chandreshA/memory-atlas-iOS.git
```

2. Open `MemoryAtlas.xcodeproj` in Xcode with support for the project's iOS 26.5 deployment target.
3. Select the `MemoryAtlas` scheme and a compatible iOS simulator.
4. Build and run the application. No API keys or account setup are required for the current features.

For a physical device, select your development team under **Signing & Capabilities** in Xcode.

The project is under active development, so setup requirements may change as features are introduced.

## Project Goals

This project is being built to explore modern iOS development through a product with meaningful technical depth. Its goals include maintainable architecture, thoughtful user experience, reliable tests, accessibility, privacy, and clear engineering tradeoffs.
