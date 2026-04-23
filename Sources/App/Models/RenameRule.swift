import Foundation

struct RenameRule: Identifiable, Hashable, Codable {
    enum Kind: String, CaseIterable, Codable {
        case findReplace
        case prefix
        case suffix
        case insertText
        case dateStamp
        case normalizeDatePrefix
        case numbering
        case removeCharacters
        case caseTransform
        case removeDiacritics
        case windowsSanitize

        var title: String {
            switch self {
            case .findReplace:
                "Text ersetzen"
            case .prefix:
                "Präfix"
            case .suffix:
                "Suffix"
            case .insertText:
                "Text einfügen"
            case .dateStamp:
                "Datum"
            case .normalizeDatePrefix:
                "Datum normalisieren"
            case .numbering:
                "Nummerierung"
            case .removeCharacters:
                "Zeichen entfernen"
            case .caseTransform:
                "Schreibweise"
            case .removeDiacritics:
                "Akzente entfernen"
            case .windowsSanitize:
                "Windows-kompatibel"
            }
        }

        var summary: String {
            switch self {
            case .findReplace:
                "Ersetzt einen Textbaustein im Dateinamen."
            case .prefix:
                "Fügt am Anfang einen festen Text hinzu."
            case .suffix:
                "Fügt vor der Erweiterung einen festen Text hinzu."
            case .insertText:
                "Fügt Text an Anfang, Ende oder Index ein."
            case .dateStamp:
                "Fügt ein Datum im Format YYYY-MM-DD_ ein."
            case .normalizeDatePrefix:
                "Vereinheitlicht vorhandene Datums-Präfixe am Anfang auf YYYY-MM-DD_."
            case .numbering:
                "Hängt eine laufende Nummer an oder stellt sie voran."
            case .removeCharacters:
                "Schneidet Zeichen am Anfang oder Ende ab."
            case .caseTransform:
                "Vereinheitlicht die Schreibweise."
            case .removeDiacritics:
                "Entfernt Akzente und diakritische Zeichen wie ä, é oder ñ."
            case .windowsSanitize:
                "Ersetzt reservierte Zeichen für Windows-Kompatibilität."
            }
        }
    }

    enum InsertPosition: String, CaseIterable, Codable {
        case start
        case end
        case index

        var title: String {
            switch self {
            case .start:
                "Anfang"
            case .end:
                "Ende"
            case .index:
                "Index"
            }
        }
    }

    enum NumberPosition: String, CaseIterable, Codable {
        case prefix
        case suffix

        var title: String {
            switch self {
            case .prefix:
                "Vorne"
            case .suffix:
                "Hinten"
            }
        }
    }

    enum DateSource: String, CaseIterable, Codable {
        case manual
        case modificationDate
        case addedDate

        var title: String {
            switch self {
            case .manual:
                "Manuell"
            case .modificationDate:
                "Letzte Änderung"
            case .addedDate:
                "Hinzugefügt"
            }
        }
    }

    enum DatePosition: String, CaseIterable, Codable {
        case prefix
        case suffix

        var title: String {
            switch self {
            case .prefix:
                "Vorne"
            case .suffix:
                "Hinten"
            }
        }
    }

    enum RemoveDirection: String, CaseIterable, Codable {
        case start
        case end

        var title: String {
            switch self {
            case .start:
                "Am Anfang"
            case .end:
                "Am Ende"
            }
        }
    }

    enum CaseStyle: String, CaseIterable, Codable {
        case keep
        case lower
        case upper
        case title

        var title: String {
            switch self {
            case .keep:
                "Beibehalten"
            case .lower:
                "Kleinbuchstaben"
            case .upper:
                "Großbuchstaben"
            case .title:
                "Title Case"
            }
        }
    }

    let id: UUID
    let kind: Kind
    var isEnabled: Bool
    var textValue: String
    var secondaryTextValue: String
    var insertPosition: InsertPosition
    var insertIndex: Int
    var numberStart: Int
    var numberStep: Int
    var numberPadding: Int
    var numberPosition: NumberPosition
    var manualDate: Date
    var dateSource: DateSource
    var datePosition: DatePosition
    var onlyIfNoDatePrefixExists: Bool
    var separator: String
    var removeCount: Int
    var removeDirection: RemoveDirection
    var caseStyle: CaseStyle
    var replaceReservedCharacters: Bool

    init(
        id: UUID = UUID(),
        kind: Kind,
        isEnabled: Bool = false,
        textValue: String = "",
        secondaryTextValue: String = "",
        insertPosition: InsertPosition = .end,
        insertIndex: Int = 0,
        numberStart: Int = 1,
        numberStep: Int = 1,
        numberPadding: Int = 2,
        numberPosition: NumberPosition = .suffix,
        manualDate: Date = Date(),
        dateSource: DateSource = .manual,
        datePosition: DatePosition = .prefix,
        onlyIfNoDatePrefixExists: Bool = true,
        separator: String = " ",
        removeCount: Int = 1,
        removeDirection: RemoveDirection = .end,
        caseStyle: CaseStyle = .keep,
        replaceReservedCharacters: Bool = true
    ) {
        self.id = id
        self.kind = kind
        self.isEnabled = isEnabled
        self.textValue = textValue
        self.secondaryTextValue = secondaryTextValue
        self.insertPosition = insertPosition
        self.insertIndex = insertIndex
        self.numberStart = numberStart
        self.numberStep = numberStep
        self.numberPadding = numberPadding
        self.numberPosition = numberPosition
        self.manualDate = manualDate
        self.dateSource = dateSource
        self.datePosition = datePosition
        self.onlyIfNoDatePrefixExists = onlyIfNoDatePrefixExists
        self.separator = separator
        self.removeCount = removeCount
        self.removeDirection = removeDirection
        self.caseStyle = caseStyle
        self.replaceReservedCharacters = replaceReservedCharacters
    }

    var title: String {
        kind.title
    }

    var summary: String {
        kind.summary
    }

    static func defaults() -> [RenameRule] {
        [
            RenameRule(kind: .findReplace, isEnabled: true),
            RenameRule(kind: .prefix),
            RenameRule(kind: .suffix),
            RenameRule(kind: .insertText),
            RenameRule(kind: .removeCharacters),
            RenameRule(kind: .caseTransform),
            RenameRule(kind: .removeDiacritics),
            RenameRule(kind: .dateStamp),
            RenameRule(kind: .normalizeDatePrefix),
            RenameRule(kind: .numbering),
            RenameRule(kind: .windowsSanitize),
        ]
    }
}
