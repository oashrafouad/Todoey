//
//  LaunchViewController.swift
//  Todoey
//
//  Created by Omar Ashraf on 07/01/2024.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {
    
    private let imageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
        imageView.image = UIImage(named: "LaunchIcon")
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(imageView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.center = view.center
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.animate()
        }
    }
    
    private func animate() {
        UIView.animate(withDuration: 0.7) {
            let size = self.view.frame.size.width * 2
            let diffX = size - self.view.frame.size.width
            let diffY = self.view.frame.size.height - size
            self.imageView.frame = CGRect(x: -(diffX / 2), y: diffY / 2, width: size, height: size)
        }
        
        UIView.animate(withDuration: 0.7, animations:{
            self.imageView.alpha = 0
        }) { done in
            if done {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    let rootVC = self.storyboard?.instantiateViewController(identifier: "rootVC") as! UINavigationController

                    rootVC.modalTransitionStyle = .crossDissolve
                    rootVC.modalPresentationStyle = .fullScreen
                    self.present(rootVC, animated: true)

                }
            }
        }
    }
}
