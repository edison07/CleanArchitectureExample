//
//  Created by Edison on 2025/4/25.
//

import UIKit
import Combine

private enum LayoutConstant {
    static let itemWidth: CGFloat = 80
    static let spacing: CGFloat = 4
    static let sideInset: CGFloat = 4
}

@MainActor
final class ScheduleViewController: UIViewController {
    private let viewModel: ScheduleViewModelProtocol
    private let errorHandler: ErrorHandlerProtocol
    private let autoFetch: Bool

    private var timeSlotCollectionView: UICollectionView!
    private var dateCollectionView: UICollectionView!
    private var timezoneLabel: UILabel!
    private var weekNavigationView: WeekNavigationView!
    private var cancellables = Set<AnyCancellable>()
    private var fetchTask: Task<Void, Never>?
    private(set) var isObservationsSetup = false
    
    init(viewModel: ScheduleViewModelProtocol, 
         errorHandler: ErrorHandlerProtocol = ErrorHandler.shared,
         autoFetch: Bool = true) {
        self.viewModel = viewModel
        self.errorHandler = errorHandler
        self.autoFetch = autoFetch
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupObservations()
        if autoFetch { fetchSchedules() }
    }
    
    deinit { fetchTask?.cancel() }
    
    private func fetchSchedules() {
        fetchTask?.cancel()
        fetchTask = Task {
            await viewModel.fetchSchedules()
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // Title Label
        let titleLabel = UILabel()
        titleLabel.text = "Available times"
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .black
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Week Navigation
        weekNavigationView = WeekNavigationView()
        weekNavigationView.delegate = self
        view.addSubview(weekNavigationView)
        weekNavigationView.translatesAutoresizingMaskIntoConstraints = false
        
        // Timezone Label
        timezoneLabel = UILabel()
        timezoneLabel.font = .systemFont(ofSize: 10)
        timezoneLabel.textAlignment = .center
        timezoneLabel.textColor = .black
        view.addSubview(timezoneLabel)
        timezoneLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Collection Views
        setupCollectionViews()
        
        // Constraints
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            weekNavigationView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            weekNavigationView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            weekNavigationView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            timezoneLabel.topAnchor.constraint(equalTo: weekNavigationView.bottomAnchor, constant: 10),
            timezoneLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            timezoneLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            dateCollectionView.topAnchor.constraint(equalTo: timezoneLabel.bottomAnchor, constant: 8),
            dateCollectionView.leadingAnchor.constraint(equalTo: timeSlotCollectionView.leadingAnchor),
            dateCollectionView.trailingAnchor.constraint(equalTo: timeSlotCollectionView.trailingAnchor),
            dateCollectionView.heightAnchor.constraint(equalToConstant: 60),
            
            timeSlotCollectionView.topAnchor.constraint(equalTo: dateCollectionView.bottomAnchor, constant: 4),
            timeSlotCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            timeSlotCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            timeSlotCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupCollectionViews() {
        let layout = createCompositionalLayout()
        timeSlotCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        timeSlotCollectionView.backgroundColor = .white
        timeSlotCollectionView.delegate = self
        timeSlotCollectionView.dataSource = self
        timeSlotCollectionView.register(TimeSlotCell.self, forCellWithReuseIdentifier: "TimeSlotCell")
        view.addSubview(timeSlotCollectionView)
        timeSlotCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        let dateLayout = UICollectionViewFlowLayout()
        dateLayout.scrollDirection = .horizontal
        dateLayout.minimumLineSpacing = LayoutConstant.spacing
        dateLayout.sectionInset = UIEdgeInsets(top: 0, left: LayoutConstant.sideInset, bottom: 0, right: LayoutConstant.sideInset)
        dateLayout.itemSize = CGSize(width: LayoutConstant.itemWidth, height: 60)
        
        dateCollectionView = UICollectionView(frame: .zero, collectionViewLayout: dateLayout)
        dateCollectionView.collectionViewLayout = dateLayout
        dateCollectionView.showsHorizontalScrollIndicator = false
        dateCollectionView.delegate = self
        dateCollectionView.dataSource = self
        dateCollectionView.backgroundColor = .white
        dateCollectionView.register(DateHeaderCell.self, forCellWithReuseIdentifier: "DateHeaderCell")
        view.addSubview(dateCollectionView)
        dateCollectionView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
            guard let self = self else { return nil }
                let slotsCount = self.viewModel.daySchedules[sectionIndex].sortedSlots.count
                let count = max(slotsCount, 1)
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .absolute(LayoutConstant.itemWidth),
                heightDimension: .absolute(40)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .absolute(LayoutConstant.itemWidth),
                heightDimension: .estimated(CGFloat(count) * 40)
            )
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: groupSize,
                repeatingSubitem: item,
                count: count
            )
            group.interItemSpacing = .fixed(LayoutConstant.spacing)
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = .init(top: 0, leading: LayoutConstant.sideInset, bottom: 0, trailing: 0)

            return section
        }

        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.scrollDirection = .horizontal
        layout.configuration = config

