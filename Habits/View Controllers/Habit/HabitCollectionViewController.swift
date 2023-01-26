//
//  HabitCollectionViewController.swift
//  Habits
//
//  Created by Aguirre, Brian P. on 1/24/23.
//

import UIKit

private let reuseIdentifier = "Cell"

// This class contains the implementation for HabitCollectionViewController
// This class utilizes a hybrid MVC-MVVM approach
class HabitCollectionViewController: UICollectionViewController {
    
    // ---------------------------------------------------------------------------------------- //
    
    // Keep track of async tasks so they can be cancelled when appropriate
    var habitsRequestTask: Task<Void, Never>? = nil
    deinit { habitsRequestTask?.cancel() }
    
    // Diffable data source typealias
    typealias DataSourceType = UICollectionViewDiffableDataSource<ViewModel.Section, ViewModel.Item>
    
    // This enum encapsulates everything the collection view needs to display the data - section identifiers and item identifiers
    enum ViewModel {
        enum Section: Hashable, Comparable {
            case favorites
            case category(_ category: Category)
            
            // Sort categories by name, and make sure favorites is at the beginning
            static func < (lhs: Section, rhs: Section) -> Bool {
                switch (lhs, rhs) {
                case (.category(let l), .category(let r)):
                    return l.name < r.name
                case (.favorites, _):
                    return true
                case (_, .favorites):
                    return false
                }
            }
        }
        
        typealias Item = Habit
    }
    
    // This struct defines the model data to be displayed by the view model
    struct Model {
        var habitsByName = [String: Habit]()
        var favoriteHabits: [Habit] {
            return Settings.shared.favoriteHabits
        }
    }
    
    // ---------------------------------------------------------------------------------------- //
    
    var dataSource: DataSourceType!
    
    // Store the model data returned from an API call
    var model = Model()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = createDataSource()
        collectionView.dataSource = dataSource
        collectionView.collectionViewLayout = createLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Update the data on each visit
        update()
    }
    
    // Get habit objects from the server
    func update() {
        
        // Cancel existing tasks
        habitsRequestTask?.cancel()
        
        // Create a new task
        habitsRequestTask = Task {
            if let habits = try? await HabitRequest().send() {
                self.model.habitsByName = habits
            } else {
                self.model.habitsByName = [:]
            }
            
            self.updateCollectionView()
            
            habitsRequestTask = nil
        }
    }
    
    // Update the collection view UI
    func updateCollectionView() {
        
        // Build a dictionary that maps each section to its associated array of items
        var itemsBySection = model.habitsByName.values.reduce(into: [ViewModel.Section: [ViewModel.Item]]()) { partial, habit in
            
            // Get the next habit
            let item = habit
            
            let section: ViewModel.Section
            
            // If the current model has the habit marked as a favorite habit, assign it to the favorites section
            if model.favoriteHabits.contains(habit) {
                section = .favorites
            } else {
                
                // Otherwise, assign it to the section for its category
                section = .category(habit.category)
            }
            
            // Append the habit to the dictionary in the appropriate section
            partial[section, default: []].append(item)
        }
        
        // Sort the items in each section
        itemsBySection = itemsBySection.mapValues { $0.sorted() }
        
        // Store the section IDs for all categories, sorted by name
        let sectionIDs = itemsBySection.keys.sorted()
        
        // Apply the snapshot
        dataSource.applySnapshotUsing(sectionIDs: sectionIDs, itemsBySection: itemsBySection)
        
    }
    
    // Create the collection view data source
    func createDataSource() -> DataSourceType {
        let dataSource = DataSourceType(collectionView: collectionView) { collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Habit", for: indexPath) as! UICollectionViewListCell
            
            var content = cell.defaultContentConfiguration()
            content.text = item.name
            cell.contentConfiguration = content
            
            return cell
        }
        
        return dataSource
    }
    
    // Create a list-style compositional layout
    func createLayout() -> UICollectionViewCompositionalLayout {
        
        // Create the item
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // Create the group
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(44))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        
        // Create the section
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}
