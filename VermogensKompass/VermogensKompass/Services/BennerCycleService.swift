import Foundation

struct BennerCycleService {
    private let initialPanicYear = 1700
    private let intervals = [18, 20, 16]
    private let range: ClosedRange<Int>
    private let goodSpan = 7
    private let hardSpan = 11

    init(range: ClosedRange<Int> = 1780...2150) {
        self.range = range
    }

    func makeEntries() -> [BennerCycleEntry] {
        let panicYears = makePanicYears(upTo: range.upperBound + hardSpan + (intervals.max() ?? 20))
        var entries: [BennerCycleEntry] = []

        for index in 0..<(panicYears.count - 1) {
            let panicYear = panicYears[index]
            let nextPanic = panicYears[index + 1]

            guard panicYear <= range.upperBound else { break }

            if range.contains(panicYear) {
                entries.append(
                    BennerCycleEntry(
                        year: panicYear,
                        phase: .panic,
                        orderInPhase: 1,
                        phaseLength: 1
                    )
                )
            }

            let availableYears = max(0, min(nextPanic, range.upperBound + 1) - panicYear - 1)
            let cycleGoodYears = min(goodSpan, availableYears)
            let cycleHardYears = max(0, availableYears - cycleGoodYears)

            if cycleGoodYears > 0 {
                for offset in 1...cycleGoodYears {
                    let year = panicYear + offset
                    guard range.contains(year) else { continue }
                    entries.append(
                        BennerCycleEntry(
                            year: year,
                            phase: .goodTimes,
                            orderInPhase: offset,
                            phaseLength: cycleGoodYears
                        )
                    )
                }
            }

            if cycleHardYears > 0 {
                for i in 0..<cycleHardYears {
                    let year = panicYear + cycleGoodYears + 1 + i
                    guard range.contains(year) else { continue }
                    entries.append(
                        BennerCycleEntry(
                            year: year,
                            phase: .hardTimes,
                            orderInPhase: i + 1,
                            phaseLength: cycleHardYears
                        )
                    )
                }
            }
        }

        return entries.sorted { $0.year < $1.year }
    }

    private func makePanicYears(upTo limit: Int) -> [Int] {
        var years = [initialPanicYear]
        var index = 0

        while years.last ?? 0 < limit {
            let increment = intervals[index % intervals.count]
            years.append((years.last ?? initialPanicYear) + increment)
            index += 1
        }

        return years
    }
}
