//
//  ShowPopUpVC.swift
//  ContactSyncing
//
//  Created by Admin on 10/10/23.
//

import Foundation
import UIKit

protocol ShowPopUpPropertiesProtocol {
    var image: UIImage? { get }
    var title: String { get }
    var description: String { get }
    var filledButtonTitle: String { get }
    var unfilledButtonTitle: String { get }
}

class ShowPopUpVC: UIViewController {
    
    private var titleLabel = UILabel()
    private var descriptionLabel = UILabel()
    private var filledButton = WWButton()
    private var unfilledButton = WWButton()
    private var infoImageView = UIImageView()
    private var stackView = UIStackView()
    private var container = UIView()
    
    private var filledButtonClosure: (() -> ())?
    private var unfilledButtonClosure: (() -> ())?
    private var titleString: String?
    private var descriptionString: String?
    private var filledButtonTitle: String?
    private var unfilledButtonTitle: String?
    private var infoImage: UIImage?
    
    override func viewDidLoad() {
        setupSubviews()
        setUpUI()
    }
    
    func setupSubviews() {
        container.layer.cornerRadius = 28
        container.backgroundColor = .white
        view.addSubview(container)
        container.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        container.translatesAutoresizingMaskIntoConstraints = false
        filledButton.translatesAutoresizingMaskIntoConstraints = false
        unfilledButton.translatesAutoresizingMaskIntoConstraints = false
        filledButton.isFilled = true
        unfilledButton.isFilled = false
        filledButton.layer.cornerRadius = 25
        unfilledButton.layer.cornerRadius = 25
        setStackView()
    }
    
    func setUpUI() {
        titleLabel.numberOfLines = 0
        descriptionLabel.numberOfLines = 0
        titleLabel.font = .rounded(ofSize: 22, weight: .bold)
        descriptionLabel.font = .rounded(ofSize: 16, weight: .medium)
        titleLabel.textColor = AppColors.greyBlackTextColor.color.withAlphaComponent(0.87)
        descriptionLabel.textColor = AppColors.greyBlackTextColor.color.withAlphaComponent(0.87)
        titleLabel.text = titleString
        descriptionLabel.text = descriptionString
        filledButton.setTitle(filledButtonTitle, for: .normal)
        unfilledButton.setTitle(unfilledButtonTitle, for: .normal)
        filledButton.titleLabel?.font = .rounded(ofSize: 17, weight: .semibold)
        unfilledButton.titleLabel?.font = .rounded(ofSize: 17, weight: .semibold)
        infoImageView.image = infoImage
        infoImageView.contentMode = .scaleAspectFit
        
        filledButton.addTarget(self, action: #selector(filledButtonTapped(_:)), for: .touchUpInside)
        unfilledButton.addTarget(self, action: #selector(unfilledButtonTapped(_:)), for: .touchUpInside)
        align()
    }
    
    func setStackView() {
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 24
        stackView.addArrangedSubview(infoImageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descriptionLabel)
        stackView.addArrangedSubview(filledButton)
        stackView.addArrangedSubview(unfilledButton)
    }
    
    func align() {
        NSLayoutConstraint.activate([
            container.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 24),
            container.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -24),
            container.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leftAnchor.constraint(equalTo: container.leftAnchor, constant: 24),
            stackView.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -24),
            stackView.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            stackView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -24),
            filledButton.heightAnchor.constraint(equalToConstant: 50),
            unfilledButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
    
    @discardableResult
    func setProperties(model: ShowPopUpPropertiesProtocol) -> Self {
        titleString = model.title
        descriptionString = model.description
        filledButtonTitle = model.filledButtonTitle
        unfilledButtonTitle = model.unfilledButtonTitle
        infoImage = model.image
        return self
    }

    @discardableResult
    func setClosures(filledButtonClosure: @escaping () -> (), unfilledButtonClosure: @escaping () -> ()) -> Self {
        self.filledButtonClosure = filledButtonClosure
        self.unfilledButtonClosure = unfilledButtonClosure
        return self
    }
    
    func present(on vc: UIViewController) {
        transitioningDelegate = self
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
        vc.present(self, animated: true)
    }
    
    @objc private func filledButtonTapped(_ sender: UIButton) {
        filledButtonClosure?()
    }
    
    @objc private func unfilledButtonTapped(_ sender: UIButton) {
        unfilledButtonClosure?()
    }
}

extension ShowPopUpVC: UIViewControllerTransitioningDelegate {
    internal func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        ShowPopUpVCPresentingTransitionaing()
    }
    
    internal func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        ShowPopUpVCDismissedTransitionaing()
    }
}


class ShowPopUpVCPresentingTransitionaing: NSObject, UIViewControllerAnimatedTransitioning {
    
    let originFrame = UIScreen.main.bounds
    let dimmerView = UIView()
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        1
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toVC = transitionContext.viewController(forKey: .to) else { return }
        
        dimmerView.frame = originFrame
        dimmerView.tag = 908523408934508934
        
        transitionContext.containerView.addSubview(dimmerView)
        transitionContext.containerView.addSubview(toVC.view)
        toVC.view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        dimmerView.alpha = 0
        toVC.view.alpha = 0
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: { [weak self] in
            self?.dimmerView.backgroundColor = AppColors.greyDisableColor.color.withAlphaComponent(0.52)
            self?.dimmerView.alpha = 1
            toVC.view.transform = .identity
            toVC.view.alpha = 1
        }) { finish in
            transitionContext.completeTransition(finish)
        }
    }
}

class ShowPopUpVCDismissedTransitionaing: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        1
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from), let toVC = transitionContext.viewController(forKey: .to) else { return }
        
        let dimmerView = transitionContext.containerView.subviews.filter { $0.tag == 908523408934508934 }.first
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            toVC.view.transform = .identity
            fromVC.view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            
            fromVC.view.alpha = 0
            dimmerView?.alpha = 0
        }) { finish in
            transitionContext.completeTransition(finish)
        }
    }
}

class WWButton: UIButton {
    @IBInspectable var isFilled: Bool = false {
        didSet {
            didSetProps()
        }
    }
    
    private var buttonColor: UIColor = AppColors.greenButtonColor.color
    
    override var isEnabled: Bool {
        didSet {
            makeEnable(isEnabled)
        }
    }
        
    func didSetProps() {
        backgroundColor = isFilled ? buttonColor : .clear
        layer.borderColor = isFilled ? UIColor.clear.cgColor : buttonColor.cgColor
        layer.borderWidth = isFilled ? 0 : 1
        setTitleColor(isFilled ? .white : buttonColor, for: .normal)
        layer.cornerRadius = bounds.height / 2
        // TODO: set title label font as sf pro is not defined in appfonts
    }
    
    private func makeEnable(_ enable: Bool) {
        backgroundColor = enable ? buttonColor : buttonColor.withAlphaComponent(0.5)
    }
}
