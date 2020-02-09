//
//  InputViewController.swift
//  RxSwiftDelegateExample
//
//  Created by Park GilNam on 2020/02/09.
//  Copyright © 2020 swieeft. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

@objc protocol InputViewControllerDelegate: class {
    @objc optional func sendString(string: String)
}

class RxInputViewControllerProxy: DelegateProxy<InputViewController, InputViewControllerDelegate>, DelegateProxyType, InputViewControllerDelegate {
    static func registerKnownImplementations() {
        self.register { (inputViewController) -> RxInputViewControllerProxy in
            RxInputViewControllerProxy(parentObject: inputViewController, delegateProxy: self)
        }
    }

    static func currentDelegate(for object: InputViewController) -> InputViewControllerDelegate? {
        return object.delegate
    }

    static func setCurrentDelegate(_ delegate: InputViewControllerDelegate?, to object: InputViewController) {
        object.delegate = delegate
    }
}

extension Reactive where Base: InputViewController {
    var rx_deleagte: DelegateProxy<InputViewController, InputViewControllerDelegate> {
        return RxInputViewControllerProxy.proxy(for: self.base)
    }

    var rx_sendString: Observable<String?> {
        return rx_deleagte.sentMessage(#selector(InputViewControllerDelegate.sendString(string:))).map { arr in arr[0] as? String }
    }
}

class InputViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var confirmButton: UIButton!
    
    weak var delegate: InputViewControllerDelegate?
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        confirmButton.rx.tap
            .throttle(.seconds(1), scheduler: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] _ in
                guard let string = self?.textField.text else { return }
                
                self?.dismiss(animated: true, completion: {
                    self?.delegate?.sendString?(string: string)
                })
            })
            .disposed(by: disposeBag)
        
        textField.rx.controlEvent(.editingDidEndOnExit)
            .subscribe(onNext: { [weak self] _ in
                self?.view.endEditing(true)
            })
            .disposed(by: disposeBag)
    }
}
