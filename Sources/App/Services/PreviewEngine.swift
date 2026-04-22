import Foundation

enum PreviewEngine {
    static func buildPreviews(items: [FileItem], rules: [RenameRule]) -> [PreviewItem] {
        let previews = items.enumerated().map { index, item in
            let proposedBaseName = RenamePipeline.apply(
                baseName: item.originalBaseName,
                rules: rules,
                context: RenameContext(itemIndex: index, fileItem: item)
            )
            let targetFilename = buildFilename(baseName: proposedBaseName, pathExtension: item.originalExtension)
            let targetURL = item.directoryURL.appendingPathComponent(targetFilename)
            return PreviewItem(
                id: item.id,
                source: item,
                proposedBaseName: proposedBaseName,
                targetFilename: targetFilename,
                targetURL: targetURL,
                validationIssues: []
            )
        }

        return ValidationService.applyValidation(to: previews)
    }

    private static func buildFilename(baseName: String, pathExtension: String) -> String {
        guard !pathExtension.isEmpty else {
            return baseName
        }

        return baseName + "." + pathExtension
    }
}
