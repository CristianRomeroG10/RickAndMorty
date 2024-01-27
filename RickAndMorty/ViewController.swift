//
//  ViewController.swift
//  RickAndMorty
//
//  Created by Diplomado on 01/12/23.
//

import UIKit

class ViewController: UIViewController {
    
    var currentPage = 1
    var isLoadingData = false
    
    //MARK: OUTLETS
    @IBOutlet weak var characterTableView: UITableView!{
        didSet{
            characterTableView.register(UINib(nibName: "CharacterTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        }
    }
    var character: [Character] = []
    
    func fetchData(page: Int){
        let restClient = RESTClient<PaginaterResponse<Character>>(client: Client("https://rickandmortyapi.com"))
        restClient.show("/api/character",page: "\(page)") { response in
            print(response.results)
           
            if page == 1 {
                self.character = response.results
            } else {
                self.character.append(contentsOf: response.results)
            }
            self.characterTableView.reloadData()
            self.isLoadingData = false
        }
    }
    
    func LoadMoreData(){
        guard !isLoadingData else {
            return
        }
        isLoadingData = true
        currentPage += 1
        fetchData(page: currentPage)
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Charater"
        self.navigationController?.navigationBar.prefersLargeTitles = true
//        restClient.show("/api/character"){ response in
//            //response.results
//            print(response.results)
        fetchData(page: currentPage)
        self.characterTableView.dataSource = self
        self.characterTableView.delegate = self
        self.characterTableView.prefetchDataSource = self
        }
    //query: ["page":"2"]
    
}

extension ViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        character.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")as! CharacterTableViewCell
        cell.idLabel.text = "ID: \(character[indexPath.row].id)"
        cell.nameLabel.text = character[indexPath.row].name
        cell.speciesLabel.text = "SPECIE: \(character[indexPath.row].species)"
        cell.genderLabel.text = "GENDER: \(character[indexPath.row].gender)"
        cell.statusLabel.text = "STATUS: \(character[indexPath.row].status)"
        cell.typeLabel.text = "TYPE: \(character[indexPath.row].type)"
        let urlString = character[indexPath.row].image
       
        guard let url = URL(string: urlString) else {return cell}
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data{
                guard let image = UIImage(data: data) else {return}
                DispatchQueue.main.async{
                    cell.characterImage.image = image
                }
            }
        }
        task.resume()
        return cell
    }
    
    
}
extension ViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}

extension ViewController: UITableViewDataSourcePrefetching{
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        guard let lastIndexPath = indexPaths.last, lastIndexPath.row == character.count - 1 else { return }
        LoadMoreData()
    }
    
    
}
