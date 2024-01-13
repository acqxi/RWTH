//
//  ProjectsView.swift
//  Activity
//
//  Created by TimurSmoev on 1/10/24.
//

import SwiftUI

struct ProjectsView: View {
    var body: some View {
        NavigationView {
            List{
                NavigationLink(destination: ProjectContentView(title: "Leg")) {
                    BoxView(title: "Leg")
                }
                .padding()
                                
                NavigationLink(destination: ProjectContentView(title: "Back")) {
                   BoxView(title: "Back")
                }
                .padding()
            }
            .navigationTitle("Projects")
            .navigationBarItems(
                trailing:
                    NavigationLink(destination: NewProjectView()) {
                        Image(systemName: "plus")
                    }
            )
        }
    }
}

struct BoxView: View {
    var title: String
    
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.white)
            .overlay(
                Text(title)
                    .foregroundColor(.black)
            )
    }
}

struct NewProjectView: View {
    var body: some View {
        NavigationView {
            Text("Hi")
        }
        .navigationTitle("New Project")
    }

}

let checkListData = [
    CheckListItem(id:0,title: "Squats 30 times"),
CheckListItem(id:1,title: "Lunges"),
CheckListItem(id:2,title:"Deadlifts"),
CheckListItem(id:3,title:"Leg Press"),
CheckListItem(id:4,title:"Leg Extensions")
]

struct ProjectContentView: View {
    var title: String
    var body: some View {
        NavigationView {
            List(checkListData){ item in
                        CheckView(isChecked: item.isChecked, title: item.title)
                    }
                    .font(.title)
        }
        .navigationTitle(title)
    }
}



struct CheckListItem:Identifiable{
    var id:Int
    var isChecked: Bool = false
    var title: String
}

struct CheckView: View {
    @State var isChecked:Bool = false
    var title:String
    func toggle(){isChecked = !isChecked}
    var body: some View {
        HStack{
            Button(action: toggle) {
                Image(systemName: isChecked ? "checkmark.square" : "square")
            }
            Text(title)
        }
    }
}

#Preview {
    ProjectsView()
}
