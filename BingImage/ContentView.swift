//
//  ContentView.swift
//  BingImage
//
//  Created by Harry Patsis on 13/10/19.
//  Copyright © 2019 Harry Patsis. All rights reserved.
//

import SwiftUI

class UrlImage: ObservableObject {
  @Published var isLoaded : Bool = false
  @Published var image : UIImage? = nil
  @Published var title : String? = nil
  
  init(_ index : Int) {
    loadJSON(index)
  }
  
  func loadImage(from: String, title: String?) {
    let url = URL(string: from)!
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
      
      guard error == nil else {
        self.image = nil
        self.title = nil
        self.isLoaded = false
        print("Error \(error!)")
        return
      }
      
      guard let content = data else {
        self.image = nil
        self.title = nil
        self.isLoaded = false
        print("No data")
        return
      }
      
      DispatchQueue.main.async {
        self.title = title
        self.image = UIImage(data: content)
        self.isLoaded = true
        print("Loaded")
      }
      
    }
    task.resume()
  }
  
  func loadJSON(_ index : Int) {
    let url = URL(string: "http://www.bing.com/HPImageArchive.aspx?format=js&idx=\(index)&n=1&mkt=en-US")!
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
      guard error == nil else {
        self.image = nil
        self.title = nil
        self.isLoaded = false
        print("Error \(error!)")
        return
      }
      
      guard let content = data else {
        self.image = nil
        self.title = nil
        self.isLoaded = false
        print("No data")
        return
      }
      let json = try! JSONSerialization.jsonObject(with: content, options: [])
      
      
      if let obj = json as? [String:Any] {
        if let images = obj["images"] as? [Any] {
          if let imginfo = images[0] as? [String:Any] {
            if let imgurl = imginfo["url"] as? String {
              let title = imginfo["title"] as? String ?? ""
              let url = "http://www.bing.com" + imgurl
              self.loadImage(from: url, title: title)
            }
          }
        }
      }
    }
    task.resume()
  }
}

struct CardView: View {
  @ObservedObject var image : UrlImage // = UrlImage(index: index)
  @State var isPresented = false
  
  var body: some View {
    ZStack {
      if image.isLoaded {
        ZStack {
          Button(action: {
            self.isPresented = true
          }) {
            Image(uiImage: image.image!)
              .renderingMode(.original)
              .resizable()
              .aspectRatio(contentMode: .fill)
          }.sheet(isPresented: self.$isPresented ) {
//            ModalView()
            Image(uiImage: self.image.image!)
            .renderingMode(.original)
            .resizable()
            .aspectRatio(contentMode: .fill)
//            .onTapGesture {
//              self.presentationMode.wrappedValue.dismiss()
//            }
          }
          
          VStack {
            Spacer()
            HStack {
              Text(image.title!)
                .frame(minWidth: 0, maxWidth: .infinity)
                .lineLimit(2)
                .foregroundColor(.white)
            }
            .padding(10)
            .background(Color.black.opacity(0.5))
          }
        }.cornerRadius(20)
      }
    }
  }
}

struct BingIndex: Identifiable {
  let id: Int
}
let bingModel: [BingIndex] = [
  BingIndex(id: 0),
  BingIndex(id: 1),
  BingIndex(id: 2),
  BingIndex(id: 3),
  BingIndex(id: 4),
  BingIndex(id: 5),
  BingIndex(id: 6),
  BingIndex(id: 7)
]

struct ContentView: View {
  var body: some View {
    //    CardView(image: UrlImage(0))
    List(bingModel) { index in
      CardView(image: UrlImage(index.id))
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}