        return layout
    }


    func setupObservations() {
        guard !isObservationsSetup else { return }
        isObservationsSetup = true
        viewModel.objectWillChange
            .sink { [weak self] _ in
                Task { @MainActor in
                    guard let self = self else { return }
                    self.updateWeekLabel()
                    self.updateTimezoneLabel()
                    self.timeSlotCollectionView.reloadData()
                    self.dateCollectionView.reloadData()
                }
            }
            .store(in: &cancellables)

        viewModel.errorPublisher
            .compactMap { $0 }
            .sink { [weak self] error in
                guard let self = self else { return }
                self.errorHandler.handle(error: error, in: self)
            }
            .store(in: &cancellables)
    }
    
    private func updateWeekLabel() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        let dates = viewModel.getWeekDates()
        let weekText = "\(formatter.string(from: dates.first!)) - \(formatter.string(from: dates.last!))"
        weekNavigationView.configure(weekText: weekText, canMoveToPrevious: viewModel.canMoveToPreviousWeek())
    }
    
    private func updateTimezoneLabel() {
        let identifier = viewModel.timezone.identifier
        let offset = viewModel.timezone.secondsFromGMT() / 3600
        timezoneLabel.text = "All times listed are in your local timezone: \(identifier) GMT \(offset >= 0 ? "+" : "")\(offset):00"
    }
}

// MARK: - WeekNavigationViewDelegate
extension ScheduleViewController: WeekNavigationViewDelegate {
    func didTapPreviousWeek() {
        viewModel.moveToPreviousWeek()
    }
    
    func didTapNextWeek() {
        viewModel.moveToNextWeek()
    }
}

// MARK: - UICollectionViewDataSource
extension ScheduleViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == dateCollectionView {
            return 1
        } else {
            return viewModel.daySchedules.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == dateCollectionView {
            return viewModel.getWeekDates().count
        } else {
            let slots = viewModel.daySchedules[section].sortedSlots
            return max(slots.count, 1)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == dateCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateHeaderCell", for: indexPath) as! DateHeaderCell
            let date = viewModel.getWeekDates()[indexPath.row]
            cell.configure(with: date)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimeSlotCell", for: indexPath) as! TimeSlotCell
            
            let day = viewModel.daySchedules[indexPath.section]
            let slots = day.sortedSlots
            
            if slots.isEmpty {
                cell.configure(isAvailable: false, time: nil)
            } else {
                let (slot, isAvailable) = slots[indexPath.row]
                
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm"
                let timeText = formatter.string(from: slot.start)
                
                cell.configure(isAvailable: isAvailable, time: timeText)
            }
            
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegate
extension ScheduleViewController: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == timeSlotCollectionView {
            dateCollectionView.contentOffset.x = scrollView.contentOffset.x
        } else if scrollView == dateCollectionView {
            timeSlotCollectionView.contentOffset.x = scrollView.contentOffset.x
        }
    }
}

