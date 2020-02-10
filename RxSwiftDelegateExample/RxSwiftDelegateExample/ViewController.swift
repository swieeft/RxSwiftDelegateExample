//
//  ViewController.swift
//  RxSwiftDelegateExample
//
//  Created by Park GilNam on 2020/02/09.
//  Copyright © 2020 swieeft. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController, InputViewControllerDelegate {

    @IBOutlet weak var inputLabel: UILabel!
    @IBOutlet weak var openButton: UIButton!
    @IBOutlet weak var openSubjectButton: UIButton!
    
    var disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyBoard = UIStoryboard(name: "Main", bundle: .main)
        let inputVC = storyBoard.instantiateViewController(withIdentifier: "InputViewController") as? InputViewController
        
        inputVC?.rx.rx_deleagte.setForwardToDelegate(self, retainDelegate: false)
        inputVC?.rx.rx_sendString
            .bind(to: inputLabel.rx.text)
            .disposed(by: disposeBag)
        
        openButton.rx.tap
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                if let inputVC = inputVC {
                    self?.present(inputVC, animated: true, completion: nil)
                }
            })
            .disposed(by: disposeBag)

        openSubjectButton.rx.tap
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .flatMap { [weak self] _ -> Observable<String> in
                guard let inputVC = inputVC else { return .empty() }

                self?.present(inputVC, animated: true, completion: nil)

                return inputVC.inputString
        }
        .bind(to: inputLabel.rx.text)
        .disposed(by: disposeBag)
    }
}

