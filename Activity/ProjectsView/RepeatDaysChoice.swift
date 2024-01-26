import SwiftUI

struct RepeatDaysChoice: View {
    @Binding var repeatDays: Set<DayOfWeek>
    
    var body: some View {
        VStack {
            List {
                ForEach(DayOfWeek.all) { dayOfWeek in
                    CheckView(
                        isChecked: Binding(
                            get: { repeatDays.contains(dayOfWeek) },
                            set: { newValue in
                                if newValue {
                                    repeatDays.insert(dayOfWeek)
                                } else {
                                    repeatDays.remove(dayOfWeek)
                                }
                            }
                        ),
                        title: "Every \(dayOfWeek.string)"
                    )
                }
            }
        }
    }
}

struct CheckView: View {
    @Binding var isChecked: Bool
    var title: String
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
