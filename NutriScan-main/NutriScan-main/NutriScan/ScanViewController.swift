import UIKit
import AVFoundation

class ScanViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417] // Add other supported barcode types if needed
        } else {
            failed()
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        captureSession.startRunning()
    }

    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if (captureSession.isRunning) {
            captureSession.stopRunning()
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }
    }

    func found(code: String) {
        print("Scanned barcode: \(code)")
        fetchProductInfo(barcode: code)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

extension ScanViewController {

    func fetchProductInfo(barcode: String) {
        let apiUrl = "https://world.openfoodfacts.net/api/v2/product/\(barcode)"
        
        guard let url = URL(string: apiUrl) else { return }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching product info: \(error)")
                return
            }
            
            guard let data = data else { return }

            do {
                let productResponse = try JSONDecoder().decode(ProductResponse.self, from: data)
                DispatchQueue.main.async {
                    self.displayProductInfo(productResponse.product)
                }
            } catch {
                print("Error parsing JSON: \(error)")
            }
        }

        task.resume()
    }

    func displayProductInfo(_ product: FoodProduct) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "showProductDetails", sender: product)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showProductDetails" {
            if let destinationVC = segue.destination as? ProductDetailsViewController,
               let product = sender as? FoodProduct {
                destinationVC.product = product
            }
        }
    }
}
