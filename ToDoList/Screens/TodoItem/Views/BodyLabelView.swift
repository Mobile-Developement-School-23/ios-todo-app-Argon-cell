//
//  BodyLabelView.swift
//  ToDoList
//
//  Created by Ильгам Нафиков on 23.06.2023.
//

import UIKit

class BodyLabelView: UILabel {

    init() {
        super.init(frame: .zero)
        setupTextView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupTextView() {
        font = UIFont.body
    }
    
}
