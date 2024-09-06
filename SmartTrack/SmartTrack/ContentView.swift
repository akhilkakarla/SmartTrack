//
//  ContentView.swift
//  SmartTrack
//
//  Created by akhil kakarla on 9/3/24.
//

import Foundation
import SwiftUI
import MapKit

struct ContentView: View {
    
        @State var austin = CLLocationCoordinate2D(latitude: 30.266666, longitude: -97.733330)
        
        @State private var camera: String = ""
        @State private var camObjs: [CameraObjects] = []
        
        static let austin = CLLocationCoordinate2D(latitude: 30.266666, longitude: -97.733330)
        var body: some View {
            TabView{
                HomeView()
                    .tabItem{
                        Label("Home", systemImage: "house")
                        Image(systemName: "photo")
                }
                .foregroundColor(Color.blue)

                TrafficIncidents()
                    .tabItem{
                        Label("Traffic Incidents", systemImage: "car.side.rear.and.collision.and.car.side.front.slash")
                }
                
                RoadClosures()
                    .tabItem{
                        Label("Road Closures", systemImage: "road.lanes")
                }
                
                Cameras()
                    .tabItem{
                        Label("Cameras", systemImage: "camera")
                }
                
            }
        }
}


struct HomeView: View {
    var body: some View {
        VStack {
            Spacer()

            Text("Welcome to SmartTrack")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 60)
                        
            VStack(spacing: 24) {
                FeatureCell(image: "car.side.rear.and.collision.and.car.side.front.slash", title: "Traffic Incidents", subtitle: "Real-time traffic incidents", color: .red)
                FeatureCell(image: "road.lanes", title: "Road Closures", subtitle: "Real-time road closure information", color: .blue)
                FeatureCell(image: "camera", title: "Cameras", subtitle: "Real-time cameras information", color: .green)

            }
            .padding(.leading)
            
            Spacer()
        }
    }
}


struct FeatureCell: View {
    var image: String
    var title: String
    var subtitle: String
    var color: Color
    
    var body: some View {
        HStack(spacing: 24) {
            Image(systemName: image)
//                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32)
                .foregroundColor(color)
                    
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(subtitle)
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            }
            
            Spacer()
        }
    }
}

struct FeatureCell_Previews: PreviewProvider {
    static var previews: some View {
        FeatureCell(image: "text.badge.checkmark", title: "Title", subtitle: "Subtitle", color: .blue)
    }
}


struct TrafficIncidents: View{
    
    @State private var trafficincident: String = ""
    @State private var trafficIncidentObjs: [TrafficIncidentsObjects] = []
    @State private var mapSelection: MKMapItem?

    var body: some View{
        NavigationView{
            ZStack{
                Map(selection:$mapSelection)
                {
                    ForEach(trafficIncidentObjs) { obj in
                        Marker("", systemImage: "car.side.rear.and.collision.and.car.side.front.slash", coordinate: CLLocationCoordinate2D(latitude : obj.latitude, longitude: obj.longitude))
                        
                        Annotation("", coordinate: CLLocationCoordinate2D(latitude : obj.latitude, longitude: obj.longitude)) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 5)
                                  .fill(Color.white)
                                Text(obj.issue_reported.lowercased())
                                    .padding(3)
                                    
                            }
                        }
                    }
                }
                .task {
                    await trafficIncidentObjs = getTrafficIncidents()
                }
            }
        }
    }
    
    func getTrafficIncidents() async -> [TrafficIncidentsObjects] {
        do {
            let (data, _) = try await URLSession.shared.data(from: URL(string:"http://127.0.0.1:8080/trafficincidents")!)
            let decodedResponse : [TrafficIncidentsObjects] = try JSONDecoder().decode([TrafficIncidentsObjects].self, from: data)
            return decodedResponse

        } catch {
            print("Error info: \(error)")
            return []
        }
    }
}



struct RoadClosures: View{
    
    @State private var roadClosureObjs: [RoadClosuresObjects] = []
    @State private var mapSelection: MKMapItem?

