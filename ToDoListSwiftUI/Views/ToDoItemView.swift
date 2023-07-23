import SwiftUI

struct ToDoItemView: View {
    @State var item: TodoItem
    
    var body: some View {
        ZStack {
            Color(uiColor: .primaryBack!)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading) {
                    HStack {
                        Button {
                            
                        } label: {
                            Text("Отменить")
                        }
                        
                        Spacer()
                        
                        Text("Дело")
                            .font(Font(UIFont.body!))
                        
                        Spacer()
                        
                        Button {
                            
                        } label: {
                            Text("Отменить")
                        }
                    }
                    .padding(.bottom)
                    
                    VStack(alignment: .center) {
                        TextView() {
                            $0.text = item.text.isEmpty ? "Что надо сделать?" : item.text
                            $0.font = UIFont.body
                            $0.autocorrectionType = .no
                            $0.layer.cornerRadius = 16
                            $0.backgroundColor = UIColor.secondaryBack
                            $0.isScrollEnabled = false
                            $0.textContainerInset = UIEdgeInsets.init(top: 16, left: 11, bottom: 16, right: 16)
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Важность")
                            
                            Spacer()
                            
                            Picker("", selection: $item.importance) {
                                Image(uiImage: .lowImportanceIcon!).tag(0)
                                Text("нет").tag(1)
                                Image(uiImage: .highImportanceIcon!).tag(2)
                                
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 200)
                        }
                        .padding()
                        
                        HStack {
                            Text("Сделать до")
                            
                            Toggle(isOn: $item.isDone) {
                                
                            }
                            
                            Spacer()
                        }
                        .padding()
                    }
                    .cornerRadius(16)
                    .background(Color(uiColor: .secondaryBack!))
                }
                .padding()
            }
            
                
        }
    }
}

struct ToDoItemView_Previews: PreviewProvider {
    static var previews: some View {
        ToDoItemView(item: TodoItem(text: "", importance: .important))
    }
}


struct TextView: UIViewRepresentable {
    
    typealias UIViewType = UITextView
    var configuration = { (view: UIViewType) in }
    
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIViewType {
        UIViewType()
    }
    
    func updateUIView(_ uiView: UIViewType, context: UIViewRepresentableContext<Self>) {
        configuration(uiView)
    }
    
}
