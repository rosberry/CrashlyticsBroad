#!/usr/bin/swift

import Foundation
import Cocoa

let ignoreFolders = ["carthage", "pods"]
let fileManager = FileManager.default

final class FileSeeker {
    let fileManager: FileManager = .default
    func find(byName name: String) -> [String] {
        return find(byName: name, at: "./")
    }
    
    func find(byName name: String, at path: String) -> [String] {
        var result = [String]()
        let name = name.lowercased()
        guard let contents = try? fileManager.contentsOfDirectory(atPath: path) else {
            print("cound not get contents of '\(path)'")
            return result
        }
        contents.forEach { content in
            var isDirectory: ObjCBool = false
            let path = path + content
            fileManager.fileExists(atPath: path, isDirectory: &isDirectory)
            if content.lowercased() == name {
                result.append(path)
            }
            else if isDirectory.boolValue, ignoreFolders.contains(content.lowercased()) == false {
                let contents = find(byName: name, at: path + "/")
                result.append(contentsOf: contents)
            }
        }
        return result
    }
    
    static let common: FileSeeker = .init()
}

func chooseFile(with name: String) -> String? {
    let paths = FileSeeker.common.find(byName: name)
    guard paths.isEmpty == false else {
        print("Could not find any '\(name)'")
        return nil
    }
    guard paths.count > 1 else {
        return paths.first
    }
    
    print("Please select the '\(name)' file that you want to configure:")
    paths.enumerated().forEach { index, path in
        print("\(index + 1): \(path)")
    }
    var index: Int = 0
    while true {
        index = (Int(readLine() ?? "0") ?? 0) - 1
        if index < 0 || index >= paths.count {
            print("please select a valid number:")
        }
        else {
            break
        }
    }
    return paths[index]
}

func matches(for regex: String, in text: String) -> [String] {
    
    do {
        let regex = try NSRegularExpression(pattern: regex)
        let results = regex.matches(in: text,
                                    range: NSRange(text.startIndex..., in: text))
        return results.map {
            String(text[Range($0.range, in: text)!])
        }
    } catch let error {
        print("invalid regex: \(error.localizedDescription)")
        return []
    }
}

func randomId() -> String {
    let id = UUID.init().uuidString
    return String(id[id.startIndex..<id.index(id.startIndex, offsetBy: 24)]).split(separator: "-").joined()
}

func findProjectId(from content: String) -> String {
    guard let startIndex = content.range(of: "rootObject = ", options: .backwards)?.upperBound,
        let endIndex = content.range(of: "/* Project object */", options: .backwards)?.lowerBound else {
       return randomId()
    }
    let projectId = String(content[startIndex..<endIndex]).trimmingCharacters(in: .whitespacesAndNewlines)
    return projectId
}

func integer(for id: String) -> Int? {
    let substr = String(id[id.startIndex..<id.index(id.startIndex, offsetBy: 8)])
    return Int(substr, radix: 16)
}

func greatestId(in content: String) -> String {
    let projectId = findProjectId(from: content)
    let start = String(projectId[projectId.startIndex...projectId.index(projectId.startIndex, offsetBy: 4)])
    let end = String(projectId[projectId.index(projectId.endIndex, offsetBy: -10)..<projectId.endIndex])
    let ids = matches(for: "\(start)[A-Fa-f0-9]+\(end)", in: content)
    return ids.reduce(projectId) { result, id -> String in
        guard let resultValue = integer(for: result),
            let idValue = integer(for: id),
            idValue > resultValue else {
            return result
        }
        return id
    }
}

func generateId(from content: String) -> String {
    let id = greatestId(in: content)
    guard let value = integer(for: id) else {
        return randomId()
    }
    let substr = String(value + 1, radix: 16)
    var result = "\(substr)\(id[id.index(id.startIndex, offsetBy: 8)...])".uppercased()
    for _ in 0..<24-result.count {
        result = "0"+result
    }
    return result
}

func runScriptPhase(with id: String) -> String {
    return """
    
    /* Begin PBXShellScriptBuildPhase section */
    \(id) /* Crashlytics */ = {
        isa = PBXShellScriptBuildPhase;
        buildActionMask = 2147483647;
        files = (
        );
        inputFileListPaths = (
        );
        inputPaths = (
            "$(SRCROOT)/$(BUILT_PRODUCTS_DIR)/$(INFOPLIST_PATH)",
        );
        name = "Crashlytics";
        outputFileListPaths = (
        );
        outputPaths = (
        );
        runOnlyForDeploymentPostprocessing = 0;
        shellPath = /bin/sh;
        shellScript = "${PODS_ROOT}/Fabric/run";
    };
    """
}

func addRunScriptPhase(with id: String, into content: String) -> String {
    guard let range = content.range(of: "/* End PBXResourcesBuildPhase section */", options: .backwards) else {
        return content
    }
    let top = content[content.startIndex...range.upperBound]
    let bottom = content[range.upperBound...]
    return "\(top)\(runScriptPhase(with: id))\(bottom)"
}

