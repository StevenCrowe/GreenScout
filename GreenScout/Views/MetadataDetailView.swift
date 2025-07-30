//
//  MetadataDetailView.swift
//  GreenScout
//
//  Display photo metadata
//

import SwiftUI
import MapKit

struct MetadataDetailView: View {
    let metadata: ImageMetadata?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                if let metadata = metadata {
                    Section(header: Text("Location")) {
                        if metadata.hasLocation {
                            Text("Coordinates: \(metadata.formattedLocation ?? "")")
                                .font(.system(.body, design: .monospaced))
                            if let altitude = metadata.altitude {
                                Text("Altitude: \(String(format: "%.1f", altitude))m")
                            }
                            
                            // Map view
                            if let coordinates = metadata.coordinates {
                                MapView(coordinate: coordinates)
                                    .frame(height: 200)
                                    .cornerRadius(8)
                                    .padding(.vertical, 4)
                            }
                        } else {
                            Text("No location data available")
                                .foregroundColor(.secondary)
                        }
                    }

                    Section(header: Text("Capture Info")) {
                        if let date = metadata.formattedCaptureDate {
                            Text("Captured: \(date)")
                        }
                        if let year = metadata.year {
                            Text("Year: \(String(year))")
                        }
                        Text("Month: \(metadata.monthName ?? "Unknown")")
                        Text("Season: \(metadata.seasonName ?? "Unknown")")
                    }

                    Section(header: Text("Device Info")) {
                        if let make = metadata.deviceMake, let model = metadata.deviceModel {
                            Text("Camera: \(make) \(model)")
                        } else if let make = metadata.deviceMake {
                            Text("Device: \(make)")
                        } else if let model = metadata.deviceModel {
                            Text("Device: \(model)")
                        } else {
                            Text("No device information")
                                .foregroundColor(.secondary)
                        }
                        
                        if let lens = metadata.lensModel {
                            Text("Lens: \(lens)")
                        }
                    }

                    Section(header: Text("Image Properties")) {
                        if let width = metadata.imageWidth, let height = metadata.imageHeight {
                            Text("Resolution: \(width) × \(height) pixels")
                            let megapixels = Double(width * height) / 1_000_000.0
                            Text("Size: \(String(format: "%.1f", megapixels)) megapixels")
                        }
                        if let orientation = metadata.orientation {
                            Text("Orientation: \(orientationString(for: orientation))")
                        }
                    }

                    Section(header: Text("Analysis")) {
                        Text("Green Coverage: \(String(format: "%.1f%%", metadata.greenCoveragePercentage ?? 0.0))")
                    }

                } else {
                    Section {
                        Text("No metadata available")
                    }
                }
            }
            .navigationTitle("Photo Metadata")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

// Helper struct for map annotations
struct LocationPin: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

// Helper function for orientation
private func orientationString(for orientation: Int) -> String {
    switch orientation {
    case 1: return "Normal"
    case 2: return "Flipped horizontally"
    case 3: return "Rotated 180°"
    case 4: return "Flipped vertically"
    case 5: return "Flipped horizontally, rotated 270°"
    case 6: return "Rotated 90°"
    case 7: return "Flipped horizontally, rotated 90°"
    case 8: return "Rotated 270°"
    default: return "Unknown"
    }
}

struct MetadataDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MetadataDetailView(metadata: nil)
    }
}
