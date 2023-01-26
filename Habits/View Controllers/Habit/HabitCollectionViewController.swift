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
    
    // Keep track of async tasks so they can be cancelled when appropriate
    var habitsRequestTask: Task<Void, Never>? = nil
    deinit { habitsRequestTask?.cancel() }
    
    // Diffable data source typealias
    typealias DataSourceType = UICollectionViewDiffableDataSource<ViewModel.Section, ViewModel.Item>
    
    // This enum encapsulates everything the collection view needs to display the data - section identifiers and item identifiers
    enum ViewModel {
        enum Section: Hashable {
            case favorites
            case category(_ category: Category)
        }
        
        typealias Item = Habit
    }
    
    // This struct defines the Model as unique from the view model
    struct Model {
        var habitsByName = [String: Habit]()
    }
    
    var dataSource: DataSourceType!
    
    // Store the model data returned from an API call
    var model = Model()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
    }
}
