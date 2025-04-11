//
//  ConfetteView.swift
//  bitcoinprice
//
//  Created by Guilherme Motti on 10/04/25.
//

import UIKit

class ConfetteView: UIView
{
    private var emitter: CAEmitterLayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConfetti()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupConfetti()
    }
    
    private func setupConfetti() {
        emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: bounds.midX, y: -10)
        emitter.emitterShape = .line
        emitter.emitterSize = CGSize(width: bounds.width, height: 1)
        
        let colors: [UIColor] = [
            .systemRed, .systemGreen, .systemBlue,
            .systemYellow, .systemPink, .systemPurple,
            .systemOrange, .systemTeal
        ]
        
        var cells = [CAEmitterCell]()
        
        for color in colors {
            let cell = CAEmitterCell()
            cell.contents = createConfettiImage(size: CGSize(width: 8, height: 4), color: color).cgImage
            cell.birthRate = 5
            
            // 🔥 Ajuste principal: Aumente a velocidade!
            cell.velocity = 190  // Valor original: ~100 (quanto maior, mais rápido)
            cell.velocityRange = 80  // Variação de velocidade
            
            cell.lifetime = 5  // Tempo de vida menor = desaparece mais rápido
            cell.emissionLongitude = .pi  // Ângulo para baixo
            cell.spin = 1
            cell.scale = 0.6
            cells.append(cell)
        }
        
        emitter.emitterCells = cells
        layer.addSublayer(emitter)
    }
    
    // Cria uma imagem de confete retangular colorido
    private func createConfettiImage(size: CGSize, color: UIColor) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let cgContext = context.cgContext
            
            // 1. Configura o brilho (shadow)
            cgContext.setShadow(
                offset: .zero,
                blur: 2,
                color: color.withAlphaComponent(0.7).cgColor
            )
            
            // 2. Desenha o retângulo colorido
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // 3. Remove o shadow para não afetar outros desenhos
            cgContext.setShadow(offset: .zero, blur: 0, color: nil)
        }
    }
    
    func startConfetti() {
        emitter.birthRate = 1  // Ativa a emissão
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.stopConfetti()  // Para após 2 segundos
        }
    }
    
    func stopConfetti() {
        emitter.birthRate = 0  // Desativa a emissão
    }
}
