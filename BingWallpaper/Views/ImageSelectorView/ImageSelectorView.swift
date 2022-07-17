import Cocoa

class ImageSelectorView: NSView {
    @IBOutlet var containerView: NSView!
    @IBOutlet var imageView: NSImageView!
    @IBOutlet var rightButton: NSButton!
    @IBOutlet var leftButton: NSButton!
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        loadNib()
        setupImageView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadNib()
        setupImageView()
    }
    
    private func loadNib() {
        if Bundle.main.loadNibNamed(String(describing: type(of: self)), owner: self, topLevelObjects: nil) {
            addSubview(containerView)
            containerView.frame = bounds
        }
    }
    
    private func setupImageView() {
        guard let imageView = imageView else { return }
        
        imageView.wantsLayer = true
        imageView.layer?.cornerRadius = 5.0
        imageView.layer?.masksToBounds = true
    }
}
