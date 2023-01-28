//
//  UserCollectionViewController.swift
//  Habits
//
//  Created by Aguirre, Brian P. on 1/24/23.
//

import UIKit

private let reuseIdentifier = "Cell"

// This class contains the implementation for UserCollectionViewController
// This class utilizes a hybrid MVC-MVVM approach
class UserCollectionViewController: UICollectionViewController {
    
    // Keep track of async tasks so they can be cancelled when appropriate
    var usersRequestTask: Task<Void, Never>? = nil
    deinit { usersRequestTask?.cancel() }
    
    // Diffable data source typealias
    typealias DataSourceType = UICollectionViewDiffableDataSource<ViewModel.Section, ViewModel.Item>
    
    // This enum encapsulates everything the collection view needs to display the data - section identifiers and item identifiers
    enum ViewModel {
        typealias Section = Int
        
        struct Item: Hashable {
            let user: User
            let isFollowed: Bool
            
            func hash(into hasher: inout Hasher) {
                hasher.combine(user)
            }
            
            static func ==(_ lhs: Item, _ rhs: Item) -> Bool {
                return lhs.user == rhs.user
            }
        }
    }
    
    // This struct defines the model data to be displayed by the view model
    struct Model {
        var usersByID = [String: User]()
        var followedUsers: [User] {
            return Array(usersByID.filter { Settings.shared.followedUserIDs.contains($0.key) }.values)
        }
    }
    
    var dataSource: DataSourceType!
    
    // Store the model data returned from an API call
    var model = Model()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = createDataSource()
        collectionView.dataSource = dataSource
        collectionView.collectionViewLayout = createLayout()
        
        update()
    }
    
    // Get user objects from the server
    func update() {
        
        // Cancel existing tasks
        usersRequestTask?.cancel()
        
        // Create a new task
        usersRequestTask = Task {
            if let users = try? await UserRequest().send() {
                self.model.usersByID = users
            } else {
                self.model.usersByID = [:]
            }
            
            self.updateCollectionView()
            
            usersRequestTask = nil
        }
    }
    
    // Update the collection view UI
    func updateCollectionView() {
        
        // Map the users in the model to a ViewModel Item array
        let users = model.usersByID.values.sorted().reduce(into: [ViewModel.Item]()) { partial, user in
            partial.append(ViewModel.Item(user: user, isFollowed: model.followedUsers.contains(user)))
        }
        
        // Insert users into a dictionary with one section
        let itemsBySection = [0: users]
        
        // Apply the snapshot
        dataSource.applySnapshotUsing(sectionIDs: [0], itemsBySection: itemsBySection)
    }
    
    // Create the collection view data source
    func createDataSource() -> DataSourceType {
        
        // Create the cell for each item
        let dataSource = DataSourceType(collectionView: collectionView) { collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "User", for: indexPath) as! UICollectionViewListCell
            
            var content = cell.defaultContentConfiguration()
            content.text = item.user.name
            content.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 11, leading: 8, bottom: 11, trailing: 8)
            content.textProperties.alignment = .center
            cell.contentConfiguration = content
            
            return cell
        }
        
//        // Create the header view for each section
//        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
//            let header = collectionView.dequeueReusableSupplementaryView(ofKind: SectionHeader.kind.identifier, withReuseIdentifier: SectionHeader.reuse.identifier, for: indexPath) as! NamedSectionHeaderView
//
//            let section = dataSource.snapshot().sectionIdentifiers[indexPath.section]
//            switch section {
//            case .favorites:
//                header.nameLabel.text = "Favorites"
//            case .category(let category):
//                header.nameLabel.text = category.name
//            }
//
//            return header
//        }
        
        return dataSource
    }
    
    // Create a list-style compositional layout
    func createLayout() -> UICollectionViewCompositionalLayout {
        
        // Create the item
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // Create the group
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.45))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        group.interItemSpacing = .fixed(20)
        
//        // Create the section header
//        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(36))
//        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: SectionHeader.kind.identifier, alignment: .top)
//        sectionHeader.pinToVisibleBounds = true
        
        // Create the section
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 20
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
        //section.boundarySupplementaryItems = [sectionHeader]
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    // Provide a context menu to toggle the followed status of a user
    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let config = UIContextMenuConfiguration(actionProvider:  { (elements) -> UIMenu? in
            
            // Get item at index path
            guard let item = self.dataSource.itemIdentifier(for: indexPath) else { return nil }
            
            // Create menu action
            let followToggle = UIAction(title: item.isFollowed ? "Unfollow" : "Follow") { action in
                
                // Toggle followed status
                Settings.shared.toggleFollowed(user: item.user)
                
                // Update collection view
                self.updateCollectionView()
            }
            
            return UIMenu(children: [followToggle])
        })
        
        return config
    }
    
}
