//
//  ViewController.swift
//  bitcoinprice
//
//  Created by Guilherme Motti on 10/04/25.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, BitcoinManagerDelegate
{
    @IBOutlet weak var labelMoedaSelecionada: UILabel!
    @IBOutlet weak var pickerViewMoeda: UIPickerView!
    @IBOutlet weak var iconeBitcoin: UIImageView!
    @IBOutlet weak var viewDadosBitcoin: UIView!
    @IBOutlet weak var labelValorBitCoin: UILabel!
    
    var bitcoinManager = BitcoinManager()
    var primeiraBuscaRealizada = false
    var confettiView: ConfetteView!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.bitcoinManager.delegate = self
        self.pickerViewMoeda.dataSource = self
        self.pickerViewMoeda.delegate = self
    }
    
    private func setupConfetti() {
        confettiView = ConfetteView(frame: view.bounds)
        confettiView.isUserInteractionEnabled = false
        view.addSubview(confettiView)
    }
    
    func didUpdatePrice(price: String, currency: String)
    {
        DispatchQueue.main.async
        {
            self.labelValorBitCoin.text = self.formatPriceAuto(price)
            self.labelMoedaSelecionada.text = currency
            if(self.confettiView != nil)
            {
                self.confettiView.stopConfetti()
            }
        }
    }
    
    func didFailWithError(error: any Error)
    {
        print(error)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.bitcoinManager.listaDeMoedas.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // Verifica se é a primeira linha sendo carregada e se ainda não foi feita a busca
        if row == 0 && !primeiraBuscaRealizada {
            let primeiraMoeda = self.bitcoinManager.listaDeMoedas[0]
            self.bitcoinManager.obterPrecoPelaMoeda(for: primeiraMoeda)
            primeiraBuscaRealizada = true
        }
        return self.bitcoinManager.listaDeMoedas[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedCurrency = self.bitcoinManager.listaDeMoedas[row]
        self.bitcoinManager.obterPrecoPelaMoeda(for: selectedCurrency)
        
        bitcoinManager.obterPrecoPelaMoeda(for: selectedCurrency)
            DispatchQueue.main.async {
                self.setupConfetti()
                self.confettiView.startConfetti()  // 🎉 EXPLOSÃO DE CORES!
                
                // Adiciona um shake na label (opcional)
                // Animação adicional (opcional)
                  UIView.animate(withDuration: 0.3, animations: {
                      self.labelValorBitCoin.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                  }) { _ in
                      UIView.animate(withDuration: 0.3) {
                          self.labelValorBitCoin.transform = .identity
                      }
                  }
            }
        
        
        // Adiciona animação quando a seleção muda
        self.animatePriceChange()
    }
    
    
    func animatePriceChange() {
        // Supondo que você tenha uma UILabel chamada priceLabel
        self.labelValorBitCoin.shake()
        self.labelMoedaSelecionada.shake()
        self.iconeBitcoin.shake()
        self.viewDadosBitcoin.shake()

        // Opcional: mudar temporariamente a cor para feedback visual
        UIView.animate(withDuration: 0.3, animations: {
            self.labelValorBitCoin.textColor = .systemGreen
        }) { _ in
            UIView.animate(withDuration: 0.3) {
                self.labelValorBitCoin.textColor = .label // Volta para a cor original
            }
        }
    }
    
    func formatPriceAuto(_ priceString: String) -> String {
        let cleanedString = priceString.replacingOccurrences(of: "[^0-9.,]", with: "", options: .regularExpression)
        
        guard let price = Double(cleanedString.replacingOccurrences(of: ",", with: ".")) else {
            return priceString
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        
        return formatter.string(from: NSNumber(value: price)) ?? priceString
    }
}

extension UIView {
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.6
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        layer.add(animation, forKey: "shake")
    }
}

extension Double {
    func formatAsCurrency(currencyCode: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode  // "MXN", "BRL", "USD", etc.
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale.current  // Usa o formato do dispositivo do usuário
        
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
