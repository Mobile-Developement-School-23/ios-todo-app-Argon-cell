@testable import ToDoList
import XCTest

final class ToDoItemTests: XCTestCase {
    // MARK: - TodoItem тесты

    func test_GenerateIdIfNotGiven() {
        // Проверка на генерацию id если не задан в аргументе функции

        let todoItemHelper = TodoItem(text: "тест", importance: .ordinary)
       
        XCTAssertTrue(!todoItemHelper.id.isEmpty)
    }

    func test_dateDeadlineNilIfNotGiven() {
        // Проверка на свойство dateDeadline, если не задан в аргументе функции, то nil

        let todoItemHelper = TodoItem(text: "тест", importance: .ordinary)
       
        XCTAssertTrue(todoItemHelper.dateDeadline == nil)
    }

    func test_DateChangingNilIfNotGiven() {
        // Проверка на свойство dateDeadline, если не задан в аргументе функции, то nil

        let todoItemHelper = TodoItem(text: "тест", importance: .ordinary)
       
        XCTAssertTrue(todoItemHelper.dateChanging == nil)
    }

    func test_IdentifibleTwoItems() {
        // Проверка на уникальность обьектов с заданными id явно и не явно

        let todoItemHelper1 = TodoItem(id: "1", text: "тест", importance: .ordinary)
        let todoItemHelper2 = TodoItem(text: "тест", importance: .ordinary)

        XCTAssertNotEqual(todoItemHelper1.id, todoItemHelper2.id)
    }

    // MARK: - TodoItem, parsing json тесты
    
    func test_ParseJson() throws {
        // Базовый тест на проверку метода parse(json: )
        
        let todoItemHelper1 = TodoItem.parse(json: ["id": "1",
                                                    "text": "тест",
                                                    "is_done": false,
                                                    "date_creation": 1100133188.0])!
        
        let todoItemHelper2 = TodoItem(id: "1", text: "тест", importance: .ordinary, dateСreation: Date(timeIntervalSince1970: 1100133188.0))
        
        XCTAssertEqual(todoItemHelper1.id, todoItemHelper2.id)
        XCTAssertEqual(todoItemHelper1.text, todoItemHelper2.text)
        XCTAssertEqual(todoItemHelper1.importance, todoItemHelper2.importance)
        XCTAssertEqual(todoItemHelper1.dateDeadline, todoItemHelper2.dateDeadline)
        XCTAssertEqual(todoItemHelper1.isDone, todoItemHelper2.isDone)
        XCTAssertEqual(todoItemHelper1.dateСreation, todoItemHelper2.dateСreation)
        XCTAssertEqual(todoItemHelper1.dateChanging, todoItemHelper2.dateChanging)
    }
    
    func test_ParseJsonIfIdNotGiven() throws {
        // Тест на проверку метода parse(json: ), если не задан id
        
        let todoItemHelper1 = TodoItem.parse(json: ["text": "тест",
                                                    "is_done": false,
                                                    "date_creation": 1100133188.0])
        
        XCTAssertNil(todoItemHelper1)
    }
    
    func test_ParseJsonIfTextNotGiven() throws {
        // Тест на проверку метода parse(json: ), если не задан text
        
        let todoItemHelper1 = TodoItem.parse(json: ["id": "1",
                                                    "is_done": false,
                                                    "date_creation": 1100133188.0])
        XCTAssertNil(todoItemHelper1)
    }
    
    func test_ParseJsonIfDateCreationNotGiven() throws {
        // Тест на проверку метода parse(json: ), если не задана дата создания
        
        let todoItemHelper1 = TodoItem.parse(json: ["id": "1",
                                                    "text": "тест",
                                                    "is_done": false])
        XCTAssertNil(todoItemHelper1)
    }
    
    func test_ParseJsonIfEmptyGiven() throws {
        // Тест на проверку метода parse(json: ), если пустой словарь
        
        let todoItemHelper1 = TodoItem.parse(json: [])
        XCTAssertNil(todoItemHelper1)
    }
    
    func test_ParseJsonIfDiffDataAdded() throws {
        // Тест на проверку метода parse(json: ), если дополнительно даны какие-то другие данные
        
        let todoItemHelper1 = TodoItem.parse(json: ["id": "1",
                                                    "text": "тест",
                                                    "is_done": false,
                                                    "date_creation": 1100133188.0,
                                                    "color": "red"])

        XCTAssertNotNil(todoItemHelper1)
    }
    
    func test_JsonNotOrdinaryImportance() {
        // Тест на сохранение сохранение в json кейсов Importance, кроме ordinary
        
        let todoItemJsonHelper = TodoItem(text: "тест", importance: .important).json as! [String: Any]
        let todoItemJsonHelper2 = TodoItem(text: "тест", importance: .ordinary).json as! [String: Any]
        let todoItemJsonHelper3 = TodoItem(text: "тест", importance: .unimportant).json as! [String: Any]
    
        XCTAssertNil(todoItemJsonHelper2["importance"])
        XCTAssertEqual(todoItemJsonHelper["importance"] as! String, "important")
        XCTAssertEqual(todoItemJsonHelper3["importance"] as! String, "unimportant")
    }
    
