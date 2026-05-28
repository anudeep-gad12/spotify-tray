import Foundation

enum ApplicationInstallLocation {
    static var bundleURL: URL {
        Bundle.main.bundleURL
    }

    static var isRunningFromApplicationsFolder: Bool {
        guard let applicationsDirectory = FileManager.default.urls(
            for: .applicationDirectory,
            in: .localDomainMask
        ).first else {
            return false
        }

        let applicationsPath = applicationsDirectory.standardizedFileURL.path
        let bundlePath = bundleURL.standardizedFileURL.path
        return bundlePath.hasPrefix(applicationsPath + "/")
    }

    static var isAppTranslocated: Bool {
        bundleURL.path.contains("/AppTranslocation/")
    }

    static var needsInstallToApplicationsFolder: Bool {
        !isRunningFromApplicationsFolder || isAppTranslocated
    }

    static func applicationsDestinationURL(fileManager: FileManager = .default) -> URL? {
        guard let applicationsDirectory = fileManager.urls(
            for: .applicationDirectory,
            in: .localDomainMask
        ).first else {
            return nil
        }

        return applicationsDirectory.appendingPathComponent(
            bundleURL.lastPathComponent,
            isDirectory: true
        )
    }

    static func installToApplicationsFolder(fileManager: FileManager = .default) throws -> URL {
        guard let destinationURL = applicationsDestinationURL(fileManager: fileManager) else {
            throw InstallLocationError.applicationsFolderUnavailable
        }

        let sourceURL = bundleURL.standardizedFileURL
        let destinationPath = destinationURL.standardizedFileURL.path

        if sourceURL.path == destinationPath {
            return destinationURL
        }

        if fileManager.fileExists(atPath: destinationPath) {
            try fileManager.removeItem(at: destinationURL)
        }

        try fileManager.copyItem(at: sourceURL, to: destinationURL)
        return destinationURL
    }
}

enum InstallLocationError: LocalizedError {
    case applicationsFolderUnavailable
    case couldNotOpenInstalledCopy

    var errorDescription: String? {
        switch self {
        case .applicationsFolderUnavailable:
            return "Could not find your Applications folder."
        case .couldNotOpenInstalledCopy:
            return "SpotifyTray was copied to Applications but could not be opened. Open it from Applications manually."
        }
    }
}
