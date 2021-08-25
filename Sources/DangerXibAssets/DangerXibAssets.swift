import Danger
import IBDecodable

public struct DangerXibAssets {
    private var danger = Danger()
    private var baseBranch: GitHub.MergeRef {
        get {
            danger.github.pullRequest.base
        }
    }
    private var headBranch: GitHub.MergeRef {
        get {
            danger.github.pullRequest.head
        }
    }
    
    public private(set) var text = "Hello, World!"

    public init() {
    }
    
    public func listUnlinkedPossibilityFiles() {
        let xibs = danger.git.modifiedFiles.filter { file in
            file.hasSuffix(".xib")
        }
        
        xibs.forEach { file in
            let diff = try? danger.utils.diff(forFile: file, sourceBranch: baseBranch.ref).get()
            guard let diff = diff else {
                return
            }
            
            let changes = diff.changes
            var headPath, basePath: String
            switch changes {
            case .created:
                return
            case .renamed(let oldPath, _):
                headPath = diff.filePath
                basePath = oldPath
            case .modified, .deleted:
                headPath = diff.filePath
                basePath = diff.filePath
            }
            
            let headFile = danger.utils.readFile(headPath, sourceBranch: headBranch.ref)
            let baseFile = danger.utils.readFile(basePath, sourceBranch: baseBranch.ref)

            do {
                let headResourceNames = try self.parseXib(headFile).resources?.map { r in r.resource.name } ?? []
                let baseResourceNames = try self.parseXib(baseFile).resources?.map { r in r.resource.name } ?? []
                let deletedResources = baseResourceNames.filter { i in headResourceNames.contains(i)}
                if deletedResources.count > 0 {
                    danger.warn("""
参照が消えてるリソースがあるかも。
\(deletedResources.joined(separator: ", "))
""")
                }
            } catch {
                // todo
                return
            }
            
        }
    }
    
    private func parseXib(_ str: String) throws -> XibDocument {
        let parser = InterfaceBuilderParser.init()
        return parser.parseXib(xml: str)
    }
}

extension DangerUtils {
    /// Gives you the diff for a single file
    ///
    /// - Parameter file: The file path
    /// - Returns: File diff or error
    public func readFile(_ file: String, sourceBranch: String) -> String {
        let diff = self.exec("git show \(sourceBranch):\(file)")
        return diff
    }
}
