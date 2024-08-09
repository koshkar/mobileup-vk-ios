import UIKit

class GalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    private let galleryView = GalleryView()

    override func loadView() {
        view = galleryView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        galleryView.segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        galleryView.logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        
        galleryView.collectionView.dataSource = self
        galleryView.collectionView.delegate = self
    }
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        galleryView.collectionView.reloadData()
    }
    
    @objc private func logoutTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = UIColor.lightGray
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if galleryView.segmentedControl.selectedSegmentIndex == 0 {
            let width = (view.frame.size.width / 2) - 2
            return CGSize(width: width, height: width)
        } else {
            let width = view.frame.size.width - 4
            return CGSize(width: width, height: width * 9 / 16)
        }
    }
}
