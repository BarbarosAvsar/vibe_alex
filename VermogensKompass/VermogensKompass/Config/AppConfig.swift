import Foundation

enum AppConfig {
    static let minimumSupportedOS = "iOS 18"

    static let contactEmail = EmailConfiguration(
        to: "beratung@vermoegenskompass.de",
        subject: "Anfrage zu physischen Edelmetallen",
        body: "Guten Tag,\n\nbitte senden Sie mir weitere Informationen zum VermögensKompass 2050." +
              "\n\nVielen Dank!"
    )

    static let focusCountryISO = "DEU"
}

struct EmailConfiguration: Equatable {
    let to: String
    let subject: String
    let body: String
}