    var body: some View{
        NavigationView{
            ZStack{
                Map(selection:$mapSelection)
                {
                    ForEach(roadClosureObjs) { obj in
                        Marker("", systemImage: "car.side.rear.and.collision.and.car.side.front.slash", coordinate: CLLocationCoordinate2D(latitude : obj.latitude_coordinate, longitude: obj.longitude_coordinate))

                        Annotation("", coordinate: CLLocationCoordinate2D(latitude : obj.latitude_coordinate, longitude: obj.longitude_coordinate)) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 5)
                                  .fill(Color.white)
                                
                                if obj.cross_streets != nil {
                                    Text(obj.cross_streets.lowercased())
                                            .padding(3)
                                }
                           }
                        }
                    }
                }
                .task {
                    await roadClosureObjs = getRoadClosures()
                }
            }
        }
    }
    
    func getRoadClosures() async -> [RoadClosuresObjects] {
        do {
            let (data, _) = try await URLSession.shared.data(from: URL(string:"http://127.0.0.1:8080/roadclosures")!)
            let decodedResponse : [RoadClosuresObjects] = try JSONDecoder().decode([RoadClosuresObjects].self, from: data)
            return decodedResponse

        } catch {
            print("Error info: \(error)")
            return []
        }
    }
}

/*
struct RoadConditions: View{
    
    @State private var roadConditionObjs: [RoadConditionsObjects] = []
    @State private var mapSelection: MKMapItem?

    var body: some View{
        NavigationView{
            ZStack{
                Map(selection:$mapSelection)
                {
                    ForEach(roadConditionObjs) { obj in
                        var locationInfo = obj.location
                        var locationArray = locationInfo.split(separator: " ")

                        let latitudeValue = locationArray[2].removeLast()
                        let longitudeValue = locationArray[1].removeFirst()
                        
                        Marker("", systemImage: "car.side.rear.and.collision.and.car.side.front.slash", coordinate: CLLocationCoordinate2D(latitude : latitudeValue, longitude: longitudeValue))

                        Annotation("", coordinate: CLLocationCoordinate2D(latitude : latitudeValue, longitude: longitudeValue)) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 5)
                                  .fill(Color.white)
                                
                                if obj.grip_text != nil {
                                    Text(obj.grip_text.lowercased())
                                        .padding(3)
                                }
                           }
                        }
                    }
                }
                .task {
                    await roadConditionObjs = getRoadConditions()
                }
            }
        }
    }
    
    func getRoadConditions() async -> [RoadConditionsObjects] {
        do {
            let (data, _) = try await URLSession.shared.data(from: URL(string:"http://127.0.0.1:8080/roadconditions")!)
            let decodedResponse : [RoadConditionsObjects] = try JSONDecoder().decode([RoadConditionsObjects].self, from: data)
            return decodedResponse

        } catch {
            print("Error info: \(error)")
            return []
        }
    }
}
*/


struct Cameras: View{
    
    @State private var cameraObjs: [CameraObjects] = []
    @State private var locInfo: [Double] = []

    var body: some View{
        NavigationView{
            ZStack{
                Map()
                {
                    ForEach(cameraObjs) { obj in
                        Marker("", systemImage: "camera", coordinate: CLLocationCoordinate2D(latitude : obj.latitude, longitude: obj.longitude))

                        Annotation("", coordinate: CLLocationCoordinate2D(latitude : obj.latitude, longitude: obj.longitude)) {
                            ZStack {
                                Image(obj.screenshotaddress)
                                    .resizable()
                           }
                        }
                    }
                }
                .task {
                    await cameraObjs = getCameras()
                }
            }
        }
    }
    
