import SwiftUI
import CoreLocation

struct PhotoDetailView: View {
    @Binding var photo: Photo // Change from @ObservedObject to @Binding
    @ObservedObject var viewModel: GalleryGuruViewModel
    @State private var isTagPickerPresented = false
    @State private var latitude: String = ""
    @State private var longitude: String = ""
    @State private var selectedDate: Date = Date()

    var body: some View {
        // Date Formatter with day/month/year format
        let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy" // Custom format for day/month/year
            return formatter
        }()
        
        ScrollView { // Wrap the content in a ScrollView
            VStack {
                // Display the photo
                Image(uiImage: photo.image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .navigationTitle(photo.imageName)
                
                // Editable title field
                TextField("Title", text: $photo.title)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                // Editable description field
                TextField("Description", text: $photo.description)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                // Tags display
                if !photo.tags.isEmpty {
                    Text("Tags:")
                        .font(.headline)
                        .padding(.top)
                    ForEach(photo.tags) { tag in
                        Text(tag.name)
                            .padding(5)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                            .padding(.bottom, 2)
                    }
                } else {
                    Text("No tags assigned")
                        .foregroundColor(Color.gray)
                }

                // Location editing
                if let location = photo.location {
                    Text("Location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                        .padding()
                    TextField("Latitude", text: $latitude)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                        .padding()

                    TextField("Longitude", text: $longitude)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                        .padding()

                    Button(action: {
                        // Update location based on input latitude and longitude
                        if let lat = Double(latitude), let long = Double(longitude) {
                            photo.location = CLLocation(latitude: lat, longitude: long)
                            viewModel.objectWillChange.send() // Notify change
                            print("Location updated to: \(lat), \(long)")
                        } else {
                            print("Invalid coordinates entered")
                        }
                    }) {
                        Text("Update Location")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(Color.white)
                            .cornerRadius(10)
                    }
                    .padding()
                } else {
                    Text("No Location Found")
                    TextField("Latitude", text: $latitude)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                        .padding()

                    TextField("Longitude", text: $longitude)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                        .padding()

                    Button(action: {
                        // Set location based on input latitude and longitude
                        if let lat = Double(latitude), let long = Double(longitude) {
                            photo.location = CLLocation(latitude: lat, longitude: long)
                            viewModel.objectWillChange.send() // Notify change
                            print("Location set to: \(lat), \(long)")
                        } else {
                            print("Invalid coordinates entered")
                        }
                    }) {
                        Text("Set Location")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(Color.white)
                            .cornerRadius(10)
                    }
                    .padding()
                }

                // Date editing
                if let date = photo.date {
                    Text("Date: \(dateFormatter.string(from: date))")
                        .padding()
                    
                    DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden() // To hide the default label
                        .padding()

                    Button(action: {
                        // Update the photo's date
                        photo.date = selectedDate
                        viewModel.objectWillChange.send() // Notify change
                        print("Date updated to: \(dateFormatter.string(from: selectedDate))")
                    }) {
                        Text("Update Date")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(Color.white)
                            .cornerRadius(10)
                    }
                    .padding()
                } else {
                    Text("No Date Found")
                    DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden() // To hide the default label
                        .padding()

                    Button(action: {
                        // Set the photo's date
                        photo.date = selectedDate
                        viewModel.objectWillChange.send() // Notify change
                        print("Date set to: \(dateFormatter.string(from: selectedDate))")
                    }) {
                        Text("Set Date")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(Color.white)
                            .cornerRadius(10)
                    }
                    .padding()
                }

                // Button to assign tags
                Button(action: {
                    isTagPickerPresented = true
                }) {
                    Text("Assign Tag")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(Color.white)
                        .cornerRadius(10)
                }
                .padding()
                .sheet(isPresented: $isTagPickerPresented) {
                    // Pass a binding for photo
                    TagPickerView(viewModel: viewModel, photo: $photo)
                }
            }
            .padding()
        }
        .onAppear {
            // Prepopulate the latitude and longitude if they exist
            if let location = photo.location {
                latitude = "\(location.coordinate.latitude)"
                longitude = "\(location.coordinate.longitude)"
            }

            // Prepopulate the date if it exists
            if let date = photo.date {
                selectedDate = date
            }
        }
    }
}
