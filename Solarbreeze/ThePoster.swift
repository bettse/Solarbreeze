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

enum Variants : UInt8 {
    case giants = 0x01
    case variant = 0x02
    case legendary = 0x03
    case eventExclusive = 0x04
    case swapForce = 0x05
    case led = 0x06
    case trapTeam = 0x09
    case easter = 0x0D
    case xmasNY = 0x0E
    case instant = 0x0F
    case eonsElite = 0x10
    case gotD = 0x11
    case stone = 0x12
    case sparkle = 0x13
    case snowPurple = 0x14
    case halloween = 0x15
    case slimeBimetal = 0x16
    case metallicGreen = 0x17
    case metallicGreen2 = 0x18
    case silverGreen = 0x19
    case crystalwRed = 0x1A
    case crystalwGreen = 0x1B
    case crystalwPurple = 0x1C
    case crystal = 0x1D
}

enum Element : UInt {
    case none, magic, earth, water, fire, tech, undead, life, air, dark, light
}

enum Series : UInt {
    case none, spyrosAdventure, giants, swapForce, trapTeam, superChargers, imaginators
    var description : String {
        get {
            switch(self) {
            case .none:
                return "None"
            case .spyrosAdventure:
                return "Spyro's Adventure"
            case .giants:
                return "Giant"
            case .swapForce:
                return "SWAP Force"
            case .trapTeam:
                return "Trap Team"
            case .superChargers:
                return "SuperChargers"
            default:
                return ""
            }
        }
    }

}

//Adventure Packs are categorized as MagicItems.
enum Role : UInt {
    case none, skylander, giant, swapForce, trapMaster, superCharger, vehicle, sidekick, mini, magicItem
    var description : String {
        get {
            switch(self) {
            case .none:
                return "None"
            case .skylander:
                return "Skylander"
            case .giant:
                return "Giant"
            case .swapForce:
                return "SWAP Force"
            case .trapMaster:
                return "Trap Master"
            case .superCharger:
                return "SuperCharger"
            case .vehicle:
                return "Vehicle"
            case .sidekick:
                return "Sidekick"
            case .mini:
                return "Mini"
            case .magicItem:
                return "Item"        
            }
        }
    }
}

class Model {
    let id : UInt
    var flags : UInt16 = 0
    
    var name : String {
        //TODO: Enhance this to account for the value of the flags, like the different trap names
        //and Alter Egos
        return ThePoster.getName(id)
    }
    
    var role : Role {
        //This is very rough
        switch(id) {
        case 0x0...0x20:
            return .skylander
        case 0x64, 0x66, 0x68, 0x6A,
             0x6C, 0x6E, 0x70, 0x72:
            return .giant
        case 0x64...0x73: //Non-Giants
            return .skylander
        case 0xC8...0xCF,
             0xD0...0xD1,
             0xD2...0xDC, //Traps
             0xE6...0xE9,
             0x12C...0x130, //Adventure packs
             0x131...0x134: //TT Adventure packs
            return .magicItem
        case 0x194...0x1AE: //Legends
            return .skylander
        //TrapTeam
        case 0x1C2, 0x1C3, //Air
             0x1C6, 0x1C7, //Earth
             0x1CA, 0x1CB, //Fire
             0x1CE, 0x1CF, //Water
             0x1D2, 0x1D3, //Magic
             0x1D6, 0x1D7, //Tech
             0x1DA, 0x1DB, //Lift
             0x1DE, 0x1DF, //Undead
             0x1E2, //Light
             0x1E4: //Dark
            return .trapMaster
        case 0x1C2...0x1F5:
            return .skylander
        case 0x1F6...0x1FE:
            return .mini
        case 0x202...0x21F:
            return .mini
        case 0x3E8...0xC84:
            return .swapForce
        case 0xC94...0xCA9:
            return .vehicle
        case 0xD48...0xD64:
            return .superCharger
        case 0xDAC...0xDAF: //Trophies
            return .magicItem
        default:
            return .none
        }
    }
    
    var series : Series {
        switch(id) {
        case 0x0...0x20:
            return .spyrosAdventure
        case 0x64...0x73:
            return .giants
        case 0xC8...0xCF:
            return .spyrosAdventure
        case 0xD0...0xD1:
            return .giants
        case 0xD2...0xDC: //Traps
            return .trapTeam
        case 0xE6...0xE9:
            return .trapTeam
        case 0x12C...0x130: //Adventure packs
            return .spyrosAdventure
        case 0x131...0x134: //TT Adventure packs
            return .trapTeam
        case 0x194...0x1AE: //Legends
            return .spyrosAdventure
        case 0x1C2...0x1FE:
            return .trapTeam
        case 0x21C...0x21F:
            return .giants
        case 0x3E8...0xC84:
            return .swapForce
        case 0xC94...0xCA9:
            return .superChargers
        case 0xCE4...0xCE7:
            return .swapForce
        case 0xD48...0xD64:
            return .superChargers
        case 0xDAC...0xDAF: //Trophies
            return .superChargers
        default:
            return .none
        }
    }
    
