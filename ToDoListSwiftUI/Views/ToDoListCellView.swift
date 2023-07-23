import SwiftUI

struct ToDoListCellView: View {
    var todoItem: TodoItem
    
    var body: some View {
        HStack {
            if todoItem.dateСreation == .distantPast {
                Spacer()
                    .frame(width: 32)
                Text("Новое")
                    .foregroundColor(Color(uiColor: UIColor.tertiaryLabel!))
                    .font(Font(UIFont.body!))
            } else {
                if todoItem.isDone {
                    Image(uiImage: UIImage.greenCheckMarkCircleIcon!)
                } else {
                    switch todoItem.importance {
                    case .important:
                        Image(uiImage: UIImage.importantCircleIcon!)
                    default:
                        Image(uiImage: UIImage.undoneCircleIcon!)
                            .renderingMode(.template)
                    }
                }

                Spacer()
                    .frame(width: 12)
                
                Text(todoItem.text)
                    .strikethrough(todoItem.isDone)
                    .foregroundColor(todoItem.isDone ? Color(uiColor: UIColor.tertiaryLabel!) : Color(uiColor: UIColor.primaryLabel!))
                    .lineLimit(3)
                    .font(Font(UIFont.body!))

                Spacer()
        
                Image(uiImage: UIImage.chevroneRightIcon!)
                    .renderingMode(.template)
                    .foregroundColor(Color(uiColor: .tertiaryLabel!))
                    .padding(.leading, 10)
            }
        }
    }
}

struct ToDoListCellView_Previews: PreviewProvider {
    static var previews: some View {
        ToDoListCellView(todoItem: TodoItem(text: "Превью дело", importance: .ordinary, isDone: false))
    }
}
