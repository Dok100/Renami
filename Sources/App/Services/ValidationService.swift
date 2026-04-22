import Foundation

enum ValidationService {
    static func applyValidation(to previews: [PreviewItem]) -> [PreviewItem] {
        let duplicateTargetURLs = duplicateTargets(in: previews)

        return previews.map { preview in
            var issues: [ValidationIssue] = []

            if preview.proposedBaseName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                issues.append(ValidationIssue(kind: .emptyName, message: "Leerer Dateiname"))
            }

            if preview.proposedBaseName.contains("/") || preview.proposedBaseName.contains(":") {
                issues.append(ValidationIssue(kind: .invalidCharacter, message: "Ungültige Zeichen"))
            }

            if duplicateTargetURLs.contains(preview.targetURL.standardizedFileURL),
               preview.isSelected
            {
                issues.append(ValidationIssue(kind: .duplicateTargetName, message: "Doppelter Zielname"))
            }

            if preview.isSelected,
               preview.targetURL.standardizedFileURL != preview.source.url.standardizedFileURL,
               FileManager.default.fileExists(atPath: preview.targetURL.path(percentEncoded: false))
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
}