    var element : Element {
        switch(id) {
        case 0x00...0x03, 0x64, 0x65, 0x1C2...0x1C5:
            return .air
        case 0x04...0x07, 0x66, 0x67, 0x1C6...0x1C9:
            return .earth
        case 0x08...0x0b, 0x68, 0x69, 0x1CA...0x1CD:
            return .fire
        case 0x0c...0x0f, 0x6A, 0x6B, 0x1CE...0x1D1:
            return .water
        case 0x10...0x12, 0x6C, 0x6D, 0x1D2...0x1D5:
            return .magic
        case 0x13...0x16, 0x6E, 0x6F, 0x1D6...0x1D9:
            return .tech
        case 0x17:
            return .magic
        case 0x18...0x1B, 0x70, 0x71, 0x1DA...0x1DD:
            return .life
        case 0x1C:
            return .magic
        case 0x1D...0x20, 0x72, 0x73, 0x1DE...0x1E1:
            return .undead
        //Legend
        case 0x194:
            return .earth
        case 0x1A0:
            return .magic
        case 0x1A3:
            return .tech
        case 0x1AE:
            return .undead
        case 0x1C2...0x1C5:
            return .air
        case 0x1E2...0x1E3:
            return .light
        case 0x1E4...0x1E5:
            return .dark
        case 0x1F9:
            return .earth
        case 0x1FA:
            return .air
        case 0x1FB:
            return .fire
        case 0x1FC:
            return .air
        case 0x1FD:
            return .fire
        case 0x1FE:
            return .tech
        case 0x202:
            return .water
        case 0x207:
            return .tech
        case 0x20E:
            return .life
        case 0x21C:
            return .life
        case 0x21D:
            return .water
        case 0x21E:
            return .magic
        case 0x21F:
            return .undead
        //XX: Skiping Some
        //Vehicles
        case 0xC94: return .air
        case 0xC95: return .undead
        case 0xC96: return .water
        case 0xC97: return .fire
        case 0xC98: return .fire
        case 0xC99: return .earth
        case 0xC9A: return .earth
        case 0xC9B: return .undead
        case 0xC9C: return .life
        case 0xC9F: return .water
        case 0xCA0: return .air
        case 0xCA1: return .air
        case 0xCA2: return .tech
        case 0xCA3: return .tech
        case 0xCA4: return .light
        case 0xCA5: return .dark
        case 0xCA6: return .magic
        case 0xCA7: return .magic
        case 0xCA8: return .tech
        case 0xCA9: return .life
        //Superchargers
        case 0xD48: return .undead
        case 0xD49: return .tech
        case 0xD4A: return .magic
        case 0xD4E: return .air
        case 0xD53: return .earth
        case 0xD54: return .fire
        case 0xD55: return .air
        case 0xD56: return .tech
        case 0xD57: return .life
        case 0xD58: return .earth
        case 0xD59: return .undead
        case 0xD5C: return .magic
        case 0xD5D: return .fire
        case 0xD5E: return .water
        case 0xD5F: return .life
        case 0xD60: return .fire
        case 0xD61: return .water
        case 0xD62: return .light
        case 0xD63: return .dark
        case 0xD64: return .life
        default: return .none
        }
    }

 
    var color : UIColor {
        switch (self.element) {
        case .none: return UIColor.gray
        case .magic: return UIColor.purple
        case .earth: return UIColor.brown
        case .water: return UIColor.blue
        case .fire: return UIColor.red
        case .tech: return UIColor.orange
        case .undead: return UIColor.gray
        case .life: return UIColor.green
        case .air: return UIColor.cyan
        case .dark: return UIColor.black
        case .light: return UIColor.yellow
        }
    }
    
    var symbol : String {
        switch (self.element) {
        case .none: return " "
        case .magic: return "✨"
        case .earth: return "🌎"
        case .water: return "💧"
        case .fire: return "🔥"
        case .tech: return "⚙️"
        case .undead: return "💀"
        case .life: return "🎄"
        case .air: return "🌀"
        case .dark: return "🌑"
        case .light: return "☀️"
        }
    }
    
    var defaultFlags : UInt16 {
        get {
            var c : UInt16 = 0
            var d : UInt16 = 0
            switch (series) {
            case .giants:
                d = 0x10
            case .swapForce:
                d = 0x20
            case .trapTeam:
                d = 0x30
            case .superChargers:
                d = 0x40
            default:
                c = 0
                d = 0
            }
            
            //D is shifted up because of endian
            return (d << 8) | c
        }
    }
    
    
    init(id: UInt, flags: UInt16 = 0) {
        self.id = id
        if (flags == 0) {
            self.flags = defaultFlags
        } else {
            self.flags = flags
        }
    }
    
    /*
    func copyWithZone(zone: NSZone) -> Model {
        return Model(id: self.id)
    }
    */
}

class ThePoster {
    static var models : [Model] = {
        return names.keys.map{return Model(id: $0)}.sorted(by: { $0.id < $1.id })
    }()
    
    static func getName(_ id: UInt) -> String {
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
        0xD4E : "Stormblade",
        0xD53 : "Smash It",
        0xD54 : "Spitfire",
        0xD55 : "Hurricane Jet-Vac",
        0xD56 : "Double Dare Trigger Happy",
        0xD57 : "Super Shot Stealth Elf",
        0xD58 : "Shark Shooter Terrafin",
        0xD59 : "Bone Bash Roller Brawl",
        0xD5C : "Big Bubble Pop Fizz",
        0xD5D : "Lava Lance Eruptor",
        0xD5E : "Deep Dive Gill Grunt",
        0xD5F : "Turbo Charge Donkey Kong",
        0xD60 : "Hammer Slam Bowser",
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