func addReference(with id: String, to section: String) -> String {
    guard let startIndex = section.range(of: "buildPhases = (")?.upperBound,
        let braceIndex = section.range(of: ");", range: startIndex..<section.endIndex)?.lowerBound,
        let endIndex = section.range(of: "*/", options: .backwards, range: startIndex..<braceIndex)?.upperBound else {
            return section
    }
    var builPathes = section[startIndex..<endIndex]
    builPathes += ",\n\t\t\t\t\(id) /* Crashlytics */"
    let top = section[section.startIndex..<startIndex]
    let bottom = section[endIndex...]
    return "\(top)\(builPathes)\(bottom)"
}

func addReferenceToNativeTarget(with id: String, into content: String) -> String {
    guard let startIndex = content.range(of: "/* Begin PBXNativeTarget section */")?.upperBound,
        let endIndex = content.range(of: "/* End PBXNativeTarget section */")?.lowerBound else {
        return content
    }
    var section = String(content[startIndex..<endIndex])
    let top = content[content.startIndex..<startIndex]
    let bottom = content[endIndex...]
    section = addReference(with: id, to: section)
    return "\(top)\(section)\(bottom)"
}

func readProject(at path: String) -> String? {
    return try? String(contentsOfFile: path)
}

func addRunScriptPhase(into content: String) -> String {
    let id = generateId(from: content)
    var content = addRunScriptPhase(with: id, into: content)
    content = addReferenceToNativeTarget(with: id, into: content)
    print("Fabric Run Script successfully added into your project")
    return content
}

func save(project: String, at path: String) {
    try? project.write(toFile: path, atomically: true, encoding: .utf8)
}

func wantConfugureGoogle() -> Bool {
    print("Do you want to configure the Firebase? (y/n): ")
    while true {
        if let choice = readLine()?.lowercased().trimmingCharacters(in: .whitespaces) {
            switch choice {
            case "y": return true
            case "n": return false
            default:
                print("Please enter a valid choice (y/n): ")
            }
        }
    }
}

func findBundleIds(in project: String) -> [String] {
    return matches(for: "PRODUCT_BUNDLE_IDENTIFIER = .+;", in: project).map { match in
        let match = match.trimmingCharacters(in: .whitespaces)
        if let startIndex = match.range(of: "=")?.upperBound,
            let endIndex = match.range(of: ";")?.lowerBound {
            return String(match[startIndex..<endIndex]).trimmingCharacters(in: .whitespaces)
        }
        return "<UNPARSABLE MATCH>"
    }
}

func readBundleId() -> String {
    print("please enter the bundle id: ")
    while true {
        if let id = readLine()?.lowercased().trimmingCharacters(in: .whitespaces) {
            return id
        }
    }
}

func chooseBundleId(in project: String) -> String {
    var ids = findBundleIds(in: project)
    if ids.isEmpty {
        print("Could not pars bundle id")
        ids = [readBundleId()]
    }
    ids = Array(Set(ids))
    if ids.count == 1 {
        return ids[0]
    }
    print("Please chose your bundle id:")
    ids.enumerated().forEach { index, id in
        print("\(index + 1): \(id)")
    }
    while true {
        if let choice = readLine()?.trimmingCharacters(in: .whitespaces),
            let index = Int(choice), index > 0, index <= ids.count {
            return ids[index - 1]
        }
        print("Please choose a valid bundle id")
    }
}

func downloadInfoPlist(using project: String, at path: String) -> String {
    print("Currentely we could not retrive your configuration file automatically.\nPlease download the file manially and continue with this script when file will be downloaded.")
    print("Tap 'enter' to redirect to the Firebase Console Settings of your project")
    let _ = readLine()
    let bundleId = chooseBundleId(in: project)
    if let url = URL(string: "https://console.firebase.google.com/project/crashlyticsbroad/settings/general/ios:\(bundleId)"),
        NSWorkspace.shared.open(url) {
        print("Firebase console ready to work.")
    }
    return configureGoogle(using: project, at: path)
}

func xcodeprojLocation(for path: String) -> String? {
    let components = path.split(separator: "/")
    if let index = components.firstIndex(where: { string in
        string.contains(".xcodeproj")
    }) {
        return String(components[0..<index].joined(separator: "/"))
    }
    return nil
}

func getCoogleConfigurationFileDestinationFolder(using path: String) -> String {
    if let location = xcodeprojLocation(for: path) {
        return location
    }
    print("Could not retrieve the 'GoogleService-Info.plist' destination. Please specify it here:")
    while true {
        if let path = readLine()?.trimmingCharacters(in: .whitespaces) {
            return path
        }
        print("Please the 'GoogleService-Info.plist' destination here:")
    }
}

