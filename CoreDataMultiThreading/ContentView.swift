//
//  ContentView.swift
//  CoreDataMultiThreading
//
//  Created by Nikita on 4.09.22.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    @StateObject private var movieListViewModel: MovieListViewModel = .init()
    
    @State private var movieName: String = ""
    
    
//    private func loadMovies() {
//        let request: NSFetchRequest<Movie> = Movie.fetchRequest()
//
//        do {
//            movies = try CoreDataManager.shared.viewContext.fetch(request)
//        } catch {
//            print(error)
//        }
//    }
//
//    private func loadAllMovies(completion: @escaping ([Movie]) -> Void) {
//        CoreDataManager.shared.persistentContainer.performBackgroundTask { context in
//            let request: NSFetchRequest<Movie> = Movie.fetchRequest()
//            guard let movies = try? context.fetch(request) else {
//                completion([])
//                return
//            }
//
//            DispatchQueue.main.async {
//                let viewContext = CoreDataManager.shared.viewContext
//                let movies = movies.compactMap { movie in
//                    try? viewContext.existingObject(with: movie.objectID) as? Movie
//                }
//                completion(movies)
//            }
////            completion(movies)
//        }
//    }
    
    private func getMoviesBy(rating: Int, in context: NSManagedObjectContext) -> [Movie] {
        var movies: [Movie] = []
        
        context.performAndWait {
            let request: NSFetchRequest<Movie> = Movie.fetchRequest()
            request.predicate = NSPredicate(format: "%K >= %i", #keyPath(Movie.rating), rating)
            movies = (try? context.fetch(request)) ?? []
        }
        
        return movies
    }
    
    private func saveMovie(completion: @escaping (() -> Void)) {
        DispatchQueue.global().async {
            let backgroundContext = CoreDataManager.shared.persistentContainer.newBackgroundContext()
            backgroundContext.perform {
                let movie = Movie(context: backgroundContext)
                movie.title = movieName
                movie.rating = Int16.random(in: 1...5)
                try? backgroundContext.save()
                completion()
            }
        }
    }
    
    var body: some View {
        
        NavigationView {
        VStack {
            
            
            
            VStack {
                TextField("Movie name", text: $movieName)
                
                HStack {
                    Button("Save bacground context") {
                        movieListViewModel.saveMovie(title: movieName, rating: Int16.random(in: 1...5))
                    }
                    Spacer()
                    Button("Save View Context") {
                        movieListViewModel.saveMovieViewContext(title: movieName, rating: Int16.random(in: 1...5))
                    }
                }
            }.padding()
            
            List(movieListViewModel.movies, id: \.id) { movie in
                HStack {
                    Text(movie.title)
                    Spacer()
                    Text("\(movie.rating)")
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Button("Update") {
                        movieListViewModel.updateRatingForMovieWith(id: movie.id,
                                                                    newRating: Int16.random(in: 1...5),
                                                                    in: CoreDataManager.shared.backgroundContext)
                    }
                }
            }.listStyle(PlainListStyle())
        .navigationTitle("Movies")
            
        }.onAppear(perform: {
            movieListViewModel.loadMovies()
//            loadMovies()
//            loadAllMovies { movies in
//                DispatchQueue.main.async {
//                    self.movies = movies
//                }
//                movies.forEach { movie in
////                    print(movie.title ?? "")
//                    print(movie.objectID)
//                }
//            }
        })
            
        }
           
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
