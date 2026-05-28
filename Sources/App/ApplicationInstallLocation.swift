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
}
