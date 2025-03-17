import SwiftUI
import WebKit

struct ContentView: View {
    @State private var showingBottomSheet = false
    @State private var jitText = "Connecting to JitStreamer"
    @State private var jitstreamerConnected = false
    @State private var showError = false
    @State private var errorString = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()
                Image("phot")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(radius: 5)
                Spacer()
                Button(action: { showingBottomSheet.toggle() }) {
                    Label("Enable JIT", systemImage: "bolt.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .sheet(isPresented: $showingBottomSheet) {
                    JITConnectionView(jitText: $jitText, jitstreamerConnected: $jitstreamerConnected, showError: $showError, errorString: $errorString)
                }

                NavigationLink(destination: WebsiteView()) {
                    Label("Set Up", systemImage: "gearshape.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)

                Button(action: {
                }) {
                    Label("Attach SideStore/AltStore Extension", systemImage: "link.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)

                Button(action: {
                }) {
                    Label("Export", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
            .padding()
        }
    }
}

struct JITConnectionView: View {
    @Binding var jitText: String
    @Binding var jitstreamerConnected: Bool
    @Binding var showError: Bool
    @Binding var errorString: String

    var body: some View {
        VStack(spacing: 20) {
            Image("phot")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(radius: 5)

            if showError {
                ErrorView(errorString: errorString)
            } else if jitstreamerConnected {
                SuccessView()
            } else {
                ConnectionProgressView(jitText: $jitText, jitstreamerConnected: $jitstreamerConnected, showError: $showError, errorString: $errorString)
            }
        }
        .padding()
    }
}

struct ConnectionProgressView: View {
    @Binding var jitText: String
    @Binding var jitstreamerConnected: Bool
    @Binding var showError: Bool
    @Binding var errorString: String

    var body: some View {
        VStack(spacing: 10) {
            Text(jitText)
                .font(.title2)
                .bold()

            ProgressView()
                .onAppear {
                    self.jitText = "Connecting to JitStreamer..."
                    JitStreamerHandler.shared.detectIfCurrentVersion() { result, error in
                        DispatchQueue.main.async {
                            jitstreamerConnected = result
                            if !result {
                                showError = true
                                errorString = error ?? "Unknown Error"
                            }
                        }
                    }
                }
        }
    }
}

struct SuccessView: View {
    var body: some View {
        VStack {
            Text("JitStreamer connected successfully!")
                .font(.title2)
                .bold()
                .foregroundColor(.green)

            AppsListView()
                .padding(.top)
        }
    }
}

struct ErrorView: View {
    var errorString: String

    var body: some View {
        VStack(spacing: 15) {
            Text("Error connecting to JitStreamer")
                .font(.title2)
                .foregroundColor(.red)
                .bold()

            Text(errorString)
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding()
        }
    }
}
