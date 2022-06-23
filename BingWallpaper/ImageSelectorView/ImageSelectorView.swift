import Cocoa

class ImageSelectorView: NSView {
  @IBOutlet var containerView: NSView!
  @IBOutlet var imageView: NSImageView!
  @IBOutlet var rightButton: NSButton!
  @IBOutlet var leftButton: NSButton!

  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    loadNib()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    loadNib()
  }

  private func loadNib() {
    if Bundle.main.loadNibNamed(String(describing: type(of: self)), owner: self, topLevelObjects: nil) {
      addSubview(containerView)
      containerView.frame = bounds
      containerView.autoresizingMask = [
        NSView.AutoresizingMask.width,
        NSView.AutoresizingMask.height
      ]
    }
  }
}
