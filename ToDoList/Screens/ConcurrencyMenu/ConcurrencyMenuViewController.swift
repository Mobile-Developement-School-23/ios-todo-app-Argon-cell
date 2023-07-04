//
//  ConcurrencyMenuViewController.swift
//  ToDoList
//
//  Created by Ильгам Нафиков on 04.07.2023.
//

import UIKit
import CocoaLumberjackSwift

class ConcurrencyMenuViewController: UIViewController {
    //MARK: - Properties
    let dataHolder: DataHolder
    
    //MARK: - Setup before test
    let url = URL(string: "https://jsonplaceholder.typicode.com/todos")!
    let defaultResultDataCount = 200
    let loopIterationCount = 200
    
    //MARK: - Views
    private lazy var dataCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var shouldBeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        return label
    }()
    
    //MARK: - Inits
    init(dataHolder: DataHolder) {
        self.dataHolder = dataHolder
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .primaryBack
        self.view.addSubview(dataCountLabel)
        self.view.addSubview(shouldBeLabel)
        
        dataCountLabel.translatesAutoresizingMaskIntoConstraints = false
        dataCountLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        dataCountLabel.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -10).isActive = true
        
        shouldBeLabel.translatesAutoresizingMaskIntoConstraints = false
        shouldBeLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        shouldBeLabel.topAnchor.constraint(equalTo: dataCountLabel.bottomAnchor, constant: 15).isActive = true

        let request = URLRequest(url: url)
        let should = 2 * loopIterationCount * defaultResultDataCount
        shouldBeLabel.text = "\(should) должно быть данных"
    
        Task {
            makeUpdateTask(with: request, count: loopIterationCount)
            makeUpdateTask(with: request, count: loopIterationCount)
        }
    }
    
    //MARK: - Methods
    func makeUpdateTask(with request: URLRequest, count: Int) {
        Task {
            for _ in 1...count {
                let data = await makeRequestTest(urlRequest: request)
                dataHolder.update(by: data)
                DispatchQueue.main.async {
                    self.dataCountLabel.text = "\(self.dataHolder.jsonValues.count) данных пришло"
                }
                
            }
        }
    }
    
    func makeRequestTest(urlRequest: URLRequest) async -> [Any] {
        guard let resultData = try? await URLSession.shared.data(for: urlRequest).0 else { return [] }
        let jsonObject = try? JSONSerialization.jsonObject(with: resultData) as? [Any]
        
        if let jsonObject = jsonObject {
            return jsonObject
        } else {
            return []
        }
    }
}
