//
//  LoginViewController.swift
//  MahotoSasaki-Lab4
//
//  Created by Mahoto Sasaki on 11/1/20.
//  Copyright © 2020 mo3aru. All rights reserved.
//

import UIKit
import WebKit

var sessionID:String = ""

class LoginViewController: UIViewController, WKUIDelegate {
    var webView: WKWebView!
    var token:String = ""
        
    override func loadView() {
        createWebView()
    }
    
    func createWebView(){
           let webConfiguration = WKWebViewConfiguration()

           webView = WKWebView(frame: .zero, configuration: webConfiguration)
           webView.uiDelegate = self
           view = webView

           webView.addObserver(self, forKeyPath: "URL", options: .new, context: nil)
       }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        fetchData()
    }
    
    struct authentication:Decodable {
        let success: Bool
        let expires_at: String
        let request_token: String
    }
    
    func fetchData(){
        let urlstring:String = "https://api.themoviedb.org/3/authentication/token/new?api_key=6674a05c20e4cc8c1e9c584ac5b7b041"
        guard let url = URL(string: urlstring) else {
            return
        }
        
        DispatchQueue.global().async {
            do {
                let data = try Data(contentsOf: url)
                let json = try JSONDecoder().decode(authentication.self, from: data)
                self.token = json.request_token
                let tokenStringURL = "https://www.themoviedb.org/authenticate/\(self.token)"
                guard let tokenURL = URL(string: tokenStringURL) else {
                    return
                }
                let myRequest = URLRequest(url: tokenURL)
                DispatchQueue.main.async {
                    self.webView.load(myRequest)
                }
                print("SUCESSFULY FETCHED")
            } catch {
                print("FAILED TO FETCH")
            }
        }
    }
    

    //https://stackoverflow.com/questions/41213185/wkwebview-function-for-detecting-if-the-url-has-changed
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let key = change?[NSKeyValueChangeKey.newKey] {
            print("observeValue \(key)") // url value
            if "\(key)" == "https://www.themoviedb.org/authenticate/\(token)/allow" {
                view = UIView()
                view.backgroundColor = UIColor.white

                let label = UILabel(frame: CGRect(x: 0, y:view.frame.height / 2 - 50, width: view.frame.width, height: 50))
                label.textAlignment = .center
                label.text = "AUTHENTICATED"
                view.addSubview(label)
                
                let button = UIButton(frame: CGRect(x: 0, y:view.frame.height / 2, width: view.frame.width, height: 50))
                button.setTitle("Logout", for: .normal)
                button.backgroundColor = UIColor.green
                button.addTarget(self, action: #selector(self.buttonPressed), for: .touchUpInside)
                view.addSubview(button)
                postSession()
            }
        }
    }
    
    //https://developer.apple.com/documentation/foundation/url_loading_system/uploading_data_to_a_website
    func postSession(){
//        struct Session: Encodable {
//            let request_token: String
//        }
//        struct SessionResponse:Decodable {
//            let success:Bool
//            let session_id:String
//        }
        let data = Session(request_token: "\(token)")
        print(data)
        guard let jsonData = try? JSONEncoder().encode(data) else {
            return
        }
        
        guard let url = URL(string: "https://api.themoviedb.org/3/authentication/session/new?api_key=6674a05c20e4cc8c1e9c584ac5b7b041") else {
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.uploadTask(with: request, from: jsonData) { data, response, error in
            if let error = error {
                print ("error: \(error)")
                return
            }
            guard let response = response as? HTTPURLResponse,
                (200...299).contains(response.statusCode) else {
                print ("server error")
                return
            }
            if let mimeType = response.mimeType, mimeType == "application/json", let data = data, let dataString = String(data: data, encoding: .utf8) {
                print ("got data: \(dataString)")
                do {
                    let json = try JSONDecoder().decode(SessionResponse.self, from: data)
                    sessionID = json.session_id
                } catch {
                    print("FAILED TO DECODE SESSIONID")
                }
            }
            
        }
        task.resume()
    }
    
    func deleteSession(){
//        struct Session: Encodable {
//            let session_id: String
//        }
        let data = deleteSessionStruct(session_id: "\(sessionID)")
        print(data)
        guard let jsonData = try? JSONEncoder().encode(data) else {
            return
        }
        
        guard let url = URL(string: "https://api.themoviedb.org/3/authentication/session?api_key=6674a05c20e4cc8c1e9c584ac5b7b041") else {
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.uploadTask(with: request, from: jsonData) { data, response, error in
            if let error = error {
                print ("error: \(error)")
                return
            }
            guard let response = response as? HTTPURLResponse,
                (200...299).contains(response.statusCode) else {
                print ("server error")
                return
            }
            if let mimeType = response.mimeType, mimeType == "application/json", let data = data, let dataString = String(data: data, encoding: .utf8) {
                print ("Sucessfully deleted session and got data: \(dataString)")
            }
            
        }
        task.resume()
    }
    
    @objc func buttonPressed(button: UIButton) {
        print("HI")
        if button.titleLabel?.text == "Logout" {
            deleteSession()
            createWebView()
            fetchData()
            sessionID = ""
        }
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
