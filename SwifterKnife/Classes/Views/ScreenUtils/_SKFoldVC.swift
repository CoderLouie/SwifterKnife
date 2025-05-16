//
//  _SKFoldVC.swift
//  SwifterKnife
//
//  Created by liyang on 2025/4/11.
//

import Foundation

import UIKit
import SwifterKnife

class _SKFoldVC: _BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBody()
    }
    var parentPath = ""
    private var previewPath = ""
    private unowned var tableView: UITableView!
    
    private lazy var items = (try? FileManager.default.contentsOfDirectory(atPath: parentPath).compactMap { str -> String? in
        if str.hasPrefix(".") { return nil }
        let path = parentPath + "/" + str
        if SandBox.isDirectory(path) { return "/" + str }
        guard let attr = try? FileManager.default.attributesOfItem(atPath: path),
              let size = attr[.size] as? Int else { return str }
        
        return str + " \(Int(round(Double(size) / 1024.0)))KB"
    }) ?? []
}
fileprivate extension String {
    func xxtruncated() -> String {
        if count <= 29 { return self }
        return self[startIndex..<index(startIndex, offsetBy: 10)] + "..." + self[index(endIndex, offsetBy: -16)...]
    }
}
// MARK: - Delegate
extension _SKFoldVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SKCaseCell = tableView.dequeueReusableCell(for: indexPath)
        cell.textLabel?.text = items[indexPath.row].xxtruncated()
        return cell
    }
}
import QuickLook
extension _SKFoldVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = _SKFoldVC()
        let name = items[indexPath.row]
        vc.title = name
        vc.parentPath = parentPath + name
        if !vc.items.isEmpty {
            navigationController?.pushViewController(vc, animated: true)
            return
        }
        previewPath = parentPath + "/" + (name.splitBy(charactersIn: " ").first ?? "")
        let previewVC = QLPreviewController()
        previewVC.dataSource = self
        present(previewVC, animated: true)
    }
}
extension _SKFoldVC: QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        1
    }
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> any QLPreviewItem {
        NSURL(fileURLWithPath: previewPath)
    }
}
// MARK: - Create Views
extension _SKFoldVC { 
    private func setupBody() {
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
                make.bottom.equalTo(-Screen.tabbarH)
            }
        }
    }
}
