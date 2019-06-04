////
///  ViewController.swift
//

import Cocoa
import OAuthSwift


class ViewController: NSViewController, NSTextFieldDelegate {

    @IBOutlet weak var token: NSTextField!
    @IBOutlet weak var clientId: NSTextField!
    @IBOutlet weak var clientSecret: NSTextField!
    @IBOutlet weak var backupFile: NSTextField!
    @IBOutlet weak var avatarImageView: NSImageView!
    @IBOutlet weak var printSettingsCheckBox: NSButton!
    @IBOutlet weak var compactDump: NSButton!

    var oauthswift: OAuthSwift?

    override func viewDidLoad() {
        super.viewDidLoad()
        compactDump.state = .on
        loadDefaults()
        setAvatarImage()
    }
    
    override func viewWillDisappear() {
        saveDefaults()
    }

    /// Load default text field values from keychain
    func loadDefaults() {
        clientId.stringValue     = APIKeys.shared.clientId
        clientSecret.stringValue = APIKeys.shared.clientSecret
        token.stringValue        = KeychainService.shared[.token] ?? ""
        backupFile.stringValue   = KeychainService.shared[.backupFile] ?? ""
    }
    
    /// Save text fiels values to keychain
    func saveDefaults() {
        KeychainService.shared[.backupFile] = backupFile.stringValue
        if KeychainService.shared[.token] != token.stringValue {
            KeychainService.shared[.token] = token.stringValue
            setAvatarImage()
        }
    }
    
    func controlTextDidEndEditing(_ obj: Notification) {
        guard (obj.object as? NSTextField) != nil else { return }
        //print(textField.stringValue)
        saveDefaults()
    }
    
    func doOAuthWunderlist(clientId: String, clientSecret: String) {
        let oauthswift = OAuth2Swift(
            consumerKey:    clientId,
            consumerSecret: clientSecret,
            authorizeUrl:   "https://www.wunderlist.com/oauth/authorize",
            accessTokenUrl: "https://www.wunderlist.com/oauth/access_token",
            responseType:   "code"
        )
        self.oauthswift = oauthswift
        let state = generateState(withLength: 20)
        
        let _ = oauthswift.authorize(
            withCallbackURL: URL(string: "http://oauthswift.herokuapp.com/callback/wunderlist")!,
            scope: "",
            state: state,
            success: { credential, response, parameters in
                log("Success: \(credential.oauthToken)")
                KeychainService.shared[.token] = credential.oauthToken
                self.token.stringValue = credential.oauthToken
                self.setAvatarImage()

        },
            failure: { error in
                log("Error: \(error.description)")
                KeychainService.shared[.token] = nil
        }
        )
    }

    @IBAction func authorizeButtonPress(_ sender: Any) {
        log("\nAuthorize\n")
        doOAuthWunderlist(clientId: APIKeys.shared.clientId,
                          clientSecret: APIKeys.shared.clientSecret)
        loadDefaults()
    }
    
    @IBAction func printButtonPress(_ sender: Any) {
        log("\nPrint content\n")
        let printContent = PrintContent()
        printContent.all(printSettingsCheckBox.state == .on)
    }

    @IBAction func DumpButtonPress(_ sender: Any) {
        log("\nDump content\n")
        if compactDump.state == .on {
            let dumpContent = DumpContentComapact(directory: "logs/dump/")
            let alert = NSAlert()
            let frame = NSRect(x: 0, y: 0, width: 200, height: 20)
            let textField = NSTextField(frame: frame)
            textField.drawsBackground = false
            alert.messageText = "Dump content"
            alert.informativeText = "Please enter dump comment"
            alert.accessoryView = textField
            alert.addButton(withTitle: "OK")
            let _ = alert.runModal()
            let comment = textField.stringValue
            dumpContent.all(comment: comment)
        } else {
            let dumpContent = DumpContent()
            dumpContent.all()
        }
    }

    @IBAction func createTestButtonPress(_ sender: Any) {
        log("\nCreate test\n")
        let createTest = CreateTest(directory: "logs/create/")
        createTest.runTest()
    }

    @IBAction func runtestsButtonPress(_ sender: Any) {
        log("\nRun tests\n")
        let testService = TestService()
        testService.testAll()
    }
    
    @IBAction func deleteButtonPress(_ sender: Any) {
        let alert = NSAlert()
        alert.informativeText = "Are you sure?"
        alert.messageText = "Clear all content"
        alert.addButton(withTitle: "Yes")
        alert.addButton(withTitle: "No")
        let responce = alert.runModal()
        if responce != .alertFirstButtonReturn {
            return
        }
        let deleteContentSercice = DeleteContentService()
        deleteContentSercice.all()
        log("\nAll content deleted\n")
    }
    
    @IBAction func insertButtonPress(_ sender: Any) {
        let path = backupFile.stringValue
        guard path != "" else { return }
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: backupFile.stringValue) else {
            log("File not exist \(path)")
            return
        }
        log("Insert test content")
        let backup = WunderImport()
        backup.importFile(path: path)
    }
    
    @IBAction func selectFilePress(_ sender: Any) {
        let panel = NSOpenPanel()
        panel.allowedFileTypes = ["json"]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canCreateDirectories = false
        panel.canChooseFiles = true
        panel.title = "Select backup json file to import"
        
        let result = panel.runModal()
        if result == .OK {
            print(panel.url!.path)
            backupFile.stringValue = panel.url!.path
            saveDefaults()
        }

    }

    @IBAction func compareDump(_ sender: Any) {
        let panel = NSOpenPanel()
        panel.allowedFileTypes = ["json"]
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.canCreateDirectories = false
        panel.canChooseFiles = true
        panel.title = "Select two dump files"

        let result = panel.runModal()
        if result != .OK {
            return
        }

        if panel.urls.count != 2 {
            log("Please select 2 files")
        }

        var dump1 = WDump()
        var dump2 = WDump()
        let decoder = WJSONAbleCoders.decoder
        do {
            let dump1Data = try Data(contentsOf: panel.urls[0])
            dump1 = try decoder.decode(WDump.self, from: dump1Data)
            let dump2Data = try Data(contentsOf: panel.urls[1])
            dump2 = try decoder.decode(WDump.self, from: dump2Data)
        } catch {
            log(error: error)
            return
        }

        CompareDump.compareDump(dump1: dump1, dump2: dump2)
    }

    func ShowNetwork(error: Swift.Error) {
        let printableError = error as CustomStringConvertible
        let alert = NSAlert()
        alert.messageText = "Network error"
        alert.informativeText = printableError.description
        alert.runModal()
    }
    
    func setAvatarImage() {
        guard KeychainService.shared[.token] != nil else {
            return
        }
        WAvatar.loadCurrent { data in
            self.avatarImageView.image = NSImage(data: data)
            log("Download avatar ok")
            WuWSSProvider.websocketInit()
        }
    }

}



