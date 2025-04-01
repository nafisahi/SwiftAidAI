import SwiftUI

struct TimerView: View {
    @Binding var timeRemaining: Int
    var timeRemainingFormatted: String
    @Binding var timerIsRunning: Bool
    var onStart: () -> Void
    var onStop: () -> Void
    var onReset: () -> Void
    var timerColor: Color = Color(red: 0.8, green: 0.2, blue: 0.2)
    var labelText: String = "Timer: "
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "timer")
                    .foregroundColor(timerColor)
                    .font(.system(size: 18))
                
                Text(labelText)
                    .font(.subheadline)
                    .bold()
                
                Text(timeRemainingFormatted)
                    .font(.title3)
                    .monospacedDigit()
                    .foregroundColor(timeRemaining > 60 ? .primary : timerColor)
                    .fontWeight(.bold)
                
                Spacer()
            }
            
            HStack(spacing: 12) {
                Button(action: {
                    if timerIsRunning {
                        onStop()
                    } else {
                        onStart()
                    }
                }) {
                    HStack {
                        Image(systemName: timerIsRunning ? "pause.fill" : "play.fill")
                        Text(timerIsRunning ? "Pause" : "Resume")
                    }
                    .font(.subheadline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(8)
                }
                
                Button(action: onReset) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Restart")
                    }
                    .font(.subheadline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .foregroundColor(.white)
                    .background(timerColor)
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
        .animation(.easeInOut, value: timerIsRunning)
    }
}

#Preview {
    TimerView(
        timeRemaining: .constant(300),
        timeRemainingFormatted: "05:00",
        timerIsRunning: .constant(true),
        onStart: {},
        onStop: {},
        onReset: {},
        timerColor: .orange,
        labelText: "Sample Timer: "
    )
    .previewLayout(.sizeThatFits)
    .padding()
} 