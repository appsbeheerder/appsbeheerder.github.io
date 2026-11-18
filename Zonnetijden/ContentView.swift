import SwiftUI

struct ContentView: View {
    @StateObject private var location = LocationManager()
    @State private var date = Date()

    private var times: SunTimes {
        SunCalculator.times(for: date, latitude: location.coordinate.latitude,
                            longitude: location.coordinate.longitude, timeZone: location.timeZone)
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: [.orange.opacity(0.85), .indigo], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            VStack(spacing: 28) {
                VStack(spacing: 4) {
                    Text(location.placeName).font(.title2.bold())
                    Text(date.formatted(.dateTime.weekday(.wide).day().month(.wide).locale(Locale(identifier: "nl_NL"))))
                        .font(.subheadline).opacity(0.85)
                }
                if times.polarDay {
                    Text("De zon gaat vandaag niet onder").font(.title3)
                } else if times.polarNight {
                    Text("De zon komt vandaag niet op").font(.title3)
                } else {
                    row(icon: "sunrise.fill", title: "Zonsopgang", time: times.sunrise)
                    row(icon: "sunset.fill", title: "Zonsondergang", time: times.sunset)
                    if let r = times.sunrise, let s = times.sunset {
                        Text("Daglicht: \(duration(s.timeIntervalSince(r)))").font(.footnote).opacity(0.85)
                    }
                }
                HStack(spacing: 24) {
                    Button { date = Calendar.current.date(byAdding: .day, value: -1, to: date)! } label: { Image(systemName: "chevron.left") }
                    Button("Vandaag") { date = Date() }
                    Button { date = Calendar.current.date(byAdding: .day, value: 1, to: date)! } label: { Image(systemName: "chevron.right") }
                }
                .buttonStyle(.borderedProminent).tint(.white.opacity(0.25))
                if location.denied {
                    Text("Locatietoegang staat uit. Zet dit aan in Instellingen voor jouw eigen tijden; nu geldt Amsterdam.")
                        .font(.footnote).multilineTextAlignment(.center).padding(.horizontal)
                }
            }
            .foregroundStyle(.white).padding()
        }
        .onAppear { location.start() }
    }

    private func row(icon: String, title: String, time: Date?) -> some View {
        HStack {
            Image(systemName: icon).font(.system(size: 44)).symbolRenderingMode(.multicolor).frame(width: 70)
            VStack(alignment: .leading) {
                Text(title).font(.headline).opacity(0.85)
                Text(format(time)).font(.system(size: 48, weight: .semibold, design: .rounded)).monospacedDigit()
            }
            Spacer()
        }
        .padding().background(.white.opacity(0.15), in: RoundedRectangle(cornerRadius: 20))
    }

    private func format(_ d: Date?) -> String {
        guard let d else { return "–" }
        var style = Date.FormatStyle(date: .omitted, time: .shortened, locale: Locale(identifier: "nl_NL"), timeZone: location.timeZone)
        style.timeZone = location.timeZone
        return d.formatted(style)
    }

    private func duration(_ s: TimeInterval) -> String {
        let m = Int((s / 60).rounded()); return "\(m / 60) u \(m % 60) min"
    }
}
