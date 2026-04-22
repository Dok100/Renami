import Foundation

struct ValidationIssue: Identifiable, Hashable {
    enum Kind: Hashable {
        case duplicateTargetName
        case emptyName
        case invalidCharacter
        case existingTargetCollision
    }

    let id = UUID()
    let kind: Kind
    let message: String
}

struct PreviewItem: Identifiable, Hashable {
    let id: UUID
    let source: FileItem
    let proposedBaseName: String
    let targetFilename: String
    let targetURL: URL
    var validationIssues: [ValidationIssue]

    var isSelected: Bool {
        source.isSelected
    }

    var hasErrors: Bool {
        !validationIssues.isEmpty
    }

    var isChanged: Bool {
        targetFilename != source.originalFilename
    }

    var validationSummary: String {
        if validationIssues.isEmpty {
            return isChanged ? "Bereit" : "Unverändert"
        }

        return validationIssues.map(\.message).joined(separator: " • ")
    }
}
