//
//  SeparatorLineView.swift
//  ToDoList
//
//  Created by Ильгам Нафиков on 23.06.2023.
//

import UIKit

class SeparatorLineView: UIView {

    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .separatorSupport
    }
    
}
