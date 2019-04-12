//
//  PaletteSelectionStepViewController.swift
//  RSDCatalog
//
//  Created by Shannon Young on 4/12/19.
//  Copyright © 2019 Sage Bionetworks. All rights reserved.
//

import UIKit
import Research
import ResearchUI

class PaletteSelectionViewController: UITableViewController {
    
    var titleLabel: UILabel!
    var headerView: UIView!
    
    var choices: [RSDColorPalette]!
    let designSystem = RSDDesignSystem()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let url = Bundle.main.url(forResource: "ColorPalettes", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = CatalogFactory.shared.createJSONDecoder()
                self.choices = try decoder.decode([RSDColorPalette].self, from: data)
            }
            catch let err {
                print("Failed to decode palette choices. \(err)")
            }
        }
        
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 60
        tableView.register(TableSectionHeader.self, forHeaderFooterViewReuseIdentifier: "TableSectionHeader")
        
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return choices?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ColorPalette", for: indexPath) as! ColorPaletteCell
        let selected = tableView.indexPathForSelectedRow == indexPath
        cell.accessoryType = selected ? .checkmark : .none
        
        let palette = choices[indexPath.item]
        
        cell.primary.backgroundColor = palette.primary.normal.color
        cell.primaryLabel.text = "\(palette.primary.swatch.name) \(palette.primary.index)"
        cell.primaryLabel.textColor = designSystem.colorRules.textColor(on: palette.primary.normal, for: .heading4)
        
        cell.secondary.backgroundColor = palette.secondary.normal.color
        cell.secondaryLabel.text = "\(palette.secondary.swatch.name) \(palette.secondary.index)"
        cell.secondaryLabel.textColor = designSystem.colorRules.textColor(on: palette.secondary.normal, for: .heading4)
        
        cell.accent.backgroundColor = palette.accent.normal.color
        cell.accentLabel.text = "\(palette.accent.swatch.name) \(palette.accent.index)"
        cell.accentLabel.textColor = designSystem.colorRules.textColor(on: palette.accent.normal, for: .heading4)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        RSDStudyConfiguration.shared.colorPalette = choices[indexPath.item]
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        if let header = tableView.headerView(forSection: 0) as? TableSectionHeader {
            updateHeader(header)
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Dequeue with the reuse identifier
        let reuseIdentifier = "TableSectionHeader"
        let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: reuseIdentifier) as! TableSectionHeader
        updateHeader(header)
        return header
    }
    
    func updateHeader(_ header: TableSectionHeader) {
        let palette = RSDStudyConfiguration.shared.colorPalette
        header.contentView.backgroundColor = palette.primary.normal.color
        header.titleLabel.textColor = designSystem.colorRules.textColor(on: palette.primary.normal, for: .heading4)
        header.titleLabel.text = "\(palette.primary.swatch.name) \(palette.primary.index)"
        header.secondaryDot.backgroundColor = palette.secondary.normal.color
        header.accentDot.backgroundColor = palette.accent.normal.color
    }
}

class ColorPaletteCell : UITableViewCell {
    @IBOutlet var primary: UIView!
    @IBOutlet var secondary: UIView!
    @IBOutlet var accent: UIView!
    @IBOutlet var primaryLabel: UILabel!
    @IBOutlet var secondaryLabel: UILabel!
    @IBOutlet var accentLabel: UILabel!
}

class TableSectionHeader: UITableViewHeaderFooterView {
    
    var titleLabel: UILabel!
    var secondaryDot: UIView!
    var accentDot: UIView!

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        // Add the title label
        titleLabel = UILabel()
        contentView.addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 0
        titleLabel.textColor = UIColor.darkGray
        titleLabel.textAlignment = .left
        titleLabel.rsd_alignToSuperview([.leading, .trailing], padding: 32, priority: .required)
        titleLabel.rsd_alignToSuperview([.top, .bottom], padding: 12, priority: UILayoutPriority(rawValue: 700))
        
        // Add dots
        secondaryDot = UIView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        contentView.addSubview(secondaryDot)
        
        secondaryDot.translatesAutoresizingMaskIntoConstraints = false
        secondaryDot.rsd_makeWidth(.equal, 24)
        secondaryDot.rsd_makeHeight(.equal, 24)
        secondaryDot.rsd_alignToSuperview([.trailing], padding: 20 + 24 + 12)
        secondaryDot.rsd_alignCenterVertical(padding: 0)
        secondaryDot.layer.cornerRadius = 12
        
        accentDot = UIView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        contentView.addSubview(accentDot)
        
        accentDot.translatesAutoresizingMaskIntoConstraints = false
        accentDot.rsd_makeWidth(.equal, 24)
        accentDot.rsd_makeHeight(.equal, 24)
        accentDot.rsd_alignToSuperview([.trailing], padding: 20)
        accentDot.rsd_alignCenterVertical(padding: 0)
        accentDot.layer.cornerRadius = 12
        
        setNeedsUpdateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
