//
//  UserDetailViewController.swift
//  Habits
//
//  Created by Aguirre, Brian P. on 1/24/23.
//

import UIKit

// This class contains the implementation for UserDetailViewController
class UserDetailViewController: UIViewController {
    
    // Keep track of async tasks so they can be cancelled when appropriate
    var imageRequestTask: Task<Void, Never>? = nil
    var userStatisticsRequestTask: Task<Void, Never>? = nil
    var habitLeadStatisticsRequestTask: Task<Void, Never>? = nil
    deinit {
        imageRequestTask?.cancel()
        userStatisticsRequestTask?.cancel()
        habitLeadStatisticsRequestTask?.cancel()
    }
    
    enum SectionHeader: String {
        case kind = "SectionHeader"
        case reuse = "HeaderView"
        
        var identifier: String {
            return rawValue
        }
    }
    
    // Diffable data source typealias
    typealias DataSourceType = UICollectionViewDiffableDataSource<ViewModel.Section, ViewModel.Item>
    
    // This enum encapsulates everything the collection view needs to display the data - section identifiers and item identifiers
    enum ViewModel {
        enum Section: Hashable, Comparable {
            case leading
            case category(_ category: Category)
            
            static func < (lhs: Section, rhs: Section) -> Bool {
                switch (lhs, rhs) {
                case (.leading, .category), (.leading, .leading):
                    return true
                case (.category, .leading):
                    return false
                case (category(let category1), category(let category2)):
                    return category1.name < category2.name
                }
            }
        }
        
        typealias Item = HabitCount
    }
    
    // This struct defines the model data to be displayed by the view model
    struct Model {
        var userStats: UserStatistics?
        var leadingStats: UserStatistics?
    }
    
    var dataSource: DataSourceType!
    
    // Store the model data returned from an API call
    var model = Model()
    
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var bioLabel: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    
    var user: User!
    
    var updateTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize UI
        userNameLabel.text = user.name
        bioLabel.text = user.bio
        
        // Fetch the user image
        // This API endpoint does not seem to be functioning correctly in the HabitServer app
        imageRequestTask = Task {
            if let image = try? await ImageRequest(imageID: user.id).send() {
                self.profileImageView.image = image
            } else {
                print("Failed")
            }
            
            imageRequestTask = nil
        }
        
        collectionView.register(NamedSectionHeaderView.self, forSupplementaryViewOfKind: SectionHeader.kind.identifier, withReuseIdentifier: SectionHeader.reuse.identifier)
        
        dataSource = createDataSource()
        collectionView.dataSource = dataSource
        collectionView.collectionViewLayout = createLayout()
        
        update()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        update()
        
        // Initialize update timer
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            self.update()
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Deinitialize update timer
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    // Required initializer
    required init?(coder: NSCoder) {
        fatalError("Init(coder:) has not been implemented")
    }
    
    // Initialize with habit
    init?(coder: NSCoder, user: User) {
        self.user = user
        super.init(coder: coder)
    }
    
    // Get user and habit lead statistics objects from the server
    func update() {
        
        // Cancel existing tasks
        userStatisticsRequestTask?.cancel()
        
        // Create a new task
        userStatisticsRequestTask = Task {
            if let userStats = try? await UserStatisticsRequest(userIDs: [user.id]).send(),
               userStats.count > 0 {
                self.model.userStats = userStats[0]
            } else {
                self.model.userStats = nil
            }
            
            self.updateCollectionView()
            
            userStatisticsRequestTask = nil
        }
        
        // Cancel existing tasks
        habitLeadStatisticsRequestTask?.cancel()
        
        // Create a new task
        habitLeadStatisticsRequestTask = Task {
            if let userStats = try? await HabitLeadStatisticsRequest(userID: user.id).send() {
                self.model.leadingStats = userStats
            } else {
                self.model.leadingStats = nil
            }
            
            self.updateCollectionView()
            
            habitLeadStatisticsRequestTask = nil
        }
    }
    
    // Update the collection view UI
    func updateCollectionView() {
        guard let userStatistics = model.userStats,
              let leadingStatistics = model.leadingStats else { return }
        
        // Set up the view model
        var itemsBySection = userStatistics.habitCounts.reduce(into: [ViewModel.Section: [ViewModel.Item]]()) { partial, habitCount in
            let section: ViewModel.Section
            
            if leadingStatistics.habitCounts.contains(habitCount) {
                section = .leading
            } else {
                section = .category(habitCount.habit.category)
            }
            
            partial[section, default: []].append(habitCount)
        }
        
        itemsBySection = itemsBySection.mapValues { $0.sorted() }
        
        let sectionIDs = itemsBySection.keys.sorted()
        
        // Apply the snapshot
        dataSource.applySnapshotUsing(sectionIDs: sectionIDs, itemsBySection: itemsBySection)
    }
    
    // Create the collection view data source
    func createDataSource() -> DataSourceType {
        
        // Create the cell for each item
        let dataSource = DataSourceType(collectionView: collectionView) { (collectionView, indexPath, habitStat) -> UICollectionViewCell in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HabitCount", for: indexPath) as! UICollectionViewListCell
            
            var content = UIListContentConfiguration.subtitleCell()
            content.text = habitStat.habit.name
            content.secondaryText = "\(habitStat.count)"
            
            content.prefersSideBySideTextAndSecondaryText = true
            content.textProperties.font = .preferredFont(forTextStyle: .headline)
            content.secondaryTextProperties.font = .preferredFont(forTextStyle: .body)
            cell.contentConfiguration = content
            
            return cell
        }
        
        // Create the header view for each section
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: SectionHeader.kind.identifier, withReuseIdentifier: SectionHeader.reuse.identifier, for: indexPath) as! NamedSectionHeaderView
            
            let section = dataSource.snapshot().sectionIdentifiers[indexPath.section]
            switch section {
            case .leading:
                header.nameLabel.text = "Leading"
            case .category(let category):
                header.nameLabel.text = category.name
            }
            
            return header
        }
        
        return dataSource
    }
    
    // Create a list-style compositional layout
    func createLayout() -> UICollectionViewCompositionalLayout {
        
        // Create the item
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 12)
        
        // Create the group
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(44))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        
        // Create the section header
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(36))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: SectionHeader.kind.identifier, alignment: .top)
        sectionHeader.pinToVisibleBounds = true
        
        // Create the section
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0)
        section.boundarySupplementaryItems = [sectionHeader]
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}
