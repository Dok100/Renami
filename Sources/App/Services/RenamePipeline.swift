import Foundation

struct RenameContext {
    let itemIndex: Int
    let fileItem: FileItem
}

enum RenamePipeline {
    static func apply(baseName: String, rules: [RenameRule], context: RenameContext) -> String {
        rules.reduce(baseName) { current, rule in
            guard rule.isEnabled else {
                return current
            }

            switch rule.kind {
            case .findReplace:
                guard !rule.textValue.isEmpty else { return current }
                return current.replacingOccurrences(of: rule.textValue, with: rule.secondaryTextValue)

            case .prefix:
                guard !rule.textValue.isEmpty else { return current }
                return rule.textValue + current

            case .suffix:
                guard !rule.textValue.isEmpty else { return current }
                return current + rule.textValue

            case .insertText:
                guard !rule.textValue.isEmpty else { return current }
                return insert(rule.textValue, into: current, position: rule.insertPosition, index: rule.insertIndex)

            case .dateStamp:
                if rule.onlyIfNoDatePrefixExists, hasDatePrefix(current) {
                    return current
                }
                guard let dateString = formattedDate(for: rule, fileItem: context.fileItem) else {
                    return current
                }
                switch rule.datePosition {
                case .prefix:
                    return dateString + current
                case .suffix:
                    return current + dateString
                }

            case .normalizeDatePrefix:
                return normalizedDatePrefix(in: current) ?? current

            case .numbering:
                let sequence = rule.numberStart + (context.itemIndex * max(rule.numberStep, 1))
                let formatted = String(format: "%0*d", max(rule.numberPadding, 1), sequence)
                let separator = rule.separator
                switch rule.numberPosition {
                case .prefix:
                    return formatted + separator + current
                case .suffix:
                    return current + separator + formatted
                }

            case .removeCharacters:
                guard rule.removeCount > 0 else { return current }
                return removeCharacters(from: current, count: rule.removeCount, direction: rule.removeDirection)

            case .caseTransform:
                return transformCase(current, style: rule.caseStyle)

            case .removeDiacritics:
                return removeDiacritics(from: current)

            case .windowsSanitize:
                guard rule.replaceReservedCharacters else { return current }
                return sanitizeForWindows(current)
            }
        }
    }

    private static func insert(_ value: String, into text: String, position: RenameRule.InsertPosition, index: Int) -> String {
        switch position {
        case .start:
            return value + text
        case .end:
            return text + value
        case .index:
            let clamped = max(0, min(index, text.count))
            let insertionIndex = text.index(text.startIndex, offsetBy: clamped)
            return String(text[..<insertionIndex]) + value + String(text[insertionIndex...])
        }
    }

