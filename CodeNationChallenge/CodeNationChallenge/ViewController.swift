//
//  ViewController.swift
//  CodeNationChallenge
//
//  Created by Bernardo Nunes on 04/05/20.
//  Copyright © 2020 Bernardo Nunes. All rights reserved.
//

import UIKit
import CommonCrypto
import Alamofire

class ViewController: UIViewController {
    
    let alphabet = "abcdefghijklmnopqrstuvwxyz"
    var alphabetCharacters: [Character] = []
    let submitURL = "https://api.codenation.dev/v1/challenge/dev-ps/submit-solution?token=ff6eb78a41e50610d6cf41b2c896163b71f334eb"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = URL(string: "https://api.codenation.dev/v1/challenge/dev-ps/generate-data?token=ff6eb78a41e50610d6cf41b2c896163b71f334eb") {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    
                    let jsonDecoder = JSONDecoder()
                    guard var message = try? jsonDecoder.decode(Message.self, from: data) else { return }
                    message.decifrado = self.decode(number: message.numero_casas, message: message.cifrado)
                    message.resumo_criptografico = message.decifrado.sha1()
                    
                    let fileName = "answer.json"
                    
                    if let directory = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first {
                        let fileURL = directory.appendingPathComponent(fileName)
                        
                        print(fileURL)
                        let jsonData = try! JSONEncoder().encode(message)
                        try! jsonData.write(to: fileURL)
                        
                        self.sendFile(data: jsonData)
                        try! print(String(contentsOf: fileURL))
                        
                    }
                
                }
            }.resume()
        }
    }
    private func sendFile(data: Data) {
        let headers: HTTPHeaders = [HTTPHeader(name: "Content-type", value: "multipart/formdata")]
        
        
//        let url = URL(string: submitURL)
        
        AF.upload(multipartFormData: { (formdata) in
            
            formdata.append(data, withName: "answer", fileName: "answer.json", mimeType: "application/json")
            
        }, to: submitURL, headers: headers).responseJSON {
            debugPrint($0)
        }
      
    }
    
    private func decode(number: Int, message: String) -> String{
        let lowerCaseMessage = message.lowercased()
        var decipheredMessage = ""
        
        for char in alphabet{
            alphabetCharacters.append(char)
        }
        print(alphabetCharacters)
        
        for char in lowerCaseMessage {
            if char.isLetter {
                let index = alphabetCharacters.firstIndex { (letter) -> Bool in
                    if letter == char{
                        return true
                    }
                    return false
                }
                
                var newIndex = index!-number
                
                if newIndex < 0 {
                    newIndex = alphabetCharacters.count + newIndex
                }
                
                decipheredMessage.append(alphabetCharacters[newIndex])
                
            } else {
                decipheredMessage.append(char)
            }
        }
        
        return decipheredMessage
    }
}

extension String {
    func sha1() -> String {
        let data = Data(self.utf8)
        var digest = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA1($0.baseAddress, CC_LONG(data.count), &digest)
        }
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        return hexBytes.joined()
    }
}

