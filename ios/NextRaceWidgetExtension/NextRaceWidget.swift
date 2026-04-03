import WidgetKit
import SwiftUI

// ── Data model ──────────────────────────────────────────────────────────────

struct NextRaceEntry: TimelineEntry {
    let date: Date
    let raceName: String
    let circuitName: String
    let countryFlag: String
    let countdown: String
    let qualifyingLabel: String
    let drivers: [(code: String, pts: String)]
}

// ── Shared-storage reader ────────────────────────────────────────────────────

private let appGroupId = "group.com.example.flutter_application_1.widget"

private func readDefaults() -> NextRaceEntry {
    let defaults = UserDefaults(suiteName: appGroupId)

    func str(_ key: String, _ fallback: String = "—") -> String {
        defaults?.string(forKey: key) ?? fallback
    }

    let countdown: String
    if let isoString = defaults?.string(forKey: "race_date_iso"),
       !isoString.isEmpty,
       let raceDate = ISO8601DateFormatter().date(from: isoString) {
        countdown = liveCountdown(to: raceDate)
    } else {
        countdown = str("countdown")
    }

    let drivers: [(String, String)] = (0..<3).map { i in
        (str("driver_\(i)_code"), str("driver_\(i)_pts"))
    }

    return NextRaceEntry(
        date: Date(),
        raceName: str("race_name", "F1 Tracker"),
        circuitName: str("circuit_name"),
        countryFlag: str("country_flag", "🏎"),
        countdown: countdown,
        qualifyingLabel: str("qualifying_label"),
        drivers: drivers
    )
}

private func liveCountdown(to raceDate: Date) -> String {
    let diff = raceDate.timeIntervalSince(Date())
    guard diff > 0 else { return "Race complete" }
    let days = Int(diff) / 86400
    let hours = (Int(diff) % 86400) / 3600
    let minutes = (Int(diff) % 3600) / 60
    if days > 0 { return "\(days)d \(hours)h" }
    if hours > 0 { return "\(hours)h \(minutes)m" }
    return "\(minutes)m"
}

// ── Timeline Provider ────────────────────────────────────────────────────────

struct NextRaceProvider: TimelineProvider {
    func placeholder(in context: Context) -> NextRaceEntry {
        NextRaceEntry(
            date: Date(),
            raceName: "Bahrain Grand Prix",
            circuitName: "Bahrain International Circuit",
            countryFlag: "🇧🇭",
            countdown: "3d 14h",
            qualifyingLabel: "5 Apr, 15:00",
            drivers: [("VER", "277"), ("NOR", "219"), ("LEC", "188")]
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (NextRaceEntry) -> Void) {
        completion(readDefaults())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<NextRaceEntry>) -> Void) {
        let entry = readDefaults()
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// ── Colour palette (matches app's AppColors) ────────────────────────────────

private extension Color {
    static let widgetBackground = Color(red: 0.075, green: 0.075, blue: 0.106)
    static let widgetSurface    = Color(red: 0.122, green: 0.122, blue: 0.157)
    static let widgetRed        = Color(red: 0.863, green: 0.149, blue: 0.149)
    static let widgetText       = Color(red: 0.894, green: 0.882, blue: 0.933)
    static let widgetMuted      = Color(red: 0.776, green: 0.776, blue: 0.780)
}

// ── Small widget (systemSmall) ───────────────────────────────────────────────

struct SmallNextRaceView: View {
    let entry: NextRaceEntry

    var body: some View {
        ZStack {
            Color.widgetBackground
            VStack(alignment: .leading, spacing: 4) {
                Rectangle()
                    .fill(Color.widgetRed)
                    .frame(height: 3)

                Spacer(minLength: 4)

                HStack(spacing: 4) {
                    Text(entry.countryFlag).font(.system(size: 18))
                    Text(entry.circuitName)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.widgetMuted)
                        .lineLimit(1)
                }

                Text(entry.raceName)
                    .font(.system(size: 13, weight: .heavy))
                    .italic()
                    .foregroundColor(.widgetText)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)

                Spacer()

                Text(entry.countdown)
                    .font(.system(size: 22, weight: .black))
                    .italic()
                    .foregroundColor(.widgetRed)

                HStack(spacing: 4) {
                    Image(systemName: "stopwatch")
                        .font(.system(size: 7))
                        .foregroundColor(.widgetMuted)
                    Text("QUAL: \(entry.qualifyingLabel)")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.widgetMuted)
                        .kerning(0.8)
                }
            }
            .padding(12)
        }
    }
}

// ── Medium widget (systemMedium) ─────────────────────────────────────────────

struct MediumNextRaceView: View {
    let entry: NextRaceEntry

    var body: some View {
        ZStack {
            Color.widgetBackground
            HStack(spacing: 0) {
                // Left: race info
                VStack(alignment: .leading, spacing: 4) {
                    Rectangle()
                        .fill(Color.widgetRed)
                        .frame(height: 3)

                    Spacer(minLength: 4)

                    HStack(spacing: 4) {
                        Text(entry.countryFlag).font(.system(size: 18))
                        Text(entry.circuitName)
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.widgetMuted)
                            .lineLimit(1)
                    }

                    Text(entry.raceName)
                        .font(.system(size: 13, weight: .heavy))
                        .italic()
                        .foregroundColor(.widgetText)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)

                    Spacer()

                    Text(entry.countdown)
                        .font(.system(size: 22, weight: .black))
                        .italic()
                        .foregroundColor(.widgetRed)

                    HStack(spacing: 4) {
                        Image(systemName: "stopwatch")
                            .font(.system(size: 7))
                            .foregroundColor(.widgetMuted)
                        Text("QUAL: \(entry.qualifyingLabel)")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.widgetMuted)
                            .kerning(0.8)
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)

                // Divider
                Rectangle()
                    .fill(Color.widgetSurface)
                    .frame(width: 1)

                // Right: standings
                VStack(alignment: .leading, spacing: 0) {
                    Text("STANDINGS")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.widgetRed)
                        .kerning(1.4)
                        .padding(.bottom, 6)

                    ForEach(Array(entry.drivers.enumerated()), id: \.offset) { i, driver in
                        HStack(spacing: 6) {
                            Text("\(i + 1)")
                                .font(.system(size: 10, weight: .black))
                                .italic()
                                .foregroundColor(.widgetMuted)
                                .frame(width: 12)

                            Text(driver.code)
                                .font(.system(size: 13, weight: .black))
                                .italic()
                                .foregroundColor(.widgetText)

                            Spacer()

                            Text("\(driver.pts)pt")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.widgetMuted)
                        }
                        .padding(.vertical, 3)

                        if i < 2 {
                            Divider().background(Color.widgetSurface)
                        }
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

// ── Entry view ───────────────────────────────────────────────────────────────

struct NextRaceWidgetEntryView: View {
    var entry: NextRaceEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemMedium:
            MediumNextRaceView(entry: entry)
        default:
            SmallNextRaceView(entry: entry)
        }
    }
}

// ── Widget definition ────────────────────────────────────────────────────────

struct NextRaceWidget: Widget {
    let kind: String = "NextRaceWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NextRaceProvider()) { entry in
            NextRaceWidgetEntryView(entry: entry)
                .containerBackground(Color.widgetBackground, for: .widget)
        }
        .configurationDisplayName("Next Race")
        .description("Shows the upcoming F1 race with countdown.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