    private static func formattedDate(for rule: RenameRule, fileItem: FileItem) -> String? {
        let sourceDate = switch rule.dateSource {
        case .manual:
            rule.manualDate
        case .modificationDate:
            fileItem.modificationDate
        case .addedDate:
            fileItem.addedDate
        }

        guard let sourceDate else {
            return nil
        }

        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: sourceDate) + "_"
    }

    private static func hasDatePrefix(_ text: String) -> Bool {
        let pattern = #"^\d{4}-\d{2}-\d{2}_"#
        return text.range(of: pattern, options: .regularExpression) != nil
    }

    private static func normalizedDatePrefix(in text: String) -> String? {
        let patterns: [(String, (NSTextCheckingResult, NSString) -> (year: String, month: String, day: String)?)] = [
            (#"^(\d{4})-(\d{2})-(\d{2})_"#, { match, text in
                (
                    text.substring(with: match.range(at: 1)),
                    text.substring(with: match.range(at: 2)),
                    text.substring(with: match.range(at: 3))
                )
            }),
            (#"^(\d{2})-(\d{2})-(\d{4})_"#, { match, text in
                (
                    text.substring(with: match.range(at: 3)),
                    text.substring(with: match.range(at: 2)),
                    text.substring(with: match.range(at: 1))
                )
            }),
            (#"^(\d{4})_(\d{2})_(\d{2})_"#, { match, text in
                (
                    text.substring(with: match.range(at: 1)),
                    text.substring(with: match.range(at: 2)),
                    text.substring(with: match.range(at: 3))
                )
            }),
            (#"^(\d{8})_"#, { match, text in
                let raw = text.substring(with: match.range(at: 1))
                let year = String(raw.prefix(4))
                let month = String(raw.dropFirst(4).prefix(2))
                let day = String(raw.dropFirst(6).prefix(2))
                return (year, month, day)
            }),
        ]

        let nsText = text as NSString

        for (pattern, extractor) in patterns {
            guard let regex = try? NSRegularExpression(pattern: pattern) else {
                continue
            }

            guard let match = regex.firstMatch(in: text, range: NSRange(location: 0, length: nsText.length)),
                  let parts = extractor(match, nsText),
                  isValidDate(year: parts.year, month: parts.month, day: parts.day)
            else {
                continue
            }

            let remainder = nsText.substring(from: match.range.location + match.range.length)
            return "\(parts.year)-\(parts.month)-\(parts.day)_\(remainder)"
        }

        return nil
    }

    private static func isValidDate(year: String, month: String, day: String) -> Bool {
        guard let year = Int(year),
              let month = Int(month),
              let day = Int(day)
        else {
            return false
        }

        var components = DateComponents()
        components.calendar = Calendar(identifier: .iso8601)
        components.year = year
        components.month = month
        components.day = day
        return components.date != nil
    }

    private static func removeCharacters(from text: String, count: Int, direction: RenameRule.RemoveDirection) -> String {
        guard count < text.count else {
            return ""
        }

        switch direction {
        case .start:
            return String(text.dropFirst(count))
        case .end:
            return String(text.dropLast(count))
        }
    }

    private static func transformCase(_ text: String, style: RenameRule.CaseStyle) -> String {
        switch style {
        case .keep:
            text
        case .lower:
            text.lowercased()
        case .upper:
            text.uppercased()
        case .title:
            titleCasePreservingSeparators(in: text)
        }
    }

    private static func titleCasePreservingSeparators(in text: String) -> String {
        var result = ""
        var currentToken = ""

        for character in text {
            if character.isLetter || character.isNumber {
                currentToken.append(character)
            } else {
                if !currentToken.isEmpty {
                    result.append(titleCaseToken(currentToken))
                    currentToken.removeAll(keepingCapacity: true)
                }
                result.append(character)
            }
        }

        if !currentToken.isEmpty {
            result.append(titleCaseToken(currentToken))
        }

        return result
    }

    private static func titleCaseToken(_ token: String) -> String {
        guard token.rangeOfCharacter(from: .letters) != nil else {
            return token
        }

        return token.prefix(1).uppercased() + token.dropFirst().lowercased()
    }

    private static func removeDiacritics(from text: String) -> String {
        text.folding(options: [.diacriticInsensitive], locale: .current)
    }

    private static func sanitizeForWindows(_ text: String) -> String {
        let reservedCharacters = CharacterSet(charactersIn: "<>:\"/\\|?*")
        let scalars = text.unicodeScalars.map { scalar in
            reservedCharacters.contains(scalar) ? "_" : Character(scalar)
        }
        let sanitized = String(scalars).trimmingCharacters(in: CharacterSet(charactersIn: ". "))
        let reservedNames = Set([
            "CON", "PRN", "AUX", "NUL",
            "COM1", "COM2", "COM3", "COM4", "COM5", "COM6", "COM7", "COM8", "COM9",
            "LPT1", "LPT2", "LPT3", "LPT4", "LPT5", "LPT6", "LPT7", "LPT8", "LPT9",
        ])

        guard reservedNames.contains(sanitized.uppercased()) else {
            return sanitized
        }

        return "_" + sanitized
    }
}
