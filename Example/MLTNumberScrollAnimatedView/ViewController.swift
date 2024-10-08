//
//  ViewController.swift
//  MLTNumberScrollAnimatedView
//
//  Created by Hou Rui on 10/08/2024.
//  Copyright (c) 2024 Hou Rui. All rights reserved.
//

import UIKit
import SnapKit
import MLTNumberScrollAnimatedView

class ViewController: UIViewController {

    private let animateNumberView = MLTNumberScrollAnimatedView(font: .systemFont(ofSize: 30), textColor: .red)
    private var currentValue: Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(animateNumberView)
        view.addSubview(textfield)
        animateNumberView.snp.makeConstraints { make in
            make.center.equalTo(self.view)
        }
        let label = UILabel()
        label.text = "--.--"
        view.addSubview(label)
        
        label.snp.makeConstraints { make in
            make.left.equalTo(animateNumberView.snp.right).offset(3)
            make.centerY.equalTo(animateNumberView)
        }
        
        let btn = UIButton(frame: CGRect(x: 80, y: 180, width:120, height: 40))
        btn.layer.borderColor = UIColor.brown.cgColor
        btn.addTarget(self, action: #selector(clickBtn), for: .touchUpInside)
        btn.setTitleColor(.gray, for: .normal)
        btn.setTitle("Change", for: .normal)
        btn.layer.borderWidth = 1
        self.view.addSubview(btn)
        
        let change = UIButton(frame: CGRect(x: 80, y: 220, width:120, height: 40))
        change.layer.borderColor = UIColor.brown.cgColor
        change.addTarget(self, action: #selector(clickBtnNoAni), for: .touchUpInside)
        change.setTitleColor(.gray, for: .normal)
        change.setTitle("Change no ani", for: .normal)
        change.layer.borderWidth = 1
        self.view.addSubview(change)

        let clearbtn = UIButton(frame: CGRect(x: 200, y: 180, width:120, height: 40))
        clearbtn.layer.borderColor = UIColor.brown.cgColor
        clearbtn.addTarget(self, action: #selector(clickClearBtn), for: .touchUpInside)
        clearbtn.setTitleColor(.gray, for: .normal)
        clearbtn.setTitle("clear", for: .normal)
        clearbtn.layer.borderWidth = 1
        self.view.addSubview(clearbtn)
    }
    
    @objc func clickBtn() {
        animateNumberView.setValue(textfield.text, animated: true)
    }
    
    @objc func clickBtnNoAni() {
        animateNumberView.setValue(textfield.text, animated: false)
    }
    
    @objc func clickClearBtn() {
        animateNumberView.setValue(nil, animated: true)
    }
    
    
    lazy var textfield: UITextField = {
        let tfield = UITextField(frame: CGRect(x: 80, y: 80, width: 300, height: 40))
        tfield.keyboardType = .decimalPad
        tfield.textColor = .orange
        tfield.layer.borderColor = UIColor.brown.cgColor
        tfield.layer.borderWidth = 1
        tfield.placeholder = "输入你的数字数字数字字字字字"
        return tfield
    }()

}
