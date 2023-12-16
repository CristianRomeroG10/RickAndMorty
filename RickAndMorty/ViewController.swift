//
//  ViewController.swift
//  RickAndMorty
//
//  Created by Diplomado on 01/12/23.
//

import UIKit

class ViewController: UIViewController {
    
    //MARK: OUTLETS
    @IBOutlet weak var characterTableView: UITableView!{
        didSet{
            characterTableView.register(UINib(nibName: "CharacterTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        }
    }
    var character: [Character] = []
    
    let restClient = RESTClient<PaginaterResponse<Character>>(client: Client("https://rickandmortyapi.com"))
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Charater"
        self.navigationController?.navigationBar.prefersLargeTitles = true
//        restClient.show("/api/character"){ response in
//            //response.results
//            print(response.results)
        restClient.show("/api/character",page: "2") { response in
            print(response.results)
            self.character = response.results
            self.characterTableView.dataSource = self
            self.characterTableView.delegate = self
            self.reloadTableView()
        }
        
        }
    //query: ["page":"2"]
    func reloadTableView(){
        DispatchQueue.main.async{
            self.characterTableView.reloadData()
        }
    }
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