    func getCameras() async -> [CameraObjects] {
        do {
            let (data, _) = try await URLSession.shared.data(from: URL(string:"http://127.0.0.1:8080/cameras")!)
            var decodedResponse : [CameraObjects] = try JSONDecoder().decode([CameraObjects].self, from: data)
            var mylocInfo: [Double] = []
            
            for index in 0...decodedResponse.count-1 {
                mylocInfo = await getCoordinates(locationInfo: decodedResponse[index].coordinates)
                decodedResponse[index].latitude = mylocInfo[0]
                decodedResponse[index].longitude = mylocInfo[1]
            }
            return decodedResponse

        } catch {
            print("Error info: \(error)")
            return []
        }
    }
    
    func getCoordinates(locationInfo: String) async -> [Double] {
        let locationArray: [Substring] = locationInfo.split(separator: " ")

        var retLocationInfo: [Double] = []
        
        let latitudeValue = locationArray[2].dropLast()
        let longitudeValue = locationArray[1].dropFirst()
        
        let val1 = Double(String(latitudeValue))
        let val2 = Double(String(longitudeValue))
        
        retLocationInfo.append(val1!)
        retLocationInfo.append(val2!)
        return retLocationInfo

    }
}

#Preview {
    ContentView()
}


struct CameraObjects: Identifiable, Codable {
    var id = UUID()
    let cameraid: String!
    let locationname: String!
    let camerastatus: String!
    let turnondate: String!
    let cameramanufacturer: String!
    let atdlocationid: String!
    let landmark: String!
    let signalengineerarea: String!
    let councildistrict: String!
    let jurisdiction: String!
    let locationtype: String!
    let primarystsegmentid: String!
    let crossstsegmentid: String!
    let primarystreetblock: String!
    let primarystreet: String!
    let primary_st_aka: String!
    let crossstreetblock: String!
    let crossstreet: String!
    let cross_st_aka: String!
    let coaintersectionid: String!
    let modifieddate: String!
    let publishedscreenshots: String!
    let screenshotaddress: String!
    let funding: String!
    let camid: String!
    let coordinates: String!
    var latitude: Double!
    var longitude: Double!

}

struct TrafficIncidentsObjects: Identifiable, Codable {
    var id = UUID()
    let traffic_report_id: String!
    let published_date: String!
    let issue_reported: String!
    let location: String!
    let latitude: Double!
    let longitude: Double!
    let address: String!
    let status: String!
    let status_date: String!
    let agency: String!
}

struct RoadConditionsObjects: Identifiable, Codable {
    var id = UUID()
    let road_id: String!
    let sensor_id: String!
    let location_name: String!
    let location: String!
    let timestamp: String!
    let voltage_y: String!
    let voltage_x: String!
    let voltage_ratio: String!
    let air_temp_secondary: String!
    let temp_surface: String!
    let condition_code_displayed: String!
    let condition_code_measured: String!
    let condition_text_displayed: String!
    let condition_text_measured: String!
    let friction_code_displayed: String!
    let friction_code_measured: String!
    let friction_value_displayed: String!
    let friction_value_measured: String!
    let dirty_lens_score: String!
    let grip_text: String!
    let relative_humidity: String!
    let air_temp_primary: String!
    let air_temp_tertiary: String!
    let status_code: String!
}

struct RoadClosuresObjects: Identifiable, Codable {
    var id = UUID()
    let sr_number: String!
    let sr_type_code: String!
    let sr_description: String!
    let owning_department: String!
    let method_received: String!
    let sr_status: String!
    let status_change_date: String!
    let created_date: String!
    let last_update_date: String!
    let close_date: String!
    let sr_location: String!
    let street_number: String!
    let zip_code: String!
    let county: String!
    let state_plane_x_coordinate: String!
    let state_plane_y_coordinate: String!
    let latitude_coordinate: Double!
    let longitude_coordinate: Double!
    let latitude_longitude: String!
    let council_district: String!
    let map_page: String!
    let map_tile: String!
    let date_and_time_of_closure: String!
    let date_and_time_of_reopening: String!
    let lanes_closed: String!
    let routine_or_emergency: String!
    let permit_number: String!
    let cross_streets: String!
    let detour_information: String!
    let business_or_dept_closing_road: String!
    let name_of_business: String!
}



