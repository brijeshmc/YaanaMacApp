import UIKit

extension UIView {

    func makeHttpRequest(path : String, queries : Array<Any>?, method : String, body : Data?) -> (urlSession : URLSession, urlRequest : URLRequest){
        let configuration = URLSessionConfiguration .default
        let session = URLSession(configuration: configuration)
        
        var urlComponents = URLComponents()
        urlComponents.scheme = AppUrl.scheme
        urlComponents.host = AppUrl.host
        urlComponents.port = AppUrl.port
        urlComponents.path = path
        
        if(queries != nil && queries!.count > 0){
            var queryItems : [URLQueryItem] = []

            for var i in 0...queries!.count{
                queryItems.append(URLQueryItem(name: queries![i] as! String, value: queries![i+1] as? String))
                i += 2;
            }
            urlComponents.queryItems = queryItems
        }
        let url = urlComponents.url
        

        var request = URLRequest(url: url!)
        request.httpMethod = method
        request.timeoutInterval = 30
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = body
        return (session, request)
    }
}
