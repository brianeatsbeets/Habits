//
//  UICollectionViewDiffableDataSource+ViewModel.swift
//  Habits
//
//  Created by Aguirre, Brian P. on 1/26/23.
//

import UIKit

// This extension implements a generic way to build snapshots based on view models
extension UICollectionViewDiffableDataSource {
    
    
    func applySnapshotUsing(sectionIDs: [SectionIdentifierType], itemsBySection: [SectionIdentifierType: [ItemIdentifierType]], sectionsRetainedIfEmpty: Set<SectionIdentifierType> = Set<SectionIdentifierType>()) {
        applySnapshotUsing(sectionIDs: sectionIDs, itemsBySection: itemsBySection, animatingDifferences: true, sectionsRetainedIfEmpty: sectionsRetainedIfEmpty)
    }
    
    func applySnapshotUsing(sectionIDs: [SectionIdentifierType], itemsBySection: [SectionIdentifierType: [ItemIdentifierType]], animatingDifferences: Bool, sectionsRetainedIfEmpty: Set<SectionIdentifierType> = Set<SectionIdentifierType>()) {
        var snapshot = NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>()
        
        for sectionID in sectionIDs {
            
            // Make sure that the section isn't empty, or if it is, that it is a "retained" section (all habits in the section are favorited)
            guard let sectionItems = itemsBySection[sectionID],
                  sectionItems.count > 0 || sectionsRetainedIfEmpty.contains(sectionID) else { continue }
            
            
            // Append sections and items
            snapshot.appendSections([sectionID])
            snapshot.appendItems(sectionItems, toSection: sectionID)
        }
        
        // Apply the snapshot
        self.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}
