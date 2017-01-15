//
//  Pokemon.swift
//  Pokedex
//
//  Created by Gayan Jayasundara on 2017-01-11.
//  Copyright © 2017 Gayan Jayasundara. All rights reserved.
//

import Alamofire
import Foundation

class Pokemon {
    fileprivate var _name: String!
    fileprivate var _pokedexId: Int!
    fileprivate var _description: String!
    fileprivate var _type: String!
    fileprivate var _defence: String!
    fileprivate var _height: String!
    fileprivate var _weight: String!
    fileprivate var _attack: String!
    fileprivate var _nextEvolutionName: String!
    fileprivate var _nextEvolutionText: String!
    fileprivate var _nextEvolutionId: String!
    fileprivate var _nextEvolutionLevel: String!
    fileprivate var _pokemonURL: String!
    
    var name: String {
        if _name == nil {
            _name = ""
        }
        return _name
    }
    
    var pokedexId: Int {
        if _pokedexId == nil {
            _pokedexId = 0
        }
        return _pokedexId
    }
    
    var nextEvolutionText: String {
        if _nextEvolutionText == nil {
            _nextEvolutionText = ""
        }
        return _nextEvolutionText
    }
    
    var nextEvolutionName: String {
        if _nextEvolutionName == nil {
            _nextEvolutionName = ""
        }
        return _nextEvolutionName
    }
    
    var nextEvolutionId: String {
        if _nextEvolutionId == nil {
            _nextEvolutionId = ""
        }
        return _nextEvolutionId
    }
    
    var nextEvolutionLevel: String {
        if  _nextEvolutionLevel == nil {
            _nextEvolutionLevel = ""
        }
        return _nextEvolutionLevel
    }
    
    var attack: String {
        if _attack == nil {
            _attack = ""
        }
        return _attack
    }
    
    var weight: String {
        if _weight == nil {
            _weight = ""
        }
        return _weight
    }
    
    var height: String {
        if _height == nil {
            _height = ""
        }
        return _height
    }
    
    var defence: String {
        if _defence == nil {
            _defence = ""
        }
        return _defence
    }
    
    var type: String {
        if _type == nil {
            _type = ""
        }
        return _type
    }
    
    var description: String {
        if _description == nil {
            _description = ""
        }
        return _description
    }
    
    init(name:String, pokedexId:Int) {
        self._name = name
        self._pokedexId = pokedexId
        
        self._pokemonURL = "\(URL_BASE)\(URL_POKEMON)\(self.pokedexId)/"
    }
    
    func downloadPokemonDetails(completed: @escaping DownloadComplete) {
        Alamofire.request(_pokemonURL).responseJSON { (response) in
            if let dict = response.result.value as? Dictionary<String, AnyObject> {
                if let weight = dict["weight"] as? String {
                    self._weight = weight
                }
                
                if let height = dict["height"] as? String {
                    self._height = height
                }
                
                if let attack = dict["attack"] as? Int {
                    self._attack = "\(attack)"
                }
                
                if let defense = dict["defense"] as? Int {
                    self._defence = "\(defense)"
                }
                
                if let types = dict["types"] as? [Dictionary<String, String>] , types.count > 0  {
                    if let name = types[0]["name"] {
                        self._type = name.capitalized
                    }
                    if types.count > 1 {
                        for x in 1..<types.count {
                            if let name = types[x]["name"] {
                                self._type! += "/\(name.capitalized)"
                            }
                        }
                    }
                } else {
                    self._type = ""
                }
                
                if let decriptionArray = dict["descriptions"] as? [Dictionary<String, String>] , decriptionArray.count > 0 {
                    if let url = decriptionArray[0]["resource_uri"] {
                        let descriptionUrl = URL_BASE.appending(url)
                        Alamofire.request(descriptionUrl).responseJSON(completionHandler: { (response) in
                            if let descDict = response.result.value as? Dictionary<String, AnyObject> {
                                if let descrption = descDict["description"] as? String {
                                    self._description = descrption.replacingOccurrences(of: "POKMON", with: "Pokemon")
                                }
                            }
                            completed()
                        })
                    }
                }
                
                if let evolutionArray = dict["evolutions"] as? [Dictionary<String, AnyObject>], evolutionArray.count > 0 {
                    if let nextEvo = evolutionArray[0]["to"] as? String{
                        if nextEvo.range(of: "mega") == nil {
                            self._nextEvolutionName = nextEvo
                        }
                    }
                    
                    if let resource_uri = evolutionArray[0]["resource_uri"] as? String {
                        let newString = resource_uri.replacingOccurrences(of: "/api/v1/pokemon/", with: "")
                        let nextEvoId = newString.replacingOccurrences(of: "/", with: "")
                        self._nextEvolutionId = nextEvoId
                    }
                    
                    if let levelExist = evolutionArray[0]["level"] {
                        if let level = levelExist as? Int {
                            self._nextEvolutionLevel = "\(level)"
                        }
                        
                    } else {
                        self._nextEvolutionLevel = ""
                    }
                }
                
                print(self.nextEvolutionId)
                print(self.nextEvolutionName)
                print(self.nextEvolutionLevel)
            }
            completed()
        }
    }
}
