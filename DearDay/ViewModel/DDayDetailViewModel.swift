//
//  DDayDetailViewModel.swift
//  DearDay
//
//  Created by Jaehui Yu on 10/31/24.
//

import Foundation
import Combine

@MainActor
final class DDayDetailViewModel {
    private let repository: DDayRepository
    private let apiService: APIService
    
    var cancellables = Set<AnyCancellable>()
    
    var input = Input()
    @Published var output = Output()
    
    init(repository: DDayRepository = DDayRepository(), apiService: APIService = APIService()) {
        self.repository = repository
        self.apiService = apiService
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
        case .deleteDDay(let dDay):
            input.deleteDDay.send(dDay)
        }
    }
    
    func transform() {
        input.deleteDDay
            .sink { [weak self] dDay in
                guard let self = self else { return }
                ImageDocumentManager.shared.removeImageFromDocument(fileName: "\(dDay.pk)")
                self.repository.deleteItem(dDay)
                self.output.deleteCompleted.send() // 삭제 완료 이벤트 전송
            }
            .store(in: &cancellables)
    }
}
