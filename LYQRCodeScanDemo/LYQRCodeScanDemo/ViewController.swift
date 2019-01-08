//
//  ViewController.swift
//  LYQRCodeScan
//
//  Created by 李扬 on 2019/1/7.
//  Copyright © 2019 rrl360. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let btn = UIButton(type: .system)
        btn.frame = CGRect(x: 100, y: 100, width: 100, height: 44)
        btn.setTitle("扫码", for: .normal)
        btn.addTarget(self, action: #selector(p_actionBtn), for: .touchUpInside)
        view.addSubview(btn)
    }
    
    @objc private func p_actionBtn() {
        
        let scan = ScanDemoViewController(scanStyle: ScanViewStyle.qqStyle)
        self.present(scan, animated: true, completion: nil)
    }
}

