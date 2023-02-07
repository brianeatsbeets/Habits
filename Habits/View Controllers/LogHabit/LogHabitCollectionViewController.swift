//
//  LogHabitCollectionViewController.swift
//  Habits
//
//  Created by Aguirre, Brian P. on 1/24/23.
//

import UIKit

private let reuseIdentifier = "Cell"

// This class contains the implementation for LogHabitCollectionViewController
class LogHabitCollectionViewController: HabitCollectionViewController {
    
    // Override the createLayout function for a custom implementation
    override func createLayout() -> UICollectionViewCompositionalLayout {
        
        // Using a section provider closure to handle the two different section designs
        return UICollectionViewCompositionalLayout { (sectionIndex, environment) -> NSCollectionLayoutSection? in
            
            // Check if we're in the first section and we have some favorite habits
            if sectionIndex == 0 && self.model.favoriteHabits.count > 0 {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.45), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(100))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0)
                
                return section
                
            // If not, don't display a favorites section
            } else {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
                group.interItemSpacing = .fixed(8)
                group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
                
                let headerSize: NSCollectionLayoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(36))
                let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: SectionHeader.kind.identifier, alignment: .top)
                sectionHeader.edgeSpacing = NSCollectionLayoutEdgeSpacing(leading: nil, top: nil, trailing: nil, bottom: .fixed(40))
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0)
                section.boundarySupplementaryItems = [sectionHeader]
                section.interGroupSpacing = 10
                
                return section
            }
        }
    }
    
    // Send the API request to log a habit
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        
        let loggedHabit = LoggedHabit(userID: Settings.shared.currentUser.id, habitName: item.name, timestamp: Date())
        
        Task {
            try? await LogHabitRequest(loggedHabit: loggedHabit).send()
        }
    }
    
    // Create custom cell configuration for Log Habits view
    override func configureCell(_ cell: UICollectionViewListCell, withItem item: HabitCollectionViewController.ViewModel.Item) {
        
        // Re-configure the cell when there is a change in state (i.e. press)
        cell.configurationUpdateHandler =  { cell, state in
            
            // Configure test and margins
            var content = UIListContentConfiguration.cell().updated(for: state)
            content.text = item.name
            content.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 11, leading: 8, bottom: 11, trailing: 8)
            content.textProperties.alignment = .center
            cell.contentConfiguration = content
            
            // Configure background color
            var backgroundConfiguration = UIBackgroundConfiguration.listPlainCell().updated(for: state)
            
            if Settings.shared.favoriteHabits.contains(item) {
                backgroundConfiguration.backgroundColor = favoriteHabitColor
            } else {
                backgroundConfiguration.backgroundColor = .systemGray6
            }
            
            if state.isHighlighted {
                
                // Reduce the alpha of the tint color to 30% when highlighted
                backgroundConfiguration.backgroundColorTransformer = .init { $0.withAlphaComponent(0.3) }
            }
            
            backgroundConfiguration.cornerRadius = 8
            cell.backgroundConfiguration = backgroundConfiguration
        }
        
        // Create a shadow effect to give the cells more depth
        cell.layer.shadowRadius = 3
        cell.layer.shadowColor = UIColor.systemGray3.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 2)
        cell.layer.shadowOpacity = 1
        cell.layer.masksToBounds = false
    }
    
}
