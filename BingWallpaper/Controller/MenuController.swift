import Cocoa

class MenuController: NSObject {
  private var statusItem: NSStatusItem!
  private var menu: NSMenu!
  private let settings = Settings()
  private var descriptors = [ImageDescriptor]()
  private var selectedDescriptorIndex = 0
  private var imageSelectorView: ImageSelectorView!
  var updateManager: UpdateManager?
  private static let IMAGE_VIEW_TAG = 6
  private static let TEXT_VIEW_TAG = 7
  
  // MARK: - UI setup
  
  func setup() {
    guard self.statusItem == nil && self.menu == nil else { return }
    
    self.statusItem = createStatusBarItem()
    self.menu = createMenu()
    self.statusItem.menu = menu
    
    imagesUpdated()
  }
  
  private func createStatusBarItem() -> NSStatusItem {
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    if let button = statusItem.button {
      button.image = NSImage(systemSymbolName: "photo", accessibilityDescription: "BingWallpaper")
    }
    
    return statusItem
  }
  
  private func createMenu() -> NSMenu {
    let menu = NSMenu()
    menu.delegate = self
    menu.minimumWidth = 300
    
    let imageItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
    imageSelectorView = ImageSelectorView(frame: CGRect(x: 0, y: 0, width: menu.size.width, height: imageSelectorViewHeight(menu: menu)))
    imageSelectorView.leftButton.action = #selector(MenuController.imageSelectorViewLeftButtonAction)
    imageSelectorView.leftButton.target = self
    imageSelectorView.rightButton.action = #selector(MenuController.imageSelectorViewRightButtonAction)
    imageSelectorView.rightButton.target = self
    imageItem.view = imageSelectorView
    imageItem.tag = MenuController.IMAGE_VIEW_TAG
    menu.addItem(imageItem)
    
    menu.addItem(NSMenuItem.separator())
    
    let refreshItem = NSMenuItem(title: "Refresh", action: #selector(refresh), keyEquivalent: "")
    refreshItem.target = self
    menu.addItem(refreshItem)
    
    menu.addItem(NSMenuItem.separator())
    
    let launchAtLoginItem = NSMenuItem(title: "Settings", action: #selector(showSettingsWc), keyEquivalent: "")
    launchAtLoginItem.target = self
    menu.addItem(launchAtLoginItem)
    
    menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
    
    return menu
  }
  
  // MARK: - IBActions

  @objc func showSettingsWc(sender: NSMenuItem) {
    SettingsWc.instance().showWindow(self)
  }

  @objc func refresh(sender: NSMenuItem) {
    updateManager?.update()
  }

  @objc func imageSelectorViewLeftButtonAction(_ sender: NSButton) {
    if descriptors.indices.contains(selectedDescriptorIndex - 1) == false {
      return
    }

    selectedDescriptorIndex = selectedDescriptorIndex - 1
    updateSelectedImage(newSelectedDescriptorIndex: selectedDescriptorIndex)
    updateImageSelectorView(newSelectedDescriptorIndex: selectedDescriptorIndex)
  }

  @objc func imageSelectorViewRightButtonAction(_ sender: NSButton) {
    if descriptors.indices.contains(selectedDescriptorIndex + 1) == false {
      return
    }

    selectedDescriptorIndex = selectedDescriptorIndex + 1
    updateSelectedImage(newSelectedDescriptorIndex: selectedDescriptorIndex)
    updateImageSelectorView(newSelectedDescriptorIndex: selectedDescriptorIndex)
  }

  @objc func textItemAction(sender: NSMenuItem) {
    if let descriptor = descriptors[safe: selectedDescriptorIndex] {
      NSWorkspace.shared.open(descriptor.copyrightUrl)
    }
  }
  
  // MARK: - Helper

  private func imageSelectorViewHeight(menu: NSMenu) -> CGFloat {
    let outerPadding = 5.0
    let buttonWidth = 15.0
    let innerPadding = 5.0
    let imageViewWidth = menu.size.width - outerPadding*2 - buttonWidth*2 - innerPadding*2
    let topMargin = 4.0
    return imageViewWidth / 16*9 + topMargin
  }

  private func updateSelectedImage(newSelectedDescriptorIndex: Int) {
    if let descriptor = descriptors[safe: newSelectedDescriptorIndex] {
      WallpaperManager.shared.setWallpaper(descriptor: descriptor)
    }
  }

  private func updateImageSelectorView(newSelectedDescriptorIndex: Int) {
    let descriptor = descriptors[safe: newSelectedDescriptorIndex]
    imageSelectorView.imageView.image = descriptor?.image

    let textItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
    textItem.tag = MenuController.TEXT_VIEW_TAG
    let textView = TextView(frame: CGRect(x: 0, y: 0, width: menu.size.width, height: 0))
    textView.descriptionLabel.stringValue = getDescription(description: descriptor?.descriptionString)
    textView.copyrightLabel.stringValue = getCopyright(description: descriptor?.descriptionString)
    textView.button.action = #selector(textItemAction)
    textView.button.target = self
    textItem.view = textView

    if let oldTextItem = menu.item(withTag: MenuController.TEXT_VIEW_TAG) {
      menu.removeItem(oldTextItem)
    }
    let imageView = menu.item(withTag: MenuController.IMAGE_VIEW_TAG)!
    let textViewIndex = menu.index(of: imageView) + 1
    menu.insertItem(textItem, at: textViewIndex)

    imageSelectorView.leftButton.isEnabled = descriptors.indices.contains(newSelectedDescriptorIndex - 1)
    imageSelectorView.rightButton.isEnabled = descriptors.indices.contains(newSelectedDescriptorIndex + 1)
  }

  private func getDescription(description: String?) -> String {
    if description == nil { return "" }
    return String(description?.split(separator: "(").first ?? "")
  }

  private func getCopyright(description: String?) -> String {
    if description == nil { return "" }
    return description?.split(separator: "(").last?.replacingOccurrences(of: ")", with: "") ?? ""
  }
}

// MARK: - Delegates

extension MenuController: UpdateManagerDelegate {
  func imagesUpdated() {
    self.descriptors = ImageDescriptionHandler.imageDescriptorsFromDb()
    selectedDescriptorIndex = self.descriptors.firstIndex(where: { $0 == self.descriptors.last }) ?? self.descriptors.endIndex
    updateSelectedImage(newSelectedDescriptorIndex: selectedDescriptorIndex)
  }
}

extension MenuController: NSMenuDelegate {
  func menuNeedsUpdate(_ menu: NSMenu) {
    updateImageSelectorView(newSelectedDescriptorIndex: selectedDescriptorIndex)
  }
}