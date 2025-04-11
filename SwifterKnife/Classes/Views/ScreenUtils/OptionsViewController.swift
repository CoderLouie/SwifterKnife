//
//  OptionsViewController.swift
//  SwifterKnife
//
//  Created by liyang on 2025/4/11.
//

import UIKit
import SnapKit

fileprivate enum SKOptions: String, CaseIterable {
    case sandbox = "查看沙盒"
    
    func perform(from vc: OptionsViewController) {
        switch self {
            
        case .sandbox:
            Haptic.impact(.medium).generate()
            let newvc = _SKFoldVC()
            newvc.title = "Sandbox"
            newvc.parentPath = NSHomeDirectory()
            vc.navigationController?.pushViewController(newvc, animated: true)
        }
    }
}

class SKCaseCell: UITableViewCell, Reusable {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setup() {
        backgroundColor = .clear
        contentView.backgroundColor = .create("#252429")
        contentView.addCorner(radius: 12.fit)
        textLabel?.textColor = .white
        selectionStyle = .none
        selectedBackgroundView = UIView().then {
            $0.backgroundColor = .clear
        }
    }
    override var frame: CGRect {
        didSet {
            super.frame = frame.with {
                $0.size.height -= 5
            }
        }
    }
}
class OptionsViewController: _BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView = UITableView().then {
            $0.backgroundColor = .clear
            $0.tableFooterView = UIView()
            $0.delegate = self
            $0.dataSource = self
            $0.rowHeight = 50
            $0.register(cellType: SKCaseCell.self)
            view.addSubview($0)
            $0.snp.makeConstraints { make in
                make.top.equalTo(Screen.navbarH)
                make.horizontalSpace(16.fit)
                make.bottom.equalTo(0)
            }
        }
    }
    
    private unowned var tableView: UITableView!
    private lazy var items: [SKOptions] = SKOptions.allCases
}

// MARK: - Delegate
extension OptionsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SKCaseCell = tableView.dequeueReusableCell(for: indexPath)
        cell.textLabel?.text = String(format: "%02d. ", indexPath.row) + items[indexPath.row].rawValue
        return cell
    }
}
extension OptionsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        items[indexPath.row].perform(from: self)
    }
}
