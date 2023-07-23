import SwiftUI

enum HeaderState: String {
    case show
    case hide
    
    mutating func togle() {
        self = self == .hide ? .show : .hide
    }
}

struct HeaderView: View {
    @Binding var state: HeaderState
    @Binding var items: [TodoItem]
    
    var body: some View {
        HStack {
            Text("Выполненно — \(items.filter{ $0.isDone }.count)")
                .foregroundColor(Color(uiColor: .customSecondaryLabel!))
                .textCase(nil)
                .font(Font(UIFont.subhead!))
                
            
            Spacer()
            
            Button {
                state.togle()
            } label: {
                Text(state == .show ? "Показать" : "Скрыть")
                    .foregroundColor(Color(uiColor: .customBlue!))
                    .font(Font(UIFont.subhead!))
//                    .bold()
                    .textCase(nil)
            }

        }
    }
}

struct HeaderVie_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView(state: .constant(.hide), items: .constant([]))
    }
}
