import Cocoa

class MenuController: NSObject {
  private var statusItem: NSStatusItem!
  private var menu: NSMenu!
  private let settings = Settings()
  private var descriptors = [ImageDescriptor]()
  private var selectedDescriptorIndex = 0
  private var imageSelectorView: ImageSelectorView!
  var wallpaperManager: WallpaperManager?

  func createMenu() {
    statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    if let button = statusItem.button {
      button.image = NSImage(systemSymbolName: "1.circle", accessibilityDescription: "1")
    }

    menu = NSMenu()
    menu.minimumWidth = 300

    let imageItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
    imageSelectorView = ImageSelectorView(frame: NSRect(x: 0, y: 0, width: menu.size.width, height: imageSelectorViewHeight(menu: menu)))
    imageSelectorView.leftButton.action = #selector(MenuController.imageSelectorViewLeftButtonAction)
    imageSelectorView.leftButton.target = self
    imageSelectorView.rightButton.action = #selector(MenuController.imageSelectorViewRightButtonAction)
    imageSelectorView.rightButton.target = self
    imageItem.view = imageSelectorView
    menu.addItem(imageItem)

    menu.addItem(NSMenuItem.separator())

    let launchAtLogin = NSMenuItem(title: "Launch at login", action: #selector(launchAtLogin), keyEquivalent: "")
    launchAtLogin.state = settings.launchAtLogin ? .on : .off
    launchAtLogin.representedObject = settings.launchAtLogin
    launchAtLogin.target = self
    menu.addItem(launchAtLogin)

    menu.addItem(NSMenuItem.separator())

    menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

    statusItem.menu = menu
  }

  @objc func launchAtLogin(atLogin sender: NSMenuItem) {
    let oldState = sender.representedObject as! Bool
    let newState = !oldState
    settings.launchAtLogin = newState
    sender.representedObject = newState
    sender.state = newState ? .on : .off
  }

  @objc func imageSelectorViewLeftButtonAction(_ sender: NSButton) {
    if descriptors.indices.contains(selectedDescriptorIndex - 1) == false {
      return
    }

    selectedDescriptorIndex = selectedDescriptorIndex - 1
    updateSelectedImage(newSelectedDescriptorIndex: selectedDescriptorIndex)
  }

  @objc func imageSelectorViewRightButtonAction(_ sender: NSButton) {
    if descriptors.indices.contains(selectedDescriptorIndex + 1) == false {
      return
    }

    selectedDescriptorIndex = selectedDescriptorIndex + 1
    updateSelectedImage(newSelectedDescriptorIndex: selectedDescriptorIndex)
  }

  private func imageSelectorViewHeight(menu: NSMenu) -> CGFloat {
    let outerPadding = 12.0
    let buttonWidth = 12.0
    let innerPadding = 8.0
    let imageViewWidth = menu.size.width - outerPadding*2 - buttonWidth*2 - innerPadding*2
    return imageViewWidth / 16*9
  }

  private func updateSelectedImage(newSelectedDescriptorIndex: Int) {
    if let descriptor = descriptors[safe: newSelectedDescriptorIndex] {
      wallpaperManager?.setWallpaper(descriptor: descriptor)
    }
    updateImageSelectorView(newSelectedDescriptorIndex: newSelectedDescriptorIndex)
  }

  private func updateImageSelectorView(newSelectedDescriptorIndex: Int) {
    imageSelectorView.imageView.image = descriptors[safe: newSelectedDescriptorIndex]?.image
    imageSelectorView.leftButton.isEnabled = descriptors.indices.contains(newSelectedDescriptorIndex - 1)
    imageSelectorView.rightButton.isEnabled = descriptors.indices.contains(newSelectedDescriptorIndex + 1)
  }
}

extension MenuController: UpdateManagerDelegate {
  func imagesUpdated(descriptors: [ImageDescriptor]) {
    self.descriptors = descriptors.sorted(by: { desc1, desc2 in desc1.startDate < desc2.startDate })
    selectedDescriptorIndex = self.descriptors.firstIndex(where: { $0 == self.descriptors.last }) ?? self.descriptors.endIndex
    updateSelectedImage(newSelectedDescriptorIndex: selectedDescriptorIndex)
  }
}
