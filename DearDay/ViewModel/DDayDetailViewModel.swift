//
//  DDayDetailViewModel.swift
//  DearDay
//
//  Created by Jaehui Yu on 10/31/24.
//

import Foundation
import Combine

final class DDayDetailViewModel {
    private let repository = DDayRepository()
    
    var cancellables = Set<AnyCancellable>()
    
    var input = Input()
    @Published var output = Output()
    
    init() {
        transform()
    }
}

extension DDayDetailViewModel: ViewModelType {
    struct Input {
        var deleteDDay = PassthroughSubject<DDay, Never>()
    }
    
    struct Output {
        var deleteCompleted = PassthroughSubject<Void, Never>() // 삭제 완료 신호
    }
    
    enum Action {
        case deleteDDay(DDay)
    }
    
    func action(_ action: Action) {
        switch action {
        case .deleteDDay(let dday):
            input.deleteDDay.send(dday)
        }
    }
    
    func transform() {
        input.deleteDDay
            .sink { [weak self] dday in
                guard let self = self else { return }
                ImageDocumentManager.shared.removeImageFromDocument(fileName: "\(dday.pk)")
                self.repository.deleteItem(dday)
                self.output.deleteCompleted.send() // 삭제 완료 이벤트 전송
            }
            .store(in: &cancellables)
    }
}
