//
// UsersSearchViewModel.swift
// Copyright © 2020 Matt Nunes-Spraggs
//


import Foundation

// MARK: - Delegate Protocol

protocol UsersSearchViewModelDelegate: class {
    func usersSearchViewModelHasUpdatedResults(_ viewModel: UsersSearchViewModel)
    func usersSearchViewModel(_ viewModel: UsersSearchViewModel, didEncounterError error: Error)
}

// MARK: - View Model

class UsersSearchViewModel {

    // MARK: - Initializers

    init(_ dataProvider: UsersDataProvider) {
        self.usersDataProvider = dataProvider
    }

    // MARK: - Private Properties

    private let usersDataProvider: UsersDataProvider
    private var currentSearchProgress: Progress?
    private var results: [User] = [] {
        didSet {
            DispatchQueue.main.async {
                self.delegate?.usersSearchViewModelHasUpdatedResults(self)
            }
        }
    }

    // MARK: - Public Properties

    weak var delegate: UsersSearchViewModelDelegate? = nil

    var searchText: String? = nil {
        didSet {
            searchTextDidUpdate(searchText)
        }
    }

    var numberOfResults: Int {
        return results.count
    }

    // MARK: - Public API

    func displayNameAtIndex(_ index: Int) -> String {
        let user = results[index]
        return user.name.first + " " + user.name.last
    }

    // MARK: - Private API

    private func searchTextDidUpdate(_ searchText: String?) {
        currentSearchProgress?.cancel()
        guard let searchText = searchText, !searchText.isEmpty else {
            self.results = []
            return
        }

        self.currentSearchProgress = usersDataProvider.search(query: searchText) { result in
            switch result {
            case .success(let users):
                self.results = users

            case .failure(let error):
                self.handleError(error)
            }
            self.currentSearchProgress = nil
        }
    }

    private func handleError(_ error: Error) {
        guard !error.isUrlCancelled else {
            return
        }

        self.results = []
        DispatchQueue.main.async {
            self.delegate?.usersSearchViewModel(self, didEncounterError: error)
        }
    }

}