//
import AVFoundation
//  CaptureView.swift
//  isNamyang
//
//  Created by Jeong YunWon on 2019/12/09.
//  Copyright © 2019 youknowone.org. All rights reserved.
//
import Foundation
import SwiftUI
import UIKit

protocol CVCaptureViewDelegate: class {
    func captureView(_ captureView: CVCaptureView, didRead code: String)
    func metadataOutputObjectsDispatchQueue(for captureView: CVCaptureView) -> DispatchQueue?
    func metadataObjectTypes(for captureView: CVCaptureView) -> [AVMetadataObject.ObjectType]
}

extension CVCaptureViewDelegate {
    func metadataOutputObjectsDispatchQueue(for _: CVCaptureView) -> DispatchQueue? {
        DispatchQueue.main
    }
}

class CVCaptureView: UIView {
    enum CVCaptureViewError: Error {
        case noCaptureDevice
        case unexpected // this is a library bug!
    }

    weak var delegate: CVCaptureViewDelegate? {
        didSet {
            reflectDelegate()
        }
    }

    public let session = AVCaptureSession()
    var metadataOutput: AVCaptureMetadataOutput?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }

    public func setup() -> Result<(), Error> {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            return .failure(CVCaptureViewError.noCaptureDevice)
        }

        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return .failure(error)
        }

        guard session.canAddInput(videoInput) else {
            return .failure(CVCaptureViewError.unexpected)
        }
        session.addInput(videoInput)

        metadataOutput = AVCaptureMetadataOutput()
        guard let metadataOutput = metadataOutput else {
            assert(false)
        }

        guard session.canAddOutput(metadataOutput) else {
            return .failure(CVCaptureViewError.unexpected)
        }
        session.addOutput(metadataOutput)
        reflectDelegate()

        return .success(())
    }

    func reflectDelegate() {
        guard let metadataOutput = metadataOutput else {
            return
        }
        if let delegate = delegate {
            metadataOutput.setMetadataObjectsDelegate(self, queue: delegate.metadataOutputObjectsDispatchQueue(for: self))
            metadataOutput.metadataObjectTypes = delegate.metadataObjectTypes(for: self)
        } else {
            metadataOutput.setMetadataObjectsDelegate(nil, queue: nil)
        }
    }

    private func _init() {
        clipsToBounds = true

        layer.session = session
        layer.videoGravity = .resizeAspectFill

        #if targetEnvironment(simulator)
            backgroundColor = .lightGray
            let label = UILabel(frame: bounds)
            label.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleRightMargin, .flexibleLeftMargin]
            label.text = "Camera area"
            label.sizeToFit()
            addSubview(label)
        #endif
    }

    // MARK: `AVCaptureVideoPreviewLayer`.

    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    override var layer: AVCaptureVideoPreviewLayer {
        super.layer as! AVCaptureVideoPreviewLayer
    }
}

extension CVCaptureView: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from _: AVCaptureConnection) {
        guard let metadata = metadataObjects.first else {
            return
        }
        guard let readable = metadata as? AVMetadataMachineReadableCodeObject else {
            return
        }
        guard let string = readable.stringValue else {
            return
        }

        delegate?.captureView(self, didRead: string)
    }
}

final class CaptureView {
    var capturing: Binding<Bool>

    public var error: Error?
    var metadataDispatchQueue = DispatchQueue.main
    var metadataObjectTypes = [AVMetadataObject.ObjectType]()
    var onRead: ((String) -> Void)?

    init(capturing: Binding<Bool>) {
        self.capturing = capturing
    }
}

extension CaptureView: UIViewRepresentable {
    func makeUIView(context: Context) -> CVCaptureView {
        let view = CVCaptureView()
        view.delegate = context.coordinator
        switch view.setup() {
        case .success:
            break
        case let .failure(e):
            error = e
        }
        return view
    }

    func updateUIView(_ view: CVCaptureView, context _: Context) {
        view.reflectDelegate()
        guard error == nil else {
            capturing.wrappedValue = false
            return
        }
        if capturing.wrappedValue {
            if !view.session.isRunning {
                view.session.startRunning()
            }
        } else {
            if view.session.isRunning {
                view.session.stopRunning()
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    public func metadata(objectTypes: [AVMetadataObject.ObjectType]) -> CaptureView {
        metadataObjectTypes = objectTypes
        assert(metadataObjectTypes == objectTypes)
        return self
    }

    public func onRead(perform code: @escaping (String) -> Void) -> CaptureView {
        onRead = code
        return self
    }

    class Coordinator: CVCaptureViewDelegate {
        var parent: CaptureView

        init(parent: CaptureView) {
            self.parent = parent
        }

        func captureView(_: CVCaptureView, didRead code: String) {
            parent.onRead?(code)
        }

        func metadataObjectTypes(for _: CVCaptureView) -> [AVMetadataObject.ObjectType] {
            parent.metadataObjectTypes
        }
    }
}

struct CaptureView_Preview: PreviewProvider {
    static var previews: some View {
        // simulator preview

        CaptureView(capturing: .constant(true))
    }
}
