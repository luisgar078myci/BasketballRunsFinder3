//
//  ViewC.swift
//  Basketball Runs Finder2
//
//  Created by Luis Garibay on 12/14/24.
//

import SwiftUI

// MARK: - Model to Store Title + URL
struct LeagueLink: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let url: URL
}

struct ViewC: View {
    @State private var showingSearch = false
    @State private var searchText = ""
    @State private var savedLinks: [LeagueLink] = []

    var body: some View {
        ZStack {
            Color.orange
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 20) {
                Text("Adult Leagues")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.leading)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(savedLinks) { link in
                            GroupBox(label:
                                HStack {
                                    Image(systemName: "link")
                                        .foregroundColor(.blue) // 🔵 Icon
                                    Text("League")
                                        .foregroundColor(.blue) // 🔵 Text
                                }
                            ) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Link(destination: link.url) {
                                        Text(link.title)
                                            .foregroundColor(.white)
                                            .underline()
                                            .lineLimit(2)
                                            .multilineTextAlignment(.leading)
                                    }
                                }
                                .padding(10)
                                .background(Color.orange.opacity(0.8))
                                .cornerRadius(8)
                            }
                            .frame(width: 200)
                        }
                    }
                    .padding(.horizontal)
                }

                Button(action: {
                    showingSearch = true
                }) {
                    Label("Add Link or Search", systemImage: "plus")
                        .padding(8)
                        .background(Color.white.opacity(0.2))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.leading)
            }
        }
        .sheet(isPresented: $showingSearch) {
            SearchSheet(searchText: $searchText, onSave: { input in
                guard !input.trimmingCharacters(in: .whitespaces).isEmpty else {
                    showingSearch = false
                    return
                }

                var finalURL: URL?

                if let url = URL(string: input), url.scheme == "https" || url.scheme == "http" {
                    finalURL = url
                } else {
                    let query = input.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                    finalURL = URL(string: "https://www.google.com/search?q=\(query)")
                }

                if let urlToAdd = finalURL {
                    let newLink = LeagueLink(title: input, url: urlToAdd)
                    savedLinks.append(newLink)
                }

                searchText = ""
                showingSearch = false
            })
        }
    }
}

struct SearchSheet: View {
    @Binding var searchText: String
    var onSave: (String) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Enter a Website or Search Term")) {
                    TextField("", text: $searchText)
                        .keyboardType(.default)
                        .autocapitalization(.none)
                        .placeholder(when: searchText.isEmpty) {
                            Text("https://example.com or 'adult leagues'")
                                .foregroundColor(.gray)
                        }
                }
            }
            .navigationBarTitle("Add League Link", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    onSave("") // Close without saving
                },
                trailing: Button("Save") {
                    guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                    onSave(searchText)
                }
            )
        }
    }
}

// MARK: - Placeholder Extension
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            if shouldShow {
                placeholder()
            }
            self
        }
    }
}

#Preview {
    ViewC()
}
