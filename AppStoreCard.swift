import SwiftUI

class ImageLoader: ObservableObject {
    
    private static let imageCache = NSCache<AnyObject, AnyObject>()
    
    @Published var image: UIImage? = UIImage(named: "no-img")
    
    public func downloadImage(url: URL) {
        let urlString = url.absoluteString

        if let imageFromCache = ImageLoader.imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = imageFromCache
            return
        }

        URLSession.shared.dataTask(with: url) { (data, res, error) in
            guard let data = data, let image = UIImage(data: data) else {
                return
            }
            DispatchQueue.main.async { [weak self] in
                ImageLoader.imageCache.setObject(image, forKey: urlString  as AnyObject)
                self?.image = image
            }
        }.resume()
    }
}


struct CardRow: View {
    
    var card: Card
    @ObservedObject var imageLoader: ImageLoader = ImageLoader()
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if (imageLoader.image != nil) {
                GeometryReader { geometry in
                    Image(uiImage: self.imageLoader.image!)
                        .resizable(resizingMode: Image.ResizingMode.stretch)
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: geometry.size.width)
                        .clipped()
                }
            }
            VStack(alignment: .leading) {
                Text(card.name)
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.white)
                    .lineLimit(2)
                Text(card.description)
                    .font(.subheadline)
                    .foregroundColor(Color.white)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .bottomLeading)
            .padding(EdgeInsets.init(top: 50, leading: 16, bottom: 16, trailing: 16))
            .background(LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0), Color.black.opacity(0.5)]), startPoint: .top, endPoint: .bottom))
        }
        .background(Color.secondary)
        .cornerRadius(10)
        .shadow(radius: 20)
        .padding(EdgeInsets.init(top: 8, leading: 0, bottom: 8, trailing: 0))
        .frame(height: UIScreen.main.bounds.width * 1.25)
        .onAppear {
            if let url = self.card.thumbnail {
                self.imageLoader.downloadImage(url: URL(string: url)!)
            }
        }
    }
}

struct CardRow_Previews: PreviewProvider {
    static var previews: some View {
        CardRow(card: Card(id: 1, name: "Test", description: "Test Description", thumbnail: "https://tagmetag.com/media/life/1572406737_68159940.jpg"))
    }
}
