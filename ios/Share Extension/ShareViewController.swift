//
//  ShareViewController.swift
//  Share Extension
//
//  Created by Bhagat on 25/11/22.
//

import UIKit
import Social
import MobileCoreServices
import Photos
import UniformTypeIdentifiers
import AVFoundation
import ImageIO

@objc(ShareViewController)
class ShareViewController: UIViewController {
        // TODO: IMPORTANT: This should be your host app bundle identifier
        var hostAppBundleIdentifier = "com.techind.flutterSharingIntentExample"
        let sharedKey = "SharingKey"
        var appGroupId = ""
        var sharedMedia: [SharingFile] = []
        var sharedText: [String] = []
        var imageData: Data?
        var timeline: String = "Timeline 1"
        var section: String = "Session 5"

        var timelines: [String] = ["A","B"]
        var sections = ["A" : ["X", "Y", "Z"], "B": ["W", "Q", "V"]]
    
        let imageContentType = UTType.image.identifier;
        let videoContentType = UTType.movie.identifier;
        let textContentType = UTType.text.identifier;
        let urlContentType = UTType.url.identifier;
        let fileURLType = UTType.fileURL.identifier;
    
    var isNeedToCloseSheet = true
    
    @IBOutlet var parentView: UIView!
    @IBOutlet weak var timelineLabel: UILabel!
    @IBOutlet weak var finBtn: UIButton!
    @IBOutlet weak var selectedTimelineLbl: UILabel!
    @IBOutlet weak var selectedSessionLbl: UILabel!
    @IBOutlet weak var sessionLbl: UILabel!
    @IBOutlet weak var contentLbl: UILabel!
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var uiView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        hideViews()
        self.view.backgroundColor = .clear
        loadIds();
        print(sections["A"])
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
            if (self.isNeedToCloseSheet) {
                self.handleButtonPress()
            }
        })
    }
    
    func hideViews() {
        timelineLabel.isHidden = true
        finBtn.isHidden = true
        sessionLbl.isHidden = true
        selectedSessionLbl.isHidden = true
        selectedTimelineLbl.isHidden = true
        contentImageView.isHidden = true
        contentLbl.isHidden = true
    }
    
    func showViews() {
        timelineLabel.isHidden = false
        finBtn.isHidden = false
        sessionLbl.isHidden = false
        selectedSessionLbl.isHidden = false
        selectedTimelineLbl.isHidden = false
        contentImageView.isHidden = false
        contentLbl.isHidden = false
    }
    
    @IBAction func saveBtn(_ sender: Any) {
        view.backgroundColor = .white
        self.isNeedToCloseSheet = false
        uiView?.removeFromSuperview()
        self.showViews()
    }
    
    @IBAction func finalizeBtn(_ sender: Any) {
        self.handleButtonPress()
    }
    
    private func loadIds() {
 
        // loading Share extension App Id
        let shareExtensionAppBundleIdentifier = Bundle.main.bundleIdentifier!;


        // convert ShareExtension id to host app id
        // By default it is remove last part of id after last point
        // For example: com.test.ShareExtension -> com.test
        let lastIndexOfPoint = shareExtensionAppBundleIdentifier.lastIndex(of: ".");
        hostAppBundleIdentifier = String(shareExtensionAppBundleIdentifier[..<lastIndexOfPoint!]);

        // loading custom AppGroupId from Build Settings or use group.<hostAppBundleIdentifier>
        appGroupId = (Bundle.main.object(forInfoDictionaryKey: "AppGroupId") as? String) ?? "group.\(hostAppBundleIdentifier)";
    }
    
    override func viewDidAppear(_ animated: Bool) {
      
        super.viewDidAppear(animated)
        // This will called after the user selects app from sharing app list.
        handleImageAttachment()
      
       }
    
    func handleImageAttachment(){
        if let content = self.extensionContext?.inputItems.first as? NSExtensionItem {
               if let contents = content.attachments {
                   for (index, attachment) in (contents).enumerated() {
                       if attachment.isImage {
                           handleImages(content: content, attachment: attachment, index: index)
                       } else if attachment.isMovie {
                           handleVideos(content: content, attachment: attachment, index: index)
                       }
                       else if attachment.isFile {
                          handleFiles(content: content, attachment: attachment, index: index)
                      }
                       else if attachment.isURL {
                           handleUrl(content: content, attachment: attachment, index: index)
                       }
                       else if attachment.isText {
                           handleText(content: content, attachment: attachment, index: index)
                       } else {
                           print(" \(attachment) File type is not supported by flutter shaing plugin.")
                       }
                       
                   }
               }
           }
        
    }
    
    func handleButtonPress(){
        if let content = self.extensionContext?.inputItems.first as? NSExtensionItem {
               if let contents = content.attachments {
                   for (index, attachment) in (contents).enumerated() {
                       if attachment.isImage {
                           handleMediaData(content: content, index: index)
                       } else if attachment.isMovie {
                           handleTextData(content: content,  index: index)
                       }
                       else if attachment.isFile {
                           handleTextData(content: content,  index: index)
                      }
                       else if attachment.isURL {
                           handleTextData(content: content,  index: index)
                       }
                       else if attachment.isText {
                           handleTextData(content: content, index: index)
                       } else {
                           print(" \(attachment) File type is not supported by flutter shaing plugin.")
                       }
                       
                   }
               }
           }
        
    }

    
    private func handleTextData (content: NSExtensionItem, index: Int) {
        let this = self
        if index == (content.attachments?.count)! - 1 {
            let userDefaults = UserDefaults(suiteName: this.appGroupId)
            let dataKey = getDataKey()
            var prevListObj = [String]()
            if let responseData = userDefaults?.object(forKey: "\(timeline)_\(section)") as? [String] {
                prevListObj = responseData
            }
            
            userDefaults?.set(this.sharedText, forKey: dataKey)
            
            prevListObj.append(dataKey)
            userDefaults?.set(prevListObj, forKey: "\(timeline)_\(section)")
        }
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }

    
    private func handleMediaData (content: NSExtensionItem,  index: Int) {
        let this = self
        if index == (content.attachments?.count)! - 1 {
            let userDefaults = UserDefaults(suiteName: this.appGroupId)
            let dataKey = getDataKey()
            var prevListObj = [String]()
            if let responseData = userDefaults?.object(forKey: "\(timeline)_\(section)") as? [String] {
                prevListObj = responseData
            }
            
            userDefaults?.set(this.imageData, forKey: dataKey)
            
            prevListObj.append(dataKey)
            userDefaults?.set(prevListObj, forKey: "\(timeline)_\(section)")
        }
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    
    private func handleFileData (content: NSExtensionItem,  index: Int) {
        let this = self
        if index == (content.attachments?.count)! - 1 {
            let userDefaults = UserDefaults(suiteName: this.appGroupId)
            let dataKey = getDataKey()
            var prevListObj = [String]()
            if let responseData = userDefaults?.object(forKey: "\(timeline)_\(section)") as? [String] {
                prevListObj = responseData
            }
            
            userDefaults?.set(this.toData(data: this.sharedMedia), forKey: dataKey)
            
            prevListObj.append(dataKey)
            userDefaults?.set(prevListObj, forKey: "\(timeline)_\(section)")
        }
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    
    private func getDataKey ()  -> String {
        let date = Date()
        let timestamp = date.timeIntervalSince1970
        print(timestamp)
        let dataKey = "\(timeline)_\(section)_\(timestamp)"
        
        return dataKey
    }

    
    private func handleText (content: NSExtensionItem, attachment: NSItemProvider, index: Int) {
        attachment.loadItem(forTypeIdentifier: textContentType, options: nil) { [weak self] data, error in

            if error == nil, let item = data as? String, let this = self {

                this.sharedText.append(item)
                
                DispatchQueue.main.async {
                    if (!this.sharedText.isEmpty) {
                        self?.contentLbl.text = this.sharedText.first
                    }
                }
             
            } else {
                self?.dismissWithError()
            }
        }
    }

    private func handleUrl (content: NSExtensionItem, attachment: NSItemProvider, index: Int) {
          attachment.loadItem(forTypeIdentifier: urlContentType, options: nil) { [weak self] data, error in

              if error == nil, let item = data as? URL, let this = self {

                  this.sharedText.append(item.absoluteString)
                  
                  DispatchQueue.main.async {
                      if (!this.sharedText.isEmpty) {
                          self?.contentLbl.text = this.sharedText.first
                      }
                  }
               
              } else {
                  self?.dismissWithError()
              }
          }
      }
    
    private func handleImages (content: NSExtensionItem, attachment: NSItemProvider, index: Int) {
   
        attachment.loadItem(forTypeIdentifier: imageContentType, options: nil) { [weak self] data, error in
             if error == nil, let url = data as? URL, let this = self {
                 // Always copy
                 let fileName = this.getFileName(from: url, type: .image)
                 let newPath = FileManager.default
                     .containerURL(forSecurityApplicationGroupIdentifier: this.appGroupId)!
                     .appendingPathComponent(fileName)
                 let copied = this.copyFile(at: url, to: newPath) 
                 if(copied) {
                     self?.imageData = try! Data(contentsOf: newPath)
                 }
                 
                 DispatchQueue.main.async {
                     let image = UIImage(data: (self?.imageData)!)
                     if (image != nil) {
                         self?.contentImageView.image = image
                     }
                 }
             } else {
                  self?.dismissWithError()
             }
         }
     }
    
    func getImageFromDir(_ imageName: String) -> UIImage? {
        
        if let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsUrl.appendingPathComponent(imageName)
            do {
                let imageData = try Data(contentsOf: fileURL)
                return UIImage(data: imageData)
            } catch {
                print(error.localizedDescription)
                print("Not able to load image")
            }
        }
        return nil
    }
    
    private func handleVideos (content: NSExtensionItem, attachment: NSItemProvider, index: Int) {
          attachment.loadItem(forTypeIdentifier: videoContentType, options: nil) { [weak self] data, error in

              if error == nil, let url = data as? URL, let this = self {

                  // Always copy
                  let fileName = this.getFileName(from: url, type: .video)
                  let newPath = FileManager.default
                      .containerURL(forSecurityApplicationGroupIdentifier:this.appGroupId)!
                      .appendingPathComponent(fileName)
                  let copied = this.copyFile(at: url, to: newPath)
//                  if(copied) {
//                      guard let sharedFile = this.getSharedMediaFile(forVideo: newPath) else {
//                          return
//                      }
//                      this.sharedMedia.append(sharedFile)
//                  }
                  
                  if(copied) {
                      this.sharedText.append(fileName)
                      DispatchQueue.main.async {
                          if (!this.sharedText.isEmpty) {
                              self?.contentLbl.text = this.sharedText.first
                          }
                      }
                  }
//                  if(copied) {
//                      self?.imageData = try! Data(contentsOf: newPath)
//
//                      DispatchQueue.main.async {
//                          if (this.imageData != nil) {
//                              self?.contentLbl.text = fileName
//                          }
//                      }
//                  }

              } else {
                   self?.dismissWithError()
              }
          }
      }
    
    private func handleFiles (content: NSExtensionItem, attachment: NSItemProvider, index: Int) {
          attachment.loadItem(forTypeIdentifier: fileURLType, options: nil) { [weak self] data, error in

              if error == nil, let url = data as? URL, let this = self {

                  // Always copy
                  let fileName = this.getFileName(from :url, type: .file)
                  print("FileName 1: \(fileName)")
                  let newPath = FileManager.default
                      .containerURL(forSecurityApplicationGroupIdentifier: this.appGroupId)!
                      .appendingPathComponent(fileName)
                  let copied = this.copyFile(at: url, to: newPath)
                  //                  if (copied) {
                  //                      this.sharedMedia.append(SharingFile(value: newPath.absoluteString, thumbnail: nil, duration: nil, type: .file))
                  //
                  //                      DispatchQueue.main.async {
                  //                          self?.contentLbl.text = fileName
                  //                          print("FileName: \(fileName)")
                  //                      }
                  //                  }
                  if(copied) {
                      this.sharedText.append(fileName)
                      DispatchQueue.main.async {
                          if (!this.sharedText.isEmpty) {
                              self?.contentLbl.text = this.sharedText.first
                          }
                      }
                  }
              } else {
                  self?.dismissWithError()
              }
          }
      }
    
    private func dismissWithError() {
            print("[ERROR] Error loading data!")
            let alert = UIAlertController(title: "Error", message: "Error loading data", preferredStyle: .alert)

            let action = UIAlertAction(title: "Error", style: .cancel) { _ in
                self.dismiss(animated: true, completion: nil)
            }

            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
        }

        private func redirectToHostApp(type: RedirectType) {
            // load group and app id from build info
            loadIds();
            let url = URL(string: "SharingMedia-\(hostAppBundleIdentifier)://dataUrl=\(sharedKey)#\(type)")
            var responder = self as UIResponder?
            let selectorOpenURL = sel_registerName("openURL:")
            
            while (responder != nil) {
                if (responder?.responds(to: selectorOpenURL))! {
                    let _ = responder?.perform(selectorOpenURL, with: url)
                }
                responder = responder!.next
            }
            extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
        }

        enum RedirectType {
            case media
            case text
            case file
            case url
        }

        func getExtension(from url: URL, type: SharingFileType) -> String {
            let parts = url.lastPathComponent.components(separatedBy: ".")
            var ex: String? = nil
            if (parts.count > 1) {
                ex = parts.last
            }

            if (ex == nil) {
                switch type {
                    case .image:
                        ex = "PNG"
                    case .video:
                        ex = "MP4"
                    case .file:
                        ex = "TXT"
                    case .text:
                        ex = "TXT"
                    case .url:
                        ex = "TXT"
                    }
            }
            return ex ?? "Unknown"
        }

        func getFileName(from url: URL, type: SharingFileType) -> String {
            var name = url.lastPathComponent

            if (name.isEmpty) {
                name = UUID().uuidString + "." + getExtension(from: url, type: type)
            }

            return name
        }

        func copyFile(at srcURL: URL, to dstURL: URL) -> Bool {
            do {
                if FileManager.default.fileExists(atPath: dstURL.path) {
                    try FileManager.default.removeItem(at: dstURL)
                }
                try FileManager.default.copyItem(at: srcURL, to: dstURL)
            } catch (let error) {
                print("Cannot copy item at \(srcURL) to \(dstURL): \(error)")
                return false
            }
            return true
        }

    private func getSharedMediaFile(forVideo: URL)  -> SharingFile? {
            let asset = AVAsset(url: forVideo)
            let duration = (CMTimeGetSeconds(asset.duration) * 1000).rounded()
            let thumbnailPath = getThumbnailPath(for: forVideo)

            if FileManager.default.fileExists(atPath: thumbnailPath.path) {
                return SharingFile(value: forVideo.absoluteString, thumbnail: thumbnailPath.absoluteString, duration: duration, type: .video)
            }

            var saved = false
            let assetImgGenerate = AVAssetImageGenerator(asset: asset)
            assetImgGenerate.appliesPreferredTrackTransform = true
            //        let scale = UIScreen.main.scale
            assetImgGenerate.maximumSize =  CGSize(width: 360, height: 360)
            do {
                let img = try assetImgGenerate.copyCGImage(at: CMTimeMakeWithSeconds(600, preferredTimescale: Int32(1.0)), actualTime: nil)
                try UIImage.pngData(UIImage(cgImage: img))()?.write(to: thumbnailPath)
                saved = true
            } catch {
                saved = false
            }

            return saved ? SharingFile(value: forVideo.absoluteString, thumbnail: thumbnailPath.absoluteString, duration: duration, type: .video) : nil

        }

        private func getThumbnailPath(for url: URL) -> URL {
            let fileName = Data(url.lastPathComponent.utf8).base64EncodedString().replacingOccurrences(of: "==", with: "")
            let path = FileManager.default
                .containerURL(forSecurityApplicationGroupIdentifier:appGroupId)!
                .appendingPathComponent("\(fileName).jpg")
            return path
        }

        func toData(data: [SharingFile]) -> Data {
            let encodedData = try? JSONEncoder().encode(data)
            return encodedData!
        }
    }

    extension Array {
        subscript (safe index: UInt) -> Element? {
            return Int(index) < count ? self[Int(index)] : nil
        }

    }

// MARK: - Attachment Types
extension NSItemProvider {
    var isImage: Bool {
        return hasItemConformingToTypeIdentifier(UTType.image.identifier)
    }

    var isMovie: Bool {
        return hasItemConformingToTypeIdentifier(UTType.movie.identifier)
    }
  
    var isText: Bool {
        return hasItemConformingToTypeIdentifier(UTType.text.identifier)
    }
    
    var isURL: Bool {
        return hasItemConformingToTypeIdentifier(UTType.url.identifier)
    }
    var isFile: Bool {
        return hasItemConformingToTypeIdentifier(UTType.fileURL.identifier)
    }
}
