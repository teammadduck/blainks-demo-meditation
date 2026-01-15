import SwiftUI

public final class LibraryViewModel: ObservableObject {
    @Published public var categories: [MeditationCategory]
    @Published public var searchText: String

    public init(
        categories: [MeditationCategory] = LibraryViewModel.sampleCategories,
        searchText: String = ""
    ) {
        self.categories = categories
        self.searchText = searchText
    }

    public var filteredCategories: [MeditationCategory] {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return categories
        }

        let query = searchText.lowercased()
        return categories.compactMap { category in
            let filteredMeditations = category.meditations.filter {
                $0.title.lowercased().contains(query)
                    || $0.subtitle.lowercased().contains(query)
                    || $0.tags.contains(where: { $0.lowercased().contains(query) })
            }
            guard !filteredMeditations.isEmpty else { return nil }
            return MeditationCategory(id: category.id, title: category.title, meditations: filteredMeditations)
        }
    }

    public static let sampleCategories: [MeditationCategory] = [
        MeditationCategory(
            title: "Sleep",
            meditations: [
                Meditation(title: "Gentle Night Drift", subtitle: "Unwind and prepare for deep rest", duration: "15 min", tags: ["calm", "night"]),
                Meditation(title: "Moonlight Breathing", subtitle: "Slow, rhythmic breaths for relaxation", duration: "10 min", tags: ["sleep", "breath"])
            ]
        ),
        MeditationCategory(
            title: "Focus",
            meditations: [
                Meditation(title: "Laser Focus", subtitle: "Sharpen concentration before tasks", duration: "12 min", tags: ["work", "study"]),
                Meditation(title: "Deep Work Prep", subtitle: "Prime your mind for flow state", duration: "18 min", tags: ["productivity", "focus"])
            ]
        ),
        MeditationCategory(
            title: "Anxiety",
            meditations: [
                Meditation(title: "Calm Waves", subtitle: "Ground yourself with a calming visualization", duration: "14 min", tags: ["anxiety", "grounding"]),
                Meditation(title: "Box Breathing", subtitle: "Steady your nerves with guided breath", duration: "8 min", tags: ["breath", "calm"])
            ]
        )
    ]
}

public struct LibraryView: View {
    @StateObject private var viewModel: LibraryViewModel
    private let gridColumns = [GridItem(.flexible()), GridItem(.flexible())]

    public init(viewModel: LibraryViewModel = LibraryViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                Color.libraryBackground
                    .ignoresSafeArea()

                VStack(spacing: 12) {
                    SearchBar(
                        text: $viewModel.searchText,
                        placeholder: "Search meditations"
                    )
                    .padding(.horizontal)

                    categoriesList
                }
                .navigationTitle("Library")
                .toolbarTitleDisplayMode(.inline)
            }
        }
        .tint(Color.libraryPrimary)
    }

    private var categoriesList: some View {
        List {
            ForEach(viewModel.filteredCategories) { category in
                categorySection(for: category)
            }
        }
        .scrollContentBackground(.hidden)
        .listStyle(.insetGrouped)
        .background(Color.clear)
    }

    @ViewBuilder
    private func categorySection(for category: MeditationCategory) -> some View {
        Section {
            LazyVGrid(columns: gridColumns, spacing: 14) {
                ForEach(category.meditations) { meditation in
                    NavigationLink {
                        MeditationDetailView(meditation: meditation)
                    } label: {
                        MeditationTile(meditation: meditation)
                    }
                    .listRowBackground(Color.clear)
                    .buttonStyle(.plain)
                    .overlay(alignment: .bottomTrailing) {
                        NavigationLink {
                            MeditationSessionView(meditation: meditation)
                        } label: {
                            Text("Start")
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(Color.libraryBackground)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(Color.libraryAccent)
                                )
                                .shadow(color: Color.libraryPrimary.opacity(0.4), radius: 6, x: 0, y: 3)
                        }
                        .padding(8)
                    }
                }
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
        } header: {
            Text(category.title)
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color.librarySecondary)
                .textCase(nil)
        }
    }
}

public struct MeditationTile: View {
    public let meditation: Meditation

    public init(meditation: Meditation) {
        self.meditation = meditation
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(meditation.title)
                .font(.headline)
                .foregroundStyle(.white)

            Text(meditation.subtitle)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))
                .lineLimit(2)

            Spacer()

            HStack {
                Label(meditation.duration, systemImage: "clock")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.9))
                Spacer()
                if let tag = meditation.tags.first {
                    Text(tag.capitalized)
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(Color.libraryBackground)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.libraryAccent))
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 150)
        .background(
            LinearGradient(
                colors: [Color.libraryPrimary, Color.librarySecondary],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.libraryPrimary.opacity(0.35), radius: 10, x: 0, y: 8)
    }
}

public struct SearchBar: View {
    @Binding public var text: String
    public var placeholder: String

    public init(text: Binding<String>, placeholder: String) {
        self._text = text
        self.placeholder = placeholder
    }

    public var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.librarySecondary)
            TextField(placeholder, text: $text)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .foregroundColor(.white)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
}

public struct MeditationCategory: Identifiable {
    public let id: UUID
    public let title: String
    public let meditations: [Meditation]

    public init(id: UUID = UUID(), title: String, meditations: [Meditation]) {
        self.id = id
        self.title = title
        self.meditations = meditations
    }
}

public struct Meditation: Identifiable, Hashable {
    public let id: UUID
    public let title: String
    public let subtitle: String
    public let duration: String
    public let tags: [String]

    public init(
        id: UUID = UUID(),
        title: String,
        subtitle: String,
        duration: String,
        tags: [String]
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.duration = duration
        self.tags = tags
    }
}

public extension Color {
    static let libraryPrimary = Color(red: 108 / 255, green: 99 / 255, blue: 255 / 255)
    static let librarySecondary = Color(red: 124 / 255, green: 131 / 255, blue: 253 / 255)
    static let libraryBackground = Color(red: 11 / 255, green: 18 / 255, blue: 36 / 255)
    static let libraryAccent = Color(red: 94 / 255, green: 234 / 255, blue: 212 / 255)
}

#if DEBUG
public struct LibraryView_Previews: PreviewProvider {
    public static var previews: some View {
        LibraryView(viewModel: LibraryViewModel())
    }
}
#endif
