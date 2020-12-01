/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import Alamofire
import MBProgressHUD

public class PickFlavorViewController: UIViewController {
  
  // MARK: Instance Variables
  
  var flavors: [Flavor] = [] {
    didSet {
      pickFlavorDataSource?.flavors = flavors
    }
  }
  
  private var pickFlavorDataSource: PickFlavorDataSource? {
    return collectionView?.dataSource as? PickFlavorDataSource
  }
  
  // MARK: Outlets
  
  @IBOutlet var contentView: UIView!
  @IBOutlet var collectionView: UICollectionView!
  @IBOutlet var iceCreamView: IceCreamView!
  @IBOutlet var label: UILabel!
  
  // MARK: View Lifecycle
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    collectionView.delegate = self
    loadFlavors()
  }
  
  private func loadFlavors() {
    
    showLoadingHUD()
    
    Alamofire.request("https://www.raywenderlich.com/downloads/Flavors.plist",
                      encoding: PropertyListEncoding.xml)
      .responsePropertyList { [weak self] (response) -> Void in
        
        guard let self = self else {
          return
        }
        
        self.hideLoadingHUD()
        
        let flavorsArray: [[String : String]]
        
        switch response.result {
        case .success(let array):
          flavorsArray = array as? [[String : String]] ?? []
        case .failure(_):
          print("Couldn't download flavors!")
          return
        }
        
        self.flavors = flavorsArray.compactMap(Flavor.init(dictionary:))
        self.collectionView.reloadData()
        self.selectFirstFlavor()
    }
  }
  
  private func showLoadingHUD() {
    let hud = MBProgressHUD.showAdded(to: contentView, animated: true)
    hud.label.text = "Loading..."
  }
  
  private func hideLoadingHUD() {
    MBProgressHUD.hide(for: contentView, animated: true)
  }
  
  private func selectFirstFlavor() {
    if let flavor = flavors.first {
      updateWithFlavor(flavor)
    }
  }
  
  // MARK: Internal
  
  private func updateWithFlavor(_ flavor: Flavor) {
    iceCreamView.updateWithFlavor(flavor)
    label.text = flavor.name
  }
}

// MARK: UICollectionViewDelegate
extension PickFlavorViewController: UICollectionViewDelegate {
  public func collectionView(_ collectionView: UICollectionView,
                             didSelectItemAt indexPath: IndexPath) {
    
    let flavor = flavors[indexPath.row]
    updateWithFlavor(flavor)
  }
}
