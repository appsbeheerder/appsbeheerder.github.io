import Foundation

/// Zonsopgang/ondergang berekend op het toestel zelf (geen internet nodig).
/// Methode: "sunrise equation" (zie Wikipedia / NOAA), nauwkeurigheid ca. 1–2 minuten.
struct SunTimes {
    let sunrise: Date?
    let sunset: Date?
    let polarDay: Bool    // zon gaat niet onder
    let polarNight: Bool  // zon komt niet op
}

enum SunCalculator {
    static func times(for date: Date, latitude: Double, longitude: Double, timeZone: TimeZone) -> SunTimes {
        // Kalenderdatum in de tijdzone van de locatie
        var local = Calendar(identifier: .gregorian)
        local.timeZone = timeZone
        let c = local.dateComponents([.year, .month, .day], from: date)

        // Julian Day van 12:00 UTC op die kalenderdag (altijd een geheel getal)
        var utc = Calendar(identifier: .gregorian)
        utc.timeZone = TimeZone(identifier: "UTC")!
        var noon = DateComponents(); noon.year = c.year; noon.month = c.month; noon.day = c.day; noon.hour = 12
        let noonDate = utc.date(from: noon)!
        let jd = noonDate.timeIntervalSince1970 / 86400.0 + 2440587.5

        let n = jd - 2451545.0
        let jStar = n - longitude / 360.0                       // oost = positief
        let m = norm360(357.5291 + 0.98560028 * jStar)          // gemiddelde anomalie
        let mr = rad(m)
        let center = 1.9148 * sin(mr) + 0.0200 * sin(2 * mr) + 0.0003 * sin(3 * mr)
        let lambda = norm360(m + center + 180 + 102.9372)       // ecliptische lengte
        let lr = rad(lambda)
        let jTransit = 2451545.0 + jStar + 0.0053 * sin(mr) - 0.0069 * sin(2 * lr)
        let sinDec = sin(lr) * sin(rad(23.4397))
        let cosDec = cos(asin(sinDec))

        let phi = rad(latitude)
        let cosH = (sin(rad(-0.833)) - sin(phi) * sinDec) / (cos(phi) * cosDec)

        if cosH > 1 { return SunTimes(sunrise: nil, sunset: nil, polarDay: false, polarNight: true) }
        if cosH < -1 { return SunTimes(sunrise: nil, sunset: nil, polarDay: true, polarNight: false) }

        let h = deg(acos(cosH))
        func toDate(_ j: Double) -> Date { Date(timeIntervalSince1970: (j - 2440587.5) * 86400.0) }
        return SunTimes(sunrise: toDate(jTransit - h / 360.0),
                        sunset: toDate(jTransit + h / 360.0),
                        polarDay: false, polarNight: false)
    }

    private static func rad(_ d: Double) -> Double { d * .pi / 180 }
    private static func deg(_ r: Double) -> Double { r * 180 / .pi }
    private static func norm360(_ x: Double) -> Double { let r = x.truncatingRemainder(dividingBy: 360); return r < 0 ? r + 360 : r }
}
