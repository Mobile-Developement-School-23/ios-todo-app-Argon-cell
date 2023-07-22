import SwiftUI

struct ToDoListView: View {
    @State var items: [TodoItem] = [
        TodoItem(text: "Первое дело", importance: .ordinary, isDone: true),
        TodoItem(text: "Второе дело", importance: .ordinary, isDone: false),
        TodoItem(text: "Третье дело", importance: .important, isDone: false),
        TodoItem(text: "Четвертое большущеееееееееееееееееееееееееееееееееееееееееееееее дело", importance: .important, isDone: false),
        TodoItem(text: "Новое", importance: .ordinary, dateСreation: .distantPast),
    ]
    
    @State var headerState: HeaderState = .hide
    @State var detailViewPresented: Bool = false
    @State var selectedItem: TodoItem?
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                VStack {
                    List {
                        Section {
                            ForEach(items.filter({ headerState == .hide || $0.dateСreation == .distantPast ? true : $0.isDone })) { item in
                                ZStack(alignment: .leading) {
                                    Button {
                                        detailViewPresented.toggle()
                                        selectedItem = item
                                    } label: {
                                        
                                    }

                                    ToDoListCellView(todoItem: item)
                                        .padding(.top, 8)
                                        .padding(.bottom, 8)
                                }
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                .listRowBackground(Color(uiColor: .secondaryBack!))
                                .swipeActions(edge: .leading) {
                                    Button {
                                        items[items.firstIndex { $0 == item }!].isDone.toggle()
                                    } label: {
                                        Image(uiImage: .whiteCheckMarkCircleIcon!)
                                    }
                                    .tint(Color(uiColor: .customGreen!))
                                }
                                .swipeActions(edge: .trailing) {
                                    Button {
                                        items.remove(at: items.firstIndex { $0 == item }!)
                                    } label: {
                                        Image(uiImage: .whiteTrashIcon!)
                                    }
                                    .tint(Color(uiColor: .customRed!))
                                }
                            }
                        } header: {
                            HeaderView(state: $headerState, items: $items)
                                .padding(.bottom, 6)
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                    
                }
                    
                Button {
                    detailViewPresented.toggle()
                } label: {
                    Image(uiImage: UIImage.plusIcon!)
                        .resizable()
                        .shadow(color: Color(uiColor: .customBlue!), radius: 8, y: 4)
                        .frame(width: 40, height: 40)
                }

            }
            .navigationTitle("Мои дела")
        }
        .sheet(isPresented: $detailViewPresented) {
// Доделать
//            ToDoItemView(item: selectedItem ?? TodoItem(text: "", importance: .ordinary))
            EmptyView()
                .onAppear(perform: {
                    if let window = UIApplication.shared.windows.first {
                        window.backgroundColor = .black
                    }
                })
        }
       
    }
}

struct ToDoListView_Previews: PreviewProvider {
    static var previews: some View {
        ToDoListView()
    }
}
