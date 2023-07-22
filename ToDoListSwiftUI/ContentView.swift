import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Color(uiColor: .primaryBack!)
                .ignoresSafeArea()
            
            ToDoListView()
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
