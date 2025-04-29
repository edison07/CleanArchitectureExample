//
//  Created by Edison on 2025/4/25.
//

import UIKit

final class TimeSlotCell: UICollectionViewCell {
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 14)
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(timeLabel)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            timeLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            timeLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            timeLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 4),
            timeLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -4)
        ])
    }
    
    func configure(isAvailable: Bool, time: String?) {
        if let timeText = time {
            timeLabel.text = timeText
            timeLabel.textColor = isAvailable ? .systemGreen : .systemGray
            isUserInteractionEnabled = true
        } else {
            timeLabel.text = ""
            isUserInteractionEnabled = false
        }
    }
}
