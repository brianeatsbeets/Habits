//
//  HabitDetailViewController.swift
//  Habits
//
//  Created by Aguirre, Brian P. on 1/24/23.
//

import UIKit

// This class contains the implementation for HabitDetailViewController
class HabitDetailViewController: UIViewController {
    
    // Keep track of async tasks so they can be cancelled when appropriate
    var habitStatisticsRequestTask: Task<Void, Never>? = nil
    deinit { habitStatisticsRequestTask?.cancel() }
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var infoLabel: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    
    var habit: Habit!
    var updateTimer: Timer?
    
    // Diffable data source typealias
    typealias DataSourceType = UICollectionViewDiffableDataSource<ViewModel.Section, ViewModel.Item>
    
    // This enum encapsulates everything the collection view needs to display the data - section identifiers and item identifiers
    enum ViewModel {
        enum Section: Hashable {
            case leaders(count: Int)
            case remaining
        }
        
        enum Item: Hashable, Comparable {
            case single(_ stat: UserCount)
            case multiple(_ stats: [UserCount])
            
            static func < (_ lhs: Item, _ rhs: Item) -> Bool {
                switch (lhs, rhs) {
                    case (.single(let lCount), .single(let rCount)):
                        return lCount.count < rCount.count
                    case (.multiple(let lCounts), .multiple(let rCounts)):
                        return lCounts.first!.count < rCounts.first!.count
                    case (.single, .multiple):
                        return false
                    case (.multiple, .single):
                        return true
                }
            }
        }
    }
    
    // This struct defines the model data to be displayed by the view model
    struct Model {
        var habitStatistics: HabitStatistics?
        var userCounts: [UserCount] {
            habitStatistics?.userCounts ?? []
        }
    }
    
    var dataSource: DataSourceType!
    
    // Store the model data returned from an API call
    var model = Model()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up UI
        nameLabel.text = habit.name
        categoryLabel.text = habit.category.name
        infoLabel.text = habit.info
        
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
        fatalError("init(coder:) has not been implemented")
    }
    
    // Initialize with habit
    init?(coder: NSCoder, habit: Habit) {
        self.habit = habit
        super.init(coder: coder)
    }
    
    // Get habit statistics objects from the server
    func update() {
        
        // Cancel existing tasks
        habitStatisticsRequestTask?.cancel()
        
        // Create a new task
        habitStatisticsRequestTask = Task {
            if let statistics = try? await HabitStatisticsRequest(habitNames: [habit.name]).send(),
               statistics.count > 0 {
                self.model.habitStatistics = statistics[0]
            } else {
                self.model.habitStatistics = nil
            }
            
            self.updateCollectionView()
            
            habitStatisticsRequestTask = nil
        }
    }
    
    // Update the collection view UI
    func updateCollectionView() {
        
        // Set up the view model
        let items = (self.model.habitStatistics?.userCounts.map { ViewModel.Item.single($0) } ?? []).sorted(by: >)
        
        // Apply the snapshot
        dataSource.applySnapshotUsing(sectionIDs: [.remaining], itemsBySection: [.remaining: items])
    }
    
    // Create the collection view data source
    func createDataSource() -> DataSourceType {
        
        // Create the cell for each item
        return DataSourceType(collectionView: collectionView) { (collectionView, indexPath, grouping) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserCount", for: indexPath) as! UICollectionViewListCell
            
            var content = UIListContentConfiguration.subtitleCell()
            content.prefersSideBySideTextAndSecondaryText = true
            
            switch grouping {
            case .single(let userStat):
                content.text = userStat.user.name
                content.secondaryText = "\(userStat.count)"
                content.textProperties.font = .preferredFont(forTextStyle: .headline)
                content.secondaryTextProperties.font = .preferredFont(forTextStyle: .body)
            default:
                break
            }
            
            cell.contentConfiguration = content
            
            return cell
        }
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
        
        // Create the section
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0)
        
        return UICollectionViewCompositionalLayout(section: section)
    }

}
