//
//  ViewController.swift
//  WiKiSearch
//
//  Created by Diego Zamora on 12/05/21.
//

import UIKit
import WebKit

class ViewController: UIViewController {
    
    // MARK: - Outlets, Variables
    @IBOutlet weak var boxSearch: UISearchBar!
    @IBOutlet weak var webView: WKWebView!
    
    
    // MARK: - DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Search Bar Delegate
        boxSearch.delegate = self
        
        
        /// Load LOGO WIKIPEDIA
        let urlLogo = URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/1/1e/Wikipedia-logo-v2-es.svg/1200px-Wikipedia-logo-v2-es.svg.png")
        webView.load(URLRequest(url: urlLogo!))
    }
    
    // MARK: - Search Wiki
    func searchWiki(query: String?) -> Void {
        
        if query != nil {
            if query!.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                
                /// Preparamos mi URL
                if let urlAPI = URL(string: "https://es.wikipedia.org/w/api.php?action=query&prop=extracts&format=json&titles=\(query!.replacingOccurrences(of: " ", with: "%20"))")
                {
                    /// Creamos la Peticion
                    let request = URLRequest(url: urlAPI)
                    
                    /// Creamos la Tarea
                    let task = URLSession.shared.dataTask(with: request) {
                        
                        (data, response, error) in
                            if error != nil
                            {
                                print(error?.localizedDescription ?? "A ocurrido un Error")
                            }
                            else
                            {
                                do {
                                    /// Obtenemos mi JSON
                                    let objJson = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                                
                                    let subQuery = objJson["query"] as! [String: Any]
                                    
                                    let pageQuery = subQuery["pages"] as! [String: Any]
                                    
                                    let pageID = pageQuery.keys
                                    
                                    
                                    DispatchQueue.main.async {
                                    
                                        if pageID.first! != "-1" {
                                            let subJsonID = pageQuery[pageID.first!] as! [String: Any]
                                            
                                            let extracto = subJsonID["extract"] as! String?
                                            
                                            /// Imprimir en WebView
                                                self.webView.loadHTMLString(extracto ?? "<h1> NO SE OBTUBIERON RESULTADOS  :( </h1>", baseURL: nil)
                                            
                                        }
                                        else
                                        {
                                            let alert = UIAlertController(title: "'\(String(describing: self.boxSearch.text!))'", message: "No se encontraron resultados a tu busqueda.", preferredStyle: .alert)
                                            
                                            let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                                            
                                            alert.addAction(action)
                                            
                                            self.present(alert, animated: true, completion: {
                                                self.boxSearch.text = ""
                                                
                                                /// Load LOGO WIKIPEDIA
                                                let urlLogo = URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/1/1e/Wikipedia-logo-v2-es.svg/1200px-Wikipedia-logo-v2-es.svg.png")
                                                self.webView.load(URLRequest(url: urlLogo!))
                                            })
                                            
                                        }
                                        
                                    }
                                    
                                    
                                    
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                    }
                    
                    
                    /// Iniciamos mi Tarea
                    task.resume()
                    
                    
                }
                
                
                
                
            }
        }
        
    }
}

//MARK: - Extension para UISearchBar
extension ViewController: UISearchBarDelegate
{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        boxSearch.resignFirstResponder()
        
        if let query = boxSearch.text {
            self.webView.loadHTMLString( "<h1> BUSCANDO... </h1>", baseURL: nil)
            searchWiki(query: query)
        }
    }
}
