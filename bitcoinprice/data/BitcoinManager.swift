//
//  BitcoinManager.swift
//  bitcoinprice
//
//  Created by Guilherme Motti on 10/04/25.
//

import Foundation

//By convention, Swift protocols are usually written in the file that has the class/struct which will call the
//delegate methods, i.e. the CoinManager.
protocol BitcoinManagerDelegate {
    
    //Create the method stubs wihtout implementation in the protocol.
    //It's usually a good idea to also pass along a reference to the current class.
    //e.g. func didUpdatePrice(_ coinManager: CoinManager, price: String, currency: String)
    //Check the Clima module for more info on this.
    func didUpdatePrice(price: String, currency: String)
    func didFailWithError(error: Error)
}

struct BitcoinManager
{
    var delegate: BitcoinManagerDelegate?

    let baseUrl = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = ""
    
    let listaDeMoedas = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
        
    
    func obterPrecoPelaMoeda(for moeda: String) {
         
         let urlString = "\(baseUrl)/\(moeda)?apikey=\(apiKey)"

         if let url = URL(string: urlString) {
             
             let session = URLSession(configuration: .default)
             let task = session.dataTask(with: url) { (data, response, error) in
                 if error != nil {
                     self.delegate?.didFailWithError(error: error!)
                     return
                 }
                 
                 if let safeData = data {
                     
                     if let bitcoinPrice = self.parseJSON(safeData) {
                         
                         let priceString = String(format: "%.2f", bitcoinPrice)
                         
                         self.delegate?.didUpdatePrice(price: priceString, currency: moeda)
                     }
                 }
             }
             task.resume()
         }
     }
     
     func parseJSON(_ data: Data) -> Double? {
         
         let decoder = JSONDecoder()
         do {
             let decodedData = try decoder.decode(BitcoinData.self, from: data)
             let lastPrice = decodedData.rate
             print(lastPrice)
             return lastPrice
             
         } catch {
             delegate?.didFailWithError(error: error)
             return nil
         }
     }
    
}
