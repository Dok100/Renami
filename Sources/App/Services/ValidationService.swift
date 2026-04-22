import Foundation

enum ValidationService {
    static func applyValidation(to previews: [PreviewItem]) -> [PreviewItem] {
        let duplicateTargetURLs = duplicateTargets(in: previews)

        return previews.map { preview in
            var issues: [ValidationIssue] = []

            if preview.proposedBaseName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                issues.append(ValidationIssue(kind: .emptyName, message: "Leerer Dateiname"))
            }

            if preview.proposedBaseName.contains("/") {
                issues.append(ValidationIssue(kind: .invalidCharacter, message: "Schrägstrich / ist im Dateinamen nicht erlaubt"))
            }

            if duplicateTargetURLs.contains(preview.targetURL.standardizedFileURL),
               preview.isSelected
            {
                issues.append(ValidationIssue(kind: .duplicateTargetName, message: "Doppelter Zielname"))
            }

            if preview.isSelected,
               existingTargetCollisionExists(for: preview)
            {
                issues.append(ValidationIssue(kind: .existingTargetCollision, message: "Zieldatei existiert bereits"))
            }

            var updated = preview
            updated.validationIssues = issues
            return updated
        }
    }

    private static func duplicateTargets(in previews: [PreviewItem]) -> Set<URL> {
        let selectedTargets = previews
            .filter(\.isSelected)
            .map(\.targetURL.standardizedFileURL)

        let grouped = Dictionary(grouping: selectedTargets, by: \.self)
        return Set(grouped.compactMap { $0.value.count > 1 ? $0.key : nil })
    }

    private static func existingTargetCollisionExists(for preview: PreviewItem) -> Bool {
        let targetURL = preview.targetURL.standardizedFileURL
        let sourceURL = preview.source.url.standardizedFileURL

        guard FileManager.default.fileExists(atPath: targetURL.path(percentEncoded: false)) else {
            return false
        }

        if targetURL == sourceURL {
            return false
        }

        return !refersToSameFile(lhs: sourceURL, rhs: targetURL)
    }

    private static func refersToSameFile(lhs: URL, rhs: URL) -> Bool {
        let keys: Set<URLResourceKey> = [.fileResourceIdentifierKey]
        let lhsIdentifier = try? lhs.resourceValues(forKeys: keys).fileResourceIdentifier
        let rhsIdentifier = try? rhs.resourceValues(forKeys: keys).fileResourceIdentifier

        guard let lhsIdentifier, let rhsIdentifier else {
            return false
        }

        return "\(lhsIdentifier)" == "\(rhsIdentifier)"
    }
}
