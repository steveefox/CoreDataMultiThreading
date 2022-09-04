//
//  MovieListViewModel.swift
//  CoreDataMultiThreading
//
//  Created by Nikita on 4.09.22.
//

import Foundation
import CoreData
import NotificationCenter

// MARK: - MovieViewModel
struct MovieViewModel {
    let movie: Movie
    
    var id: NSManagedObjectID {
        return movie.objectID
    }
    
    var title: String {
        return movie.title ?? ""
    }
    
    var rating: Int16 {
        return movie.rating
    }
}

// MARK: - MovieListViewModel
final class MovieListViewModel: NSObject,  ObservableObject {
    @Published var movies: [MovieViewModel] = []
    
    private var fetchResultController: NSFetchedResultsController<Movie>!
    
    override init() {
        super.init()
        
        setupDidSaveObjectsNotification()
    }
}

// MARK: - Public
extension MovieListViewModel {
    func loadMovies() {
        let request: NSFetchRequest<Movie> = Movie.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        fetchResultController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: CoreDataManager.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        try? fetchResultController.performFetch()
        fetchResultController.delegate = self
        
        movies = (fetchResultController.fetchedObjects ?? []).map { MovieViewModel(movie: $0) }

//        do {
//            movies = try CoreDataManager.shared.viewContext.fetch(request).map { MovieViewModel(movie: $0) }
//        } catch {
//            print(error)
//        }
    }
    
    func saveMovie(title: String, rating: Int16) {
        CoreDataManager.shared.persistentContainer.performBackgroundTask { context in
            let movie = Movie(context: context)
            movie.title = title
            movie.rating = rating
            
            try? context.save()
        }
    }
    
    func saveMovieViewContext(title: String, rating: Int16) {
        let viewContext = CoreDataManager.shared.viewContext
        let movie = Movie(context: viewContext)
        movie.title = title
        movie.rating = rating
        
        try? viewContext.save()
    }
    
    func updateRatingForMovieWith(id: NSManagedObjectID, newRating: Int16, in context: NSManagedObjectContext) {
        context.perform {
            guard let movie = try? context.existingObject(with: id) as? Movie else { return }
            
            movie.rating = newRating
            try? context.save()
        }
    }
}

// MARK: - Private
private extension MovieListViewModel {
    func setupDidSaveObjectsNotification() {
        let notificationName = NSManagedObjectContext.didSaveObjectsNotification
        let context: NSManagedObjectContext = CoreDataManager.shared.backgroundContext
        NotificationCenter.default.addObserver(self, selector: #selector(didSave(_:)), name: notificationName, object: context)
    }
}

// MARK: - Notification Handlers
@objc private extension MovieListViewModel {
    func didSave(_ notification: Notification) {
//        let viewContext = CoreDataManager.shared.viewContext
//        DispatchQueue.main.async {
//            viewContext.mergeChanges(fromContextDidSave: notification)
//        }
    }
}

// MARK: - Description
extension MovieListViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        movies = (controller.fetchedObjects as? [Movie] ?? []).map { MovieViewModel(movie: $0) }
    }
}
