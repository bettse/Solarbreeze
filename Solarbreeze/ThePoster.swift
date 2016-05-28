//
//  ThePoster.swift
//  Solarbreeze
//
//  Created by Eric Betts on 5/28/16.
//  Copyright © 2016 Eric Betts. All rights reserved.
//

import Foundation
import UIKit

/*
 ThePoster is a way of looking up token data.
 It helps associate internal represetations from the token 
 data to the real world name and characteristics. 
 Like how you might use a real world poster to look 
 at a list of the figures, their pictures, or stats
 */

class Model {
    var id : UInt
    enum Element : UInt {
        case None, Magic, Earth, Water, Fire, Tech, Undead, Life, Air, Dark, Light
    }
    
    var name : String {
        return ThePoster.getName(id)
    }
    
    /*
    var color : UIColor {
        switch (self.element) {
        case None: return UIColor.whiteColor()
        case Magic: return UIColor.purpleColor()
        case Earth: return UIColor.brownColor()
        case Water: return UIColor.blueColor()
        case Fire: return UIColor.redColor()
        case Tech: return UIColor.orangeColor()
        case Undead: return UIColor.grayColor()
        case Life: return UIColor.greenColor()
        case Air: return UIColor.cyanColor()
        case Dark: return UIColor.blackColor()
        case Light: return UIColor.yellowColor()
        }
    }
    */
    
    init(id: UInt) {
        self.id = id
    }
    
    /*
    func copyWithZone(zone: NSZone) -> Model {
        return Model(id: self.id)
    }
    */
}

class ThePoster {
    static var models : [Model] = {
        return names.keys.map{return Model(id: $0)}.sort({ $0.id < $1.id })
    }()
    
    static func getName(id: UInt) -> String {
        return names.get(id, defaultValue: "<\(id)>")
    }
    