func wantToRemoveDownloaded() -> Bool {
    print("Do you want to remove the downloaded file? (y/n): ")
    while true {
        if let choice = readLine()?.lowercased().trimmingCharacters(in: .whitespaces) {
            switch choice {
            case "y": return true
            case "n": return false
            default:
                print("Please enter a valid choice (y/n): ")
            }
        }
    }
}

func copyGoogleInfoPlist(using projectPath: String) {
    print("Provide the path to your 'GoogleService-Info.plist' here:")
    guard let infoPlistPath = readLine()?.trimmingCharacters(in: .whitespaces) else {
        return
    }
    let infoPlsitURL = URL(fileURLWithPath: infoPlistPath)
    let destinationPath = getCoogleConfigurationFileDestinationFolder(using: projectPath) + "/GoogleService-Info.plist"
    let destinatinURL = URL(fileURLWithPath: destinationPath)
    try? fileManager.copyItem(at: infoPlsitURL, to: destinatinURL)
    if wantToRemoveDownloaded() {
        try? fileManager.removeItem(at: infoPlsitURL)
    }
}

func createFileReference(with id: String, using project: String) -> String {
    guard let startIndex = project.range(of: "/* Begin PBXFileReference section */")?.upperBound,
        let endIndex = project.range(of: "/* End PBXFileReference section */")?.lowerBound else {
            return project
    }
    var section = String(project[startIndex..<endIndex])
    let top = project[project.startIndex..<startIndex]
    let bottom = project[endIndex...]
    let reference = "\(id) /* GoogleService-Info.plist */ = {isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = text.plist.xml; path = \"GoogleService-Info.plist\"; sourceTree = SOURCE_ROOT; };"
    section += "\t\t" + reference + "\n"
    return "\(top)\(section)\(bottom)"
}

func addBuldFile(with id: String, fileReferenceId: String, using project: String) -> String {
    guard let startIndex = project.range(of: "/* Begin PBXBuildFile section */")?.upperBound,
        let endIndex = project.range(of: "/* End PBXBuildFile section */")?.lowerBound else {
            return project
    }
    var section = String(project[startIndex..<endIndex])
    let top = project[project.startIndex..<startIndex]
    let bottom = project[endIndex...]
    let buildFile = "\(id) /* GoogleService-Info.plist in Resources */ = {isa = PBXBuildFile; fileRef = \(fileReferenceId) /* GoogleService-Info.plist */; };"
    section += "\t\t" + buildFile + "\n"
    return "\(top)\(section)\(bottom)"
}

func groupRange(with name: String, in project: String, including matches: String...) ->  Range<String.Index>? {
    var index: String.Index? = project.startIndex
    while let offsetIndex = index {
        index = project.range(of: "\(name) = (", range: offsetIndex..<project.endIndex)?.upperBound
        if let startIndex = index, let endIndex = project.range(of: ");", range: startIndex..<project.endIndex)?.lowerBound {
            let group = project[startIndex..<endIndex]
            var isMatch = false
            matches.forEach { string in
                if group.contains(string) {
                    isMatch = true
                }
            }
            if isMatch {
                return startIndex..<endIndex
            }
        }
    }
    return nil
}

func addFileReferenceIntoGroup(with id: String, using project: String) -> String {
    guard let range = groupRange(with: "children", in: project, including: "/* Info.plist */") else {
        return project
    }
    let top = project[project.startIndex..<range.lowerBound]
    let bottom = project[range.upperBound...]
    var group = String(project[range])
    group += "\t\(id) /* GoogleService-Info.plist */,\n\t\t\t"
    return "\(top)\(group)\(bottom)"
}

func addGoogleInfoPlsit(into project: String, at path: String) -> String {
    let fileReferenceId = generateId(from: project)
    var project = createFileReference(with: fileReferenceId, using: project)
    let buildFileId = generateId(from: project)
    project = addBuldFile(with: buildFileId, fileReferenceId: fileReferenceId, using: project)
    project = addFileReferenceIntoGroup(with: fileReferenceId, using: project)
    print("'GoogleService-Info.plist' successfully added into your project")
    return project
}

func configureGoogle(using project: String, at path: String) -> String {
    print("'GoogleService-Info.plist' is required. Please choose a on of following cases:")
    print("1: Download from firebase console")
    print("2: Specify the location")
    print("0: Cancel")
    
    while true {
        if let choice = readLine()?.lowercased().trimmingCharacters(in: .whitespaces) {
            switch choice {
            case "1":
                return downloadInfoPlist(using: project, at: path)
            case "2":
                copyGoogleInfoPlist(using: path)
                return addGoogleInfoPlsit(into: project, at: path)
            case "0":
                return project
            default:
                continue
            }
        }
    }
}

func main() {
    guard let path = chooseFile(with: "project.pbxproj"),
        var project = readProject(at: path) else {
        return
    }
    project = addRunScriptPhase(into: project)
    if wantConfugureGoogle() {
        project = configureGoogle(using: project, at: path)
    }
    save(project: project, at: path)
}

main()
