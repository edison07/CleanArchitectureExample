//
//  Created by Edison on 2025/4/25.
//

import UIKit

@MainActor
protocol WeekNavigationViewDelegate: AnyObject {
    func didTapPreviousWeek()
    func didTapNextWeek()
}

final class WeekNavigationView: UIView {
    private let weekLabel = UILabel()
    private let previousButton = UIButton(type: .system)
    private let nextButton = UIButton(type: .system)
    
    weak var delegate: WeekNavigationViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        
        previousButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        previousButton.addTarget(self, action: #selector(previousWeekTapped), for: .touchUpInside)
        
        weekLabel.font = .systemFont(ofSize: 18, weight: .medium)
        weekLabel.textAlignment = .center
        weekLabel.textColor = .black
        
        nextButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        nextButton.addTarget(self, action: #selector(nextWeekTapped), for: .touchUpInside)
        
        stackView.addArrangedSubview(previousButton)
        stackView.addArrangedSubview(weekLabel)
        stackView.addArrangedSubview(nextButton)
        
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    func configure(weekText: String, canMoveToPrevious: Bool) {
        weekLabel.text = weekText
        previousButton.isEnabled = canMoveToPrevious
    }
    
    @objc private func previousWeekTapped() {
        delegate?.didTapPreviousWeek()
    }
    
    @objc private func nextWeekTapped() {
        delegate?.didTapNextWeek()
    }
} 