    static let names : [UInt:String] = [
    
    0x0 : "Whirlwind",
    0x1 : "Sonic Boom",
    0x2 : "Warnado",
    0x3 : "Lightning Rod",
    0x4 : "Bash",
    0x5 : "Terrafin",
    0x6 : "Dino-Rang",
    0x7 : "Prism Break",
    0x8 : "Sunburn",
    0x9 : "Eruptor",
    0xA : "Ignitor",
    0xB : "Flameslinger",
    0xC : "Zap",
    0xD : "Wham-Shell",
    0xE : "Gill Grunt",
    0xF : "Slam Bam",
    0x10 : "Spyro",
    0x11 : "Voodood",
    0x12 : "Double Trouble",
    0x13 : "Trigger Happy",
    0x14 : "Drobot",
    0x15 : "Drill Sergeant",
    0x16 : "Boomer",
    0x17 : "Wrecking Ball",
    0x18 : "Camo",
    0x19 : "Zook",
    0x1A : "Stealth Elf",
    0x1B : "Stump Smash",
    0x1C : "Spyro - Dark",
    0x1D : "Hex",
    0x1E : "Chop Chop",
    0x1F : "Ghost Roaster",
    0x20 : "Cynder",
    0x64 : "Jet-Vac",
    0x65 : "Swarm",
    0x66 : "Crusher",
    0x67 : "Flashwing",
    0x68 : "Hot Head",
    0x69 : "Hot Dog",
    0x6A : "Chill",
    0x6B : "Thumpback",
    0x6C : "Pop Fizz",
    0x6D : "Ninjini",
    0x6E : "Bouncer",
    0x6F : "Sprocket",
    0x70 : "TreeRex",
    0x71 : "Shroomboom",
    0x72 : "Eye Brawl",
    0x73 : "Fright Rider",
    0xC8 : "Anvil Rain",
    0xC9 : "Hidden Treasure",
    0xCA : "Healing Elixir",
    0xCB : "Ghost Swords",
    0xCC : "Time Twister",
    0xCD : "Sky-Iron Shield",
    0xCE : "Winged Boots",
    0xCF : "Sparx",
    0xD0 : "Dragonfire Cannon",
    0xD1 : "Scorpion Striker",
    0xD2 : "Trap - Magic",
    0xD3 : "Trap - Water",
    0xD4 : "Trap - Air",
    0xD5 : "Trap - Undead",
    0xD6 : "Trap - Tech",
    0xD7 : "Trap - Fire",
    0xD8 : "Trap - Earth",
    0xD9 : "Trap - Life",
    0xDA : "Trap - Light",
    0xDB : "Trap - Dark",
    0xDC : "Trap - Kaos",
    0xE6 : "Hand of Fate",
    0xE7 : "Piggy Bank",
    0xE8 : "Rocket Ram",
    0xE9 : "Teaky Sneaky",
    0x12C : "Dragon's Peak",
    0x12D : "Empire of Ice",
    0x12E : "Pirate Seas",
    0x12F : "Darklight Crypt",
    0x130 : "Volcanic Vault",
    0x131 : "Mirror of Mystery",
    0x132 : "Nightmare Express",
    0x133 : "Sunspire Scraper",
    0x134 : "Midnight Museum",
    0x194 : "Bash - Legend",
    0x1A0 : "Spyro - Legend",
    0x1A3 : "Trigger Happy - Legend",
    0x1AE : "Chop Chop - Legend",
    0x1C2 : "Gusto",
    0x1C3 : "Thunderbolt",
    0x1C4 : "Fling Kong",
    0x1C5 : "Blades",
    0x1C6 : "Wallop",
    0x1C7 : "Headrush",
    0x1C8 : "Fist Bump",
    0x1C9 : "Rocky Roll",
    0x1CA : "Wildfire",
    0x1CB : "Ka-Boom",
    0x1CC : "Trailblazer",
    0x1CD : "Torch",
    0x1CE : "Snapshot",
    0x1CF : "Lobstar",
    0x1D0 : "Flip Wreck",
    0x1D1 : "Echo",
    0x1D2 : "Blastermind",
    0x1D3 : "Enigma",
    0x1D4 : "Deja Vu",
    0x1D5 : "Cobra Cadabra",
    0x1D6 : "Jawbreaker",
    0x1D7 : "Gearshift",
    0x1D8 : "Chopper",
    0x1D9 : "Treadhead",
    0x1DA : "Bushwhack",
    0x1DB : "Tuff Luck",
    0x1DC : "Food Fight",
    0x1DD : "High Five",
    0x1DE : "Krypt King",
    0x1DF : "Short Cut",
    0x1E0 : "Bat Spin",
    0x1E1 : "Funny Bones",
    0x1E2 : "Knight Light",
    0x1E3 : "Spotlight",
    0x1E4 : "Knight Mare",
    0x1E5 : "Blackout",
    0x1F6 : "Bop",
    0x1F7 : "Spry",
    0x1F8 : "Hijinx",
    0x1F9 : "Terrabite",
    0x1FA : "Breeze",
    0x1FB : "Weerupter",
    0x1FC : "Pet Vac",
    0x1FD : "Small Fry",
    0x1FE : "Drobit",
    0x202 : "Gill Runt",
    0x207 : "Trigger Snappy",
    0x20E : "Whisper Elf",
    0x21C : "Barkely",
    0x21D : "Thumpling",
    0x21E : "Minijini",
    0x21F : "Eye Small",
    0x3E8 : "(Boom) Jet",
    0x3E9 : "(Free) Ranger",
    0x3EA : "(Rubble) Rouser",
    0x3EB : "(Doom) Stone",
    0x3EC : "(Blast) Zone",
    0x3ED : "(Fire) Kraken",
    0x3EE : "(Stink) Bomb",
    0x3EF : "(Grilla) Drilla",
    0x3F0 : "(Hoot) Loop",
    0x3F1 : "(Trap) Shadow",
    0x3F2 : "(Magna) Charge",
    0x3F3 : "(Spy) Rise",
    0x3F4 : "(Night) Shift",
    0x3F5 : "(Rattle) Shake",
    0x3F6 : "(Freeze) Blade",
    0x3F7 : "(Wash) Buckler",
    0x7D0 : "Boom (Jet)",
    0x7D1 : "Free (Ranger)",
    0x7D2 : "Rubble (Rouser)",
    0x7D3 : "Doom (Stone)",
    0x7D4 : "Blast (Zone)",
    0x7D5 : "Fire (Kraken)",
    0x7D6 : "Stink (Bomb)",
    0x7D7 : "Grilla (Drilla)",
    0x7D8 : "Hoot (Loop)",
    0x7D9 : "Trap (Shadow)",
    0x7DA : "Magna (Charge)",
    0x7DB : "Spy (Rise)",
    0x7DC : "Night (Shift)",
    0x7DD : "Rattle (Shake)",
    0x7DE : "Freeze (Blade)",
    0x7DF : "Wash (Buckler)",
    0xBB8 : "Scratch",
    0xBB9 : "Pop Thorn",
    0xBBA : "Slobbertooth",
    0xBBB : "Scorp",
    0xBBC : "Fryno",
    0xBBD : "Smolderdash",
    0xBBE : "Bumble Blast",
    0xBBF : "Zoo Lou",
    0xBC0 : "Dune Bug",
    0xBC1 : "Star Strike",
    0xBC2 : "Countdown",
    0xBC3 : "Windup",
    0xBC4 : "Roller Brawl",
    0xBC5 : "Grim Creeper",
    0xBC6 : "Riptide",
    0xBC7 : "Punk Shock",
    0xC80 : "Battle Hammer",
    0xC81 : "Sky Diamond",
    0xC82 : "Platinum Sheep",
    0xC83 : "Groove Machine",
    0xC84 : "UFO Hat",
    0xC94 : "Jet Stream",
    0xC95 : "Tomb Buggy",
    0xC96 : "Reef Ripper",
    0xC97 : "Burn Cycle",
    0xC98 : "Hot Streak",
    0xC99 : "Shark Tank",
    0xC9A : "Thump Truck",
    0xC9B : "Crypt Crusher",
    0xC9C : "Stealth Stinger",
    0xC9D : "?",
    0xC9E : "?",
    0xC9F : "Dive Bomber",
    0xCA0 : "Sky Slicer",
    0xCA1 : "Clown Cruiser",
    0xCA2 : "Gold Rusher",
    0xCA3 : "Shield Striker",
    0xCA4 : "Sun Runner",
    0xCA5 : "Sea Shadow",
    0xCA6 : "Splatter Splasher",
    0xCA7 : "Soda Skimmer",
    0xCA8 : "Barrel Blaster",
    0xCA9 : "Buzz Wing",
    0xCE4 : "Sheep Wreck Island",
    0xCE5 : "Tower of Time",
    0xCE6 : "Fiery Forge",
    0xCE7 : "Arkeyan Crossbow",
    0xD48 : "Fiesta",
    0xD49 : "High Volt",
    0xD4A : "Splat",
    0xD4B : "?",
    0xD4C : "?",
    0xD4D : "?",
    0xD4E : "Stormblade",
    0xD4F : "?",
    0xD50 : "?",
    0xD51 : "?",
    0xD52 : "?",
    0xD53 : "Smash It",
    0xD54 : "Spitfire",
    0xD55 : "Jet-Vac",
    0xD56 : "Trigger Happy",
    0xD57 : "Stealth Elf",
    0xD58 : "Terrafin",
    0xD59 : "Roller Brawl",
    0xD5A : "?",
    0xD5B : "?",
    0xD5C : "Pop Fizz",
    0xD5D : "Eruptor",
    0xD5E : "Gill Grunt",
    0xD5F : "Donkey Kong",
    0xD60 : "Bowser",
    0xD61 : "Dive-Clops",
    0xD62 : "Astroblast",
    0xD63 : "Nightfall",
    0xD64 : "Thrillipede",
    0xDAC : "Sky Trophy",
    0xDAD : "Land Trophy",
    0xDAE : "Sea Trophy",
    0xDAF : "Kaos Trophy"

    ]
}
