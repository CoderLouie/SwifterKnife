//
//  OptionsViewController.swift
//  SwifterKnife
//
//  Created by liyang on 2025/4/11.
//

import UIKit

public protocol SKSOptionHandler {
    func addOption(_ title: String, action: @escaping (_ vc: UIViewController) -> Void)
}

fileprivate struct SKOptions {
    let title: String
    let action: (_ vc: UIViewController) -> Void
}

class SKCaseCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setup() {
        backgroundColor = .clear
        contentView.backgroundColor = UIColor(red: 37 / 255.0, green: 36 / 255.0, blue: 41 / 255.0, alpha: 1)
        contentView.layer.do {
            $0.masksToBounds = true
            $0.cornerRadius = 12
        }
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
//            $0.register(cellType: SKCaseCell.self)
            $0.register(SKCaseCell.self, forCellReuseIdentifier: "SKCaseCell")
            view.addSubview($0)
            $0.doConstraints { make in
                make.topEqualTo(Screen.navbarH)
                make.horizontalEqualTo(16)
                make.bottomEqualTo(-Screen.tabbarH)
            }
        }
    }
    
    private unowned var tableView: UITableView!
    private var items: [SKOptions] = [
        .init(title: "查看沙盒") { vc in
            UIImpactFeedbackGenerator(style: .medium).do {
                $0.prepare()
                $0.impactOccurred()
            }
            let newvc = _SKFoldVC()
            newvc.title = "Sandbox"
            newvc.parentPath = NSHomeDirectory()
            vc.navigationController?.pushViewController(newvc, animated: true)
        }
    ]
}

// MARK: - Delegate
extension OptionsViewController: SKSOptionHandler {
    func addOption(_ title: String, action: @escaping (UIViewController) -> Void) {
        items.append(.init(title: title, action: action))
    }
    func reloadIfNeeded() {
        if isViewLoaded {
            tableView.reloadData()
        }
    }
}
extension OptionsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SKCaseCell = tableView.dequeueReusableCell(withIdentifier: "SKCaseCell", for: indexPath) as! SKCaseCell
        cell.textLabel?.text = String(format: "%02d. ", indexPath.row) + items[indexPath.row].title
        return cell
    }
}
extension OptionsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        items[indexPath.row].action(self)
    }
}
