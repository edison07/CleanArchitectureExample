//
//  Created by Edison on 2025/4/25.
//

import UIKit

final class DateHeaderCell: UICollectionViewCell {
    private let dayLabel = UILabel()
    private let dateLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        let stack = UIStackView(arrangedSubviews: [dayLabel, dateLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 4
        contentView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        dayLabel.font = .systemFont(ofSize: 14)
        dayLabel.textColor = .black
        dateLabel.font = .systemFont(ofSize: 18, weight: .medium)
        dateLabel.textColor = .black
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(with date: Date) {
        let dayFmt = DateFormatter()
        dayFmt.dateFormat = "EEE"
        dayLabel.text = dayFmt.string(from: date)
        let dateFmt = DateFormatter()
        dateFmt.dateFormat = "dd"
        dateLabel.text = dateFmt.string(from: date)
        backgroundColor = Calendar.current.isDateInToday(date) ? .lightGray : .clear
    }
}
