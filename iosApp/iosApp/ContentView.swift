import SwiftUI
import shared
import KMPNativeCoroutinesCore
import KMPNativeCoroutinesAsync

struct ContentView: View {
    @ObservedObject private(set) var viewModel: ViewModel

	var body: some View {
        ListView(phrases: viewModel.greetings)
            .onAppear { self.viewModel.startObserving() }
	}
}

extension ContentView {
    @MainActor
    class ViewModel: ObservableObject {
        @Published var greetings: [String] = []

        func startObserving() {
            Task {
                do {
                    let sequence = asyncSequence(for: Greeting().greet())
                    for try await phrase in sequence {
                        self.greetings.append(phrase)
                    }
                } catch {
                    print("Failed with error: \(error)")
                }
            }
        }
    }
}

struct ListView: View {
    let phrases: Array<String>

    var body: some View {
        List(phrases, id: \.self) {
            Text($0)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView(viewModel: ContentView.ViewModel())
	}
}