    func test_JsonCheckDates() throws {
        // Тест на сохранение в json типов не сложных типов Date, а unix-timestamp
        
        let todoItemJsonHelper = TodoItem(text: "тест", importance: .ordinary, dateDeadline: Date(timeIntervalSince1970: 1100133188), dateСreation: Date(timeIntervalSince1970: 1100133188), dateChanging: Date(timeIntervalSince1970: 1100133188)).json as! [String: Any]
        
        XCTAssertEqual(todoItemJsonHelper["date_deadline"] as! Double, 1100133188.0)
        XCTAssertEqual(todoItemJsonHelper["date_creation"] as! Double, 1100133188.0)
        XCTAssertEqual(todoItemJsonHelper["date_changing"] as! Double, 1100133188.0)
    }
    
    func test_JsonNildateDeadline() throws {
        // Тест на проверку отсутсвия в json dateDeadline, если он nil
        
        let todoItemJsonHelper = TodoItem(text: "тест", importance: .ordinary).json as! [String: Any]
        
        XCTAssertNil(todoItemJsonHelper["date_deadline"])
    }
    
    // MARK: - TodoItem, parsing csv тесты

    func test_ParseCsv() throws {
        // Тест на проверку метода parse(csv: )

        let todoItemHelper1 = TodoItem.parse(csv: "1;тест;;;false;1100133188.0;")!
        let todoItemHelper2 = TodoItem(id: "1", text: "тест", importance: .ordinary, dateСreation: Date(timeIntervalSince1970: 1100133188.0))
        
        XCTAssertEqual(todoItemHelper1.id, todoItemHelper2.id)
        XCTAssertEqual(todoItemHelper1.text, todoItemHelper2.text)
        XCTAssertEqual(todoItemHelper1.importance, todoItemHelper2.importance)
        XCTAssertEqual(todoItemHelper1.dateDeadline, todoItemHelper2.dateDeadline)
        XCTAssertEqual(todoItemHelper1.isDone, todoItemHelper2.isDone)
        XCTAssertEqual(todoItemHelper1.dateСreation, todoItemHelper2.dateСreation)
        XCTAssertEqual(todoItemHelper1.dateChanging, todoItemHelper2.dateChanging)
    }
    
    func test_CsvNotOrdinaryImportance() {
        // Тест на сохранение сохранение в csv свойстве кейсов Importance, кроме ordinary
        
        let todoItemCsvHelper1 = TodoItem(id: "1", text: "тест", importance: .ordinary, isDone: false, dateСreation: Date(timeIntervalSince1970: 1100133188.0)).csv
        let todoItemCsvHelper2 = TodoItem(id: "2", text: "тест", importance: .important, isDone: false, dateСreation: Date(timeIntervalSince1970: 1100133188.0)).csv
        let todoItemCsvHelper3 = TodoItem(id: "3", text: "тест", importance: .unimportant, isDone: false, dateСreation: Date(timeIntervalSince1970: 1100133188.0)).csv

        XCTAssertEqual(todoItemCsvHelper1, "1;тест;;;false;1100133188.0;")
        XCTAssertEqual(todoItemCsvHelper2, "2;тест;important;;false;1100133188.0;")
        XCTAssertEqual(todoItemCsvHelper3, "3;тест;unimportant;;false;1100133188.0;")
    }

    func test_CsvCheckDates() throws {
        // Тест на сохранение в csv свойстве типов не сложных типов Date, а unix-timestamp

        let todoItemCsvHelper = TodoItem(id: "1", text: "тест", importance: .ordinary, dateDeadline: Date(timeIntervalSince1970: 1100133188), isDone: false, dateСreation: Date(timeIntervalSince1970: 1100133188), dateChanging: Date(timeIntervalSince1970: 1100133188)).csv

        XCTAssertEqual(todoItemCsvHelper, "1;тест;;1100133188.0;false;1100133188.0;1100133188.0")
    }
    
    func test_CsvNildateDeadline() throws {
        // Тест на проверку отсутсвия в csv dateDeadline, если он nil
        
        let todoItemCsvHelper = TodoItem(id: "1", text: "тест", importance: .ordinary, isDone: false, dateСreation: Date(timeIntervalSince1970: 1100133188.0)).csv
        XCTAssertEqual(todoItemCsvHelper, "1;тест;;;false;1100133188.0;")
    }

//    //MARK: - TodoItem, parsing json & csv тесты
    func test_ParseFromJSONgetCSV() {
        // Тест на проверку инициализации TodoItem c помощью parse(json: Any) и получение из него csv: String

        let todoItemHelperCsv = TodoItem.parse(json: ["id": "1",
                                                      "text": "тест",
                                                      "importance": "ordinary",
                                                      "date_deadline": nil,
                                                      "is_done": false,
                                                      "date_creation": 1100133188.0,
                                                      "date_changing": nil])!.csv

        XCTAssertEqual(todoItemHelperCsv, "1;тест;;;false;1100133188.0;")
    }

    func test_ParseFromCSVgetJSON() {
        // Тест на проверку инициализации TodoItem c помощью parse(csv: String) и получение из него json: Any

        let todoItemHelperJson = TodoItem.parse(csv: "1;тест;;;false;1100133188.0;")!.json as! [String: Any]

        XCTAssertEqual(todoItemHelperJson["id"] as! String, "1")
        XCTAssertEqual(todoItemHelperJson["text"] as! String, "тест")
        XCTAssertEqual(todoItemHelperJson["importance"] as? String, nil)
        XCTAssertEqual(todoItemHelperJson["date_deadline"] as? Double, nil)
        XCTAssertEqual(todoItemHelperJson["is_done"] as! Bool, false)
        XCTAssertEqual(todoItemHelperJson["date_creation"] as! Double, 1100133188.0)
        XCTAssertEqual(todoItemHelperJson["date_changing"] as? Double, nil)
    }
}
