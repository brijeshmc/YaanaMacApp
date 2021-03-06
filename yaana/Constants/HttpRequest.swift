import UIKit

extension UIView {

    func makeHttpRequest(path : String, queries : Array<Any>?, method : String, body : Data?, accepts : String) -> (urlSession : URLSession, urlRequest : URLRequest){
        let configuration = URLSessionConfiguration .default
        let session = URLSession(configuration: configuration)
        
        var urlComponents = URLComponents()
        urlComponents.scheme = AppUrl.scheme
        urlComponents.host = AppUrl.host
        //urlComponents.port = AppUrl.port
        urlComponents.path = path
        
        if(queries != nil && queries!.count > 0){
            var queryItems : [URLQueryItem] = []

            var i = 0
            while i < queries!.count {
                queryItems.append(URLQueryItem(name: queries![i] as! String, value: queries![i+1] as? String))
                i += 2
            }
            urlComponents.queryItems = queryItems
        }
        let url = urlComponents.url
        
        var token = KeychainWrapper.standard.string(forKey: "yaana_token")


        var request = URLRequest(url: url!)
        request.httpMethod = method
        request.timeoutInterval = 30
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(accepts, forHTTPHeaderField: "Accept")
        if(token != nil && token != ""){
            token = "yaanaAuthToken \(token!)"
            request.addValue(token!, forHTTPHeaderField: "RequestAuthorization")
        }
        

        request.httpBody = body
        return (session, request)
    }
}

