import SwiftUI

// A reusable timer component with start, pause, and reset functionality
struct SharedTimerView: View {
    // Timer state bindings and properties
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
            // Timer display section
            HStack {
                // Timer icon
                Image(systemName: "timer")
                    .foregroundColor(timerColor)
                    .font(.system(size: 18))
                
                // Timer label and time display
                Text(labelText)
                    .font(.subheadline)
                    .bold()
                
                // Time remaining with color change for urgency
                Text(timeRemainingFormatted)
                    .font(.title3)
                    .monospacedDigit()
                    .foregroundColor(timeRemaining > 60 ? .primary : timerColor)
                    .fontWeight(.bold)
                
                Spacer()
            }
            
            // Timer control buttons
            HStack(spacing: 12) {
                // Play/Pause button
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
                
                // Reset button
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