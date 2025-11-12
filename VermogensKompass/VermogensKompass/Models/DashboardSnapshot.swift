import Foundation

struct DashboardSnapshot: Codable {
    let metals: [MetalAsset]
    let macroOverview: MacroOverview
    let macroSeries: [MacroSeries]
    let crises: [CrisisEvent]
}
