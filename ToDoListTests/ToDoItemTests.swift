import XCTest
@testable import ToDoList

final class ToDoItemTests: XCTestCase {
    //MARK: - Настройка
    var todoItem: TodoItem!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        todoItem = TodoItem(id: "1", text: "тест", importance: .ordinary, isDone: false, dateСreation: Date(timeIntervalSince1970: 1100133188.0))
    }

    override func tearDownWithError() throws {
        todoItem = nil
        try super.tearDownWithError()
    }
    
    //MARK: - TodoItem, parsing json тесты
    func testJSONParse() throws {
        // Тест на проверку метода parse(json: )
        
        let todoItemHelper = TodoItem.parse(json: ["id": "1",
                                                   "text": "тест",
                                                   "is_done": false,
                                                   "date_creation": 1100133188.0])!
        
        XCTAssertEqual(todoItem.id, todoItemHelper.id)
        XCTAssertEqual(todoItem.text, todoItemHelper.text)
        XCTAssertEqual(todoItem.importance, todoItemHelper.importance)
        XCTAssertEqual(todoItem.deadline, todoItemHelper.deadline)
        XCTAssertEqual(todoItem.isDone, todoItemHelper.isDone)
        XCTAssertEqual(todoItem.dateСreation, todoItemHelper.dateСreation)
        XCTAssertEqual(todoItem.dateChanging, todoItemHelper.dateChanging)
    }
    
    func testJSONOrdinaryImportance() {
        // Тест на сохранение сохранение в json кейсов Importance, кроме ordinary
        
        let todoItemHelper = TodoItem(id: "1", text: "тест", importance: .important, deadline: nil, isDone: false, dateСreation: Date(timeIntervalSince1970: 1100133188), dateChanging: nil)
        let todoItemJson = todoItemHelper.json as! [String: Any]
        let resultJson = ["id": "1", "text": "тест", "is_done": false, "date_creation": 1100133188.0, "importance": "important"] as! [String: Any]
        
        XCTAssertEqual(todoItemJson["importance"] as? String, resultJson["importance"] as? String)
    }
    
    func testJSONCheckDates() throws {
        // Тест на сохранение в json типов не сложных типов Date, а unix-timestamp
        
        let todoItemJson = TodoItem(id: "1", text: "тест", importance: .ordinary, deadline: Date(timeIntervalSince1970: 1100133188), isDone: false, dateСreation: Date(timeIntervalSince1970: 1100133188), dateChanging: Date(timeIntervalSince1970: 1100133188)).json as! [String: Any]
        let resultJson = ["id": "1", "text": "тест", "is_done": false, "date_creation": 1100133188.0, "date_changing": 1100133188.0, "deadline": 1100133188.0] as! [String: Any]
        
        XCTAssertEqual(todoItemJson["deadline"] as? Double, resultJson["deadline"] as? Double)
        XCTAssertEqual(todoItemJson["date_creation"] as! Double, resultJson["date_creation"] as! Double)
        XCTAssertEqual(todoItemJson["date_changing"] as? Double, resultJson["date_changing"] as? Double)
    }
    
    func testJSONNilDeadline() throws {
        // Тест на проверку отсутсвия в json deadline, если он nil
        
        let todoItemJson = todoItem.json as! [String: Any]
        let resultJson = ["id": "1", "text": "тест", "is_done": false, "date_creation": 1100133188.0] as! [String: Any]
        
        XCTAssertEqual(todoItemJson["deadline"] as? Double, resultJson["deadline"] as? Double)
    }
    
    //MARK: - CSV Тесты
    func testCSVParse() throws {
        // Тест на проверку метода parse(csv: )
        
        let todoItemHelper = TodoItem.parse(csv: "1;тест;;;false;1100133188.0;")!
        
        XCTAssertEqual(todoItem.id, todoItemHelper.id)
        XCTAssertEqual(todoItem.text, todoItemHelper.text)
        XCTAssertEqual(todoItem.importance, todoItemHelper.importance)
        XCTAssertEqual(todoItem.deadline, todoItemHelper.deadline)
        XCTAssertEqual(todoItem.isDone, todoItemHelper.isDone)
        XCTAssertEqual(todoItem.dateСreation, todoItemHelper.dateСreation)
        XCTAssertEqual(todoItem.dateChanging, todoItemHelper.dateChanging)
    }
    
    func testCSVNilDeadline() throws {
        // Тест на проверку отсутсвия в csv deadline, если он nil
        XCTAssertEqual(todoItem.csv, "1;тест;;;false;1100133188.0;")
    }
    
    func testCSVOrdinaryImportance() {
        // Тест на сохранение сохранение в csv свойстве кейсов Importance, кроме ordinary
        let todoItemHelper = TodoItem(id: "2", text: "тест", importance: .important, isDone: false, dateСreation: Date(timeIntervalSince1970: 1100133188.0))
        let todoItemHelper2 = TodoItem(id: "3", text: "тест", importance: .unimportant, isDone: false, dateСreation: Date(timeIntervalSince1970: 1100133188.0))
        
        XCTAssertEqual(todoItem.csv, "1;тест;;;false;1100133188.0;")
        XCTAssertEqual(todoItemHelper.csv, "2;тест;important;;false;1100133188.0;")
        XCTAssertEqual(todoItemHelper2.csv, "3;тест;unimportant;;false;1100133188.0;")
    }

    func testCSVCheckDates() throws {
        // Тест на сохранение в csv свойстве типов не сложных типов Date, а unix-timestamp

        let todoItemHelper = TodoItem(id: "1", text: "тест", importance: .ordinary, deadline: Date(timeIntervalSince1970: 1100133188), isDone: false, dateСreation: Date(timeIntervalSince1970: 1100133188), dateChanging: Date(timeIntervalSince1970: 1100133188))

        XCTAssertEqual(todoItemHelper.csv, "1;тест;;1100133188.0;false;1100133188.0;1100133188.0")
    }
    
    
    //MARK: - Общие тесты (с JSON и СSV)
    func testParseFromJSONgetCSV() {
        // Тест на проверку инициализации TodoItem c помощью parse(json: Any) и получение из него csv: String
        
        let todoItemHelperCsv = TodoItem.parse(json: ["id": "1",
                                                   "text": "тест",
                                                   "importance": "ordinary",
                                                   "deadline": nil,
                                                   "is_done": false,
                                                   "date_creation": 1100133188.0,
                                                   "date_changing": nil])!.csv

        XCTAssertEqual(todoItemHelperCsv, "1;тест;;;false;1100133188.0;")
    }
    
    func testParseFromCSVgetJSON() {
        // Тест на проверку инициализации TodoItem c помощью parse(csv: String) и получение из него json: Any
        
        let todoItemHelperJson = TodoItem.parse(csv: "1;тест;;;false;1100133188.0;")!.json as! [String: Any]
        let resultJson = ["id": "1", "text": "тест", "is_done": false, "date_creation": 1100133188.0] as! [String: Any]
        
        XCTAssertEqual(todoItemHelperJson["id"] as! String, resultJson["id"] as! String)
        XCTAssertEqual(todoItemHelperJson["text"] as! String, resultJson["text"] as! String)
        XCTAssertEqual(todoItemHelperJson["importance"] as? String, resultJson["importance"] as? String)
        XCTAssertEqual(todoItemHelperJson["deadline"] as? Double, resultJson["deadline"] as? Double)
        XCTAssertEqual(todoItemHelperJson["is_done"] as! Bool, resultJson["is_done"] as! Bool)
        XCTAssertEqual(todoItemHelperJson["date_creation"] as! Double, resultJson["date_creation"] as! Double)
        XCTAssertEqual(todoItemHelperJson["date_changing"] as? Double, resultJson["date_changing"] as? Double)
    }
    
    //MARK: - TodoItem тесты
    func testTodoItemInit() {
        // Тест на проверку инициализации TodoItem
        
        let todoItemHelper = TodoItem(id: "1", text: "тест", importance: .ordinary, deadline: nil, isDone: false, dateСreation: Date(timeIntervalSince1970: 1100133188.0), dateChanging: nil)
    
        XCTAssertEqual(todoItem.id, todoItemHelper.id)
        XCTAssertEqual(todoItem.text, todoItemHelper.text)
        XCTAssertEqual(todoItem.importance, todoItemHelper.importance)
        XCTAssertEqual(todoItem.deadline, todoItemHelper.deadline)
        XCTAssertEqual(todoItem.isDone, todoItemHelper.isDone)
        XCTAssertEqual(todoItem.dateСreation, todoItemHelper.dateСreation)
        XCTAssertEqual(todoItem.dateChanging, todoItemHelper.dateChanging)
    }
    
    func testGenerateIdIfNotGiven() {
        // Проверка на генерацию id если не задан в аргументе функции
        
        let todoItemHelper = TodoItem(text: "тест", importance: .ordinary, isDone: false)
        XCTAssertTrue(!todoItemHelper.id.isEmpty)
    }
    
    func testDeadlineNilIfNotGiven() {
        // Проверка на свойство deadline, если не задан в аргументе функции, то nil
        
        XCTAssertTrue(todoItem.deadline == nil)
    }
    
    func testDateChangingNilIfNotGiven() {
        // Проверка на свойство deadline, если не задан в аргументе функции, то nil
    
        XCTAssertTrue(todoItem.deadline == nil)
    }
    
    func testIdentifibleTwoItems() {
        // Проверка на уникальность обьектов с заданными id явно и не явно
        
        let todoItemHelper = TodoItem(text: "тест", importance: .ordinary, deadline: nil, isDone: false, dateСreation: Date(timeIntervalSince1970: 1100133188.0), dateChanging: nil)
        
        XCTAssertNotEqual(todoItemHelper.id, todoItem.id)
    }
}
