import SwiftUI

struct ChemicalProductListView: View {
    @StateObject private var store = ChemicalStore.shared
    @State private var searchText = ""
    @State private var selectedType: ChemicalType?
    @State private var showingAddSheet = false
    @State private var selectedChemical: ChemicalProduct?
    
    var filteredChemicals: [ChemicalProduct] {
        store.chemicals.filter { chemical in
            let matchesSearch = searchText.isEmpty || 
                chemical.name.localizedCaseInsensitiveContains(searchText) ||
                chemical.activeIngredient.localizedCaseInsensitiveContains(searchText) ||
                chemical.manufacturer.localizedCaseInsensitiveContains(searchText)
            
            let matchesType = selectedType == nil || chemical.productType == selectedType
            
            return matchesSearch && matchesType
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search chemicals...", text: $searchText)
                }
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Filter pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterPill(
                            title: "All",
                            isSelected: selectedType == nil,
                            action: { selectedType = nil }
                        )
                        
                        ForEach(ChemicalType.allCases, id: \.self) { type in
                            FilterPill(
                                title: type.rawValue,
                                isSelected: selectedType == type,
                                action: { selectedType = type }
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                
                // Chemical list
                if filteredChemicals.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "flask")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No chemicals found")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        if store.chemicals.isEmpty {
                            Button("Add Sample Data") {
                                TestDataProvider.createSampleChemicals()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGroupedBackground))
                } else {
                    List {
                        ForEach(filteredChemicals) { chemical in
                            NavigationLink(destination: ChemicalProductDetailView(chemical: chemical)) {
                                ChemicalProductRow(chemical: chemical) {
                                    // Action for row tap
                                }
                            }
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        }
                        .onDelete(perform: deleteChemicals)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Chemical Products")
            .navigationBarItems(
                trailing: Button(action: { showingAddSheet = true }) {
                    Image(systemName: "plus")
                }
            )
            .sheet(isPresented: $showingAddSheet) {
                AddChemicalProductView()
            }
        }
    }
    
    func deleteChemicals(at offsets: IndexSet) {
        for index in offsets {
            store.deleteChemical(filteredChemicals[index])
        }
    }
}

struct FilterPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(15)
        }
    }
}

// Version for selection in other views
struct ChemicalProductListView_Selection: View {
    let onSelect: (ChemicalProduct) -> Void
    @Environment(\.dismiss) var dismiss
    @StateObject private var store = ChemicalStore.shared
    @State private var searchText = ""
    @State private var selectedType: ChemicalType?
    
    var filteredChemicals: [ChemicalProduct] {
        store.chemicals.filter { chemical in
            let matchesSearch = searchText.isEmpty || 
                chemical.name.localizedCaseInsensitiveContains(searchText) ||
                chemical.activeIngredient.localizedCaseInsensitiveContains(searchText) ||
                chemical.manufacturer.localizedCaseInsensitiveContains(searchText)
            
            let matchesType = selectedType == nil || chemical.productType == selectedType
            
            return matchesSearch && matchesType
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search chemicals...", text: $searchText)
                }
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Filter pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterPill(
                            title: "All",
                            isSelected: selectedType == nil,
                            action: { selectedType = nil }
                        )
                        
                        ForEach(ChemicalType.allCases, id: \.self) { type in
                            FilterPill(
                                title: type.rawValue,
                                isSelected: selectedType == type,
                                action: { selectedType = type }
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                
                // Chemical list
                if filteredChemicals.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "flask")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No chemicals found")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        if store.chemicals.isEmpty {
                            Button("Add Sample Data") {
                                TestDataProvider.createSampleChemicals()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGroupedBackground))
                } else {
                    List {
                        ForEach(filteredChemicals) { chemical in
                            ChemicalProductRow(chemical: chemical) {
                                onSelect(chemical)
                                dismiss()
                            }
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Select Chemical")
            .navigationBarItems(trailing: Button("Cancel") { dismiss() })
        }
    }
}

struct ChemicalProductListView_Previews: PreviewProvider {
    static var previews: some View {
        ChemicalProductListView()
    }
}
