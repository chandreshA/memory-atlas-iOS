
# Memory Atlas

Memory Atlas is a local-first iOS app for preserving and exploring personal memories through an interactive timeline and map.

Instead of treating photos, journal entries, books, and places as separate collections, Memory Atlas brings them together as moments. A moment can contain a written reflection, selected photographs, a location, a book, and connections to other memories.

> This project is currently in active development.

## The Idea

Our lives are connected by more than dates.

A particular book may remind us of a trip. A photograph may belong to a larger chapter of life. Returning to a familiar place can reveal how much has changed.

Memory Atlas is designed to make those connections visible.

## Planned Features

- Create moments containing text, dates, photos, places, and books
- Explore memories chronologically through a timeline
- Discover memories geographically through an interactive map
- Search and filter memories by date, place, book, or tag
- Connect related moments into Memory Threads
- Resurface memories with an On This Day experience
- Compare past and present visits with Then & Now
- Export memories in a portable format
- Use the core experience without creating an account

## Technical Goals

Memory Atlas is also a portfolio project focused on production-minded iOS engineering.

| Area | Technology or approach |
| --- | --- |
| User interface | SwiftUI |
| UIKit interoperability | MapKit and `UIViewRepresentable` |
| Concurrency | Swift async/await |
| Networking | Book search and metadata API |
| Persistence | SwiftData and local file storage |
| Architecture | MVVM with repository abstractions |
| Unit testing | XCTest |
| UI testing | XCUITest |
| Accessibility | Dynamic Type, VoiceOver, and non-map alternatives |
| State management | Explicit loading, empty, success, and error states |

## Architecture

The planned architecture separates the application into three primary layers:

```text
Presentation
    ↓
Domain
    ↓
Data
```

- **Presentation:** SwiftUI views and view models
- **Domain:** application models, use cases, and business rules
- **Data:** SwiftData persistence, image storage, location services, and networking

Dependencies will be expressed through protocols so important behavior can be tested without relying on live databases, APIs, or location services.

## Privacy

Personal memories deserve careful handling.

Memory Atlas is being designed as a local-first application:

- Memories are stored on the device
- An account is not required
- Only photographs explicitly selected by the user are imported
- Health information is never requested
- Exported data remains under the user’s control

Any future cloud synchronization will be optional.

## Roadmap

### Phase 1: Foundation

- [ ] Establish the application architecture
- [ ] Define the core memory model
- [ ] Configure SwiftData persistence
- [ ] Add unit and UI test targets
- [ ] Implement loading, empty, and error-state components

### Phase 2: Capture and Timeline

- [ ] Create and edit text-based memories
- [ ] Import selected photographs
- [ ] Display memories chronologically
- [ ] Add search and filtering

### Phase 3: Atlas

- [ ] Attach locations to memories
- [ ] Display memories on a map
- [ ] Add map clustering
- [ ] Provide an accessible list alternative
- [ ] Filter the map using a time range

### Phase 4: Books and Connections

- [ ] Search for books using a remote API
- [ ] Attach books to memories
- [ ] Create Memory Threads
- [ ] Surface related memories

### Phase 5: Reflection and Portability

- [ ] Add On This Day
- [ ] Add Then & Now
- [ ] Export a portable memory archive
- [ ] Improve accessibility and performance

## Testing Strategy

The project will use:

- XCTest for business rules, filtering, persistence, networking, and view-model behavior
- Test doubles for network, location, image-storage, and persistence dependencies
- XCUITest for critical flows such as creating, editing, searching, and deleting a memory
- Accessibility identifiers to keep UI tests readable and reliable

## Getting Started

1. Clone the repository:

```bash
git clone https://github.com/chandreshA/memory-atlas-iOS.git
```

2. Open `MemoryAtlas.xcodeproj` in Xcode.
3. Select an iOS simulator.
4. Build and run the application.

The project is under active development, so setup requirements may change as features are introduced.

## Project Goals

This project is being built to explore modern iOS development through a product with meaningful technical depth. Its goals include maintainable architecture, thoughtful user experience, reliable tests, accessibility, privacy, and clear engineering tradeoffs.
