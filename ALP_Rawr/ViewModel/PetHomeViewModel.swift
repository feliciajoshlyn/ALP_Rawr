//
//  PetViewModel.swift
//  ALP_Rawr
//
//  Created by Dapur Gili on 23/05/25.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import WatchConnectivity

class PetHomeViewModel: ObservableObject{
    // Published variables, yang akan digunakan di View
    @Published var pet: PetModel = PetModel()
    @Published var currEmotion: String = "Happy"
    @Published var icon: String = "happybadge"
    @Published var hasFetchData: Bool = false
    
    //PetService untuk function-function yang connect ke Realtime DB
    private let petService: PetService

    //User untuk menerima dan nanti pakai atribut user yang lagi login
    private var user: User?
    private var userUid: String?
    
    //Timer untuk menjalankan function yang akan melakukan pengecekan secara berkala
    private var timer: Timer?
    
    //Session untuk connect ke watch
    
    //PetService diinject melalui init
    init(petService: PetService = LivePetService()) {
        self.petService = petService
    }
    
    //Saat ViewModel tidak dipakai lagi, timernya dimatikan
    deinit {
        timer?.invalidate()
    }
    
//    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
//        if activationState == .activated && session.isReachable {
//            self.sendPetToWatch(pet: self.pet)
//        }
//    }
//    
//    func sessionDidBecomeInactive(_ session: WCSession) {
//        self.savePet()
//    }
//    
//    func sessionDidDeactivate(_ session: WCSession) {
//        self.savePet()
//    }
    
//    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
//        print("📱 iOS received message: \(message)")
//        DispatchQueue.main.async {
//            print("Processing message on main thread")
//            print("Received message: \(message)")
//            var interactionType = InteractionType.feeding
//            
//            switch message["type"] as! String {
//            case "feeding":
//                interactionType = InteractionType.feeding
//            case "petting":
//                interactionType = InteractionType.petting
//            default:
//                break
//            }
//            
//            self.applyInteraction(interactionType)
//            print("Applied interaction, new hunger level: \(self.pet.hunger)")
//        }
//                
//        self.sendPetToWatch(pet: self.pet)
//    }
    
    //Function untuk mengambil pet data, tidak bisa dijalankan di init karena membutuhkan user sudah login, sementara ViewModel ini dibuat bersamaan
    // dengan AuthViewModel, supaya bisa diakses di view-view lain pada aplikasi, dan saat AuthViewModel pertama dibuat, bisa saja belum ada user yang login
    func fetchPetData(currentUserId: String? = Auth.auth().currentUser?.uid) {
        
        //Supaya gak fetch data berulang kali sebelum data disimpan di DB, nanti overwrite perubahan yang terjadi di app ini
        guard !hasFetchData else {
            print("Already fetched data, returning early")
            return
        }
        
        //Kalau sebelumnya hasFetchData == false, akan diset jadi true di sini
        hasFetchData = true
        
        //Error handling kalau semisal saja user kosong, petnya diset jadi default
        guard let userId = currentUserId else {
            print("No user ID found, setting up default pet")
            setupDefaultPet()
            self.startTimer()
            return
        }
        
        
        //Panggil function fetchPet dari FB Realtime DB dari PetService
        petService.fetchPet(for: userId) { [weak self] pet in
            DispatchQueue.main.async{
                if let fetchedPet = pet {
                    //PetService akan return Pet yang diambil kalau berhasil, trs dimasukkan variabel pet-nya ViewModel
                    self?.pet = fetchedPet
                    WatchConnectivityManager.shared.sendPetToWatch(pet: fetchedPet)
                } else {
                    //Kalau gagal, setup default pet
                    self?.setupDefaultPet()
                }
            }
        }
        
        //Start timernya untuk periodic checking
        self.startTimer()
    }

    //Function buat bikin default pet
    private func setupDefaultPet(){
        self.pet = PetModel(
            name: "Default",
            hp: 100.0,
            hunger: 100.0,
            isHungry: false,
            bond: 0,
            lastFed: Date(),
            lastPetted: Date(),
            lastWalked: Date(),
            lastShower: Date(),
            lastChecked: Date(),
            currMood: "Happy",
            emotions: [
                "Happy":PetEmotionModel(
                    name: "Happy",
                    level: 100.0,
                    limit: 40.0,
                    priority: 1,
                    icon: "happybadge"
                ),
                "Sad":PetEmotionModel(name: "Sad", level: 0.0, limit: 50.0, priority: 2, icon: "sadbadge"),
                "Angry":PetEmotionModel(name: "Angry", level: 0.0, limit: 70.0, priority: 3, icon: "angrybadge"),
                "Bored":PetEmotionModel(name: "Bored", level: 0.0, limit: 60.0, priority: 4, icon: "boredbadge"),
                "Fear":PetEmotionModel(name: "Fear", level: 0.0, limit: 80.0, priority: 5, icon: "fearbadge")
            ],
            userId: ""
        )
    }
    
    //Function kalau ada interaksi dengan petnya yang akan mengubah level dari emosi pet
    //Value perubahan sudah diset di InteractionType untuk masing-masing interaction dan masing-masing mood/emotion
    func applyInteraction(_ type: InteractionType) {
        guard let changes = InteractionEffect.effects[type] else { return }

        for (emotionName, num) in changes {
            if var emotion = pet.emotions[emotionName] {
                emotion.apply(change: num)
                pet.emotions[emotionName] = emotion
            }
        }
        
        //Tambahan yang perlu diset sesudah ada interaksi tertentu
        if type == .petting {
            pet.lastPetted = Date()
        } else if type == .feeding {
            pet.lastFed = Date()
            pet.hunger = min(100.0, pet.hunger + 1.0)
            print("Difeed dari watch untuk \(pet.name)")
        } else if type == .showering {
            pet.lastShower = Date()
        }
        
        self.checkCurrEmotion()
    }
    
    //Function untuk cek emotion/mood dari petnya skrng apa berdasarkan level dari emotion tersebut
    //Setiap emotion ada limitnya yang berarti kalau level > limit tersebut artinya pet sedang merasakan mood tersebut
    //Kalau ada emotion yang sama2 melebihi limitnya, akan dicek dari priority
    func checkCurrEmotion(){
        let activeEmotions = pet.emotions.filter { $0.value.level >= $0.value.limit }
        
        //Set default kalau gaada emotion yang aktif jadi happy
        if activeEmotions.isEmpty {
            self.currEmotion = "Happy"
            self.icon = "happybadge"
            return
        }
        
        let sortedEmotions = activeEmotions.sorted {
            return $0.value.priority > $1.value.priority
        }
        
        if let topEmotion = sortedEmotions.first {
            self.currEmotion = topEmotion.key
            self.icon = topEmotion.value.icon
        } else {
            self.currEmotion = "Happy"
            self.icon = "happybadge"
        }
    }
    
    //Function untuk bantu round decimal value jd "places" angka di belakang koma
    func roundToDecimal(_ value: Double, places: Int) -> Double {
        let factor = pow(10.0, Double(places))
        return (value * factor).rounded() / factor
    }
    
    //Function untuk cek kondisi petnya
    func updatePetStatusPeriodically() {
        let now = Date()
        
        //Akan melakukan pengecekan berdasarkan sudah lewat berapa lama dari terakhir kali dicek
        let lastChecked = pet.lastChecked
        let timePassed = now.timeIntervalSince(lastChecked) // bentuknya dalam detik
        
        guard timePassed >= 60 else { return } // cuman diupdate kalau sudah lewat 1 menit
        
        let minutesPassed: Double = roundToDecimal(timePassed / 60.0, places: 1) // perubahan waktu td diubah jd menit
        
        // Ngurangi hunger, kalau udh lewat 3 menit = dikurangi 1
        let hungerDecrease: Double = roundToDecimal(minutesPassed / 3.0, places: 1)
        pet.hunger = max(0.0, pet.hunger - hungerDecrease)
        pet.isHungry = pet.hunger < 40.0

        // Hitung berapa jam sudah berlalu sejak dikasih makan, dielus, diajak jalan2, dimandiin
        let hoursSinceFed = now.timeIntervalSince(pet.lastFed) / 3600
        let hoursSincePetted = now.timeIntervalSince(pet.lastPetted) / 3600
        let hoursSinceWalked = now.timeIntervalSince(pet.lastWalked) / 3600
        let hoursSinceShowered = now.timeIntervalSince(pet.lastShower) / 3600

        // Ubah HP berdasarkan status lapar
        if pet.hunger >= 50.0 {
            // Nambah HP nya kalau dia kenyang (gk lapar)
            let hpIncrease: Double = roundToDecimal(minutesPassed / 5.0, places: 1)
            pet.hp = min(100.0, pet.hp + hpIncrease)
        } else {
            // HP berkurang kalau kelaparan
            if pet.hunger < 15.0 { // HP cuman mulai berkurang kalau kelaparan yang parah
                let hpDecrease = roundToDecimal(minutesPassed / 8, places: 3)  // Saat hunger di bawah 15, untuk setiap 8 menit nanti HP akan berkurang
                pet.hp = max(1.0, pet.hp - hpDecrease)
            }
            
            // Penalti kalau, gk diajak interaksi lama banget
            var neglectPenalty: Double = 0.0
            if hoursSinceFed > 8.0 { neglectPenalty += 1.0 }
            if hoursSincePetted > 12.0 { neglectPenalty += 1.0 }
            if hoursSinceWalked > 16.0 { neglectPenalty += 1.0 }
            if hoursSinceShowered > 30.0 { neglectPenalty += 1.0 }
            
            //Kalau udah diabaikan lama-lama nanti HP berkurang
            if neglectPenalty > 0.0 {
                let hpDecrease: Double = roundToDecimal((minutesPassed * neglectPenalty) / 15, places: 2) // Gradual penalty based on neglect
                pet.hp = max(1.0, pet.hp - hpDecrease)
                
            }
        }

        // Update emotion levels berdasarkan lama waktu gk diajak iteraksi
        for (name, emotion) in pet.emotions {
            var updated = emotion
            
            switch name {
            case "Sad":
                if hoursSincePetted > 6.0 {
                    // Tambah sedih kalau udah lama gk dielus
                    let increase = min(3.0, roundToDecimal(minutesPassed / 10.0, places: 2)) // Max 3 points per update
                    updated.level = min(100.0, updated.level + increase)
                } else {
                    // Kalau udh dielus bakal berkurang kesedihannya
                    let decrease: Double = roundToDecimal(minutesPassed / 15.0, places: 2)
                    updated.level = max(0.0, updated.level - decrease)
                }
                
            case "Angry":
                if pet.hunger < 30.0 {
                    // Kalau laper marah
                    let increase: Double = min(2.0, roundToDecimal(minutesPassed / 8.0, places: 3))
                    updated.level = min(100.0, updated.level + increase)
                } else if pet.hunger > 60.0 {
                    // Kalau udh kenyang berkurang amarahnya
                    let decrease: Double = roundToDecimal(minutesPassed / 12.0, places: 3)
                    updated.level = max(0.0, updated.level - decrease)
                }
                
            case "Bored":
                if hoursSinceWalked > 8.0 {
                    // Bosen kalau lama gk diajak jalan2
                    let increase: Double = min(4.0, roundToDecimal(minutesPassed / 6.0, places: 3)) // Boredom builds faster
                    updated.level = min(100.0, updated.level + increase)
                } else {
                    // Habis jalan, level bosennya berkurang
                    let decrease: Double = roundToDecimal(minutesPassed / 10.0, places: 3)
                    updated.level = max(0.0, updated.level - decrease)
                }
                
            case "Fear":
                if hoursSinceShowered > 48.0 { // Tambah takut kalau udh lama kotor
                    let increase: Double = min(1.0, roundToDecimal(minutesPassed / 20.0, places: 3))
                    updated.level = min(100.0, updated.level + increase)
                } else {
                    // Rasa takut akan berkurang seiring berjalannya waktu
                    let decrease: Double = roundToDecimal(minutesPassed / 25.0, places: 3)
                    updated.level = max(0, updated.level - decrease)
                }
                
            case "Happy":
                // Lvl kebahagiaan bergantung ke tingkat care usernya
                let overallCare = (pet.hunger + pet.hp) / 2
                
                if overallCare > 70 {
                    // Kalau carenya bagus meningkat happinessnya
                    let increase: Double = roundToDecimal(minutesPassed / 8.0, places: 3)
                    updated.level = min(100.0, updated.level + increase)
                } else if overallCare < 40.0 {
                    // Kalau diabaikan happiness berkurang
                    let decrease: Double = roundToDecimal(minutesPassed / 6.0, places: 3)
                    updated.level = max(0.0, updated.level - decrease)
                }
                // Kalau tingkat carenya gk terlalu tinggi/rendah, dibiarkan
                
            default:
                break
            }
            
            //diupdate berdasarkan nama emotionnya
            pet.emotions[name] = updated
        }

        //update terakhir dicek kapan
        self.pet.lastChecked = now
        //cek emosi ulang
        self.checkCurrEmotion()
    }
    
    //Function simpanan buat kalau mau testing yang durasinya lebih cepat
//    func updatePetStatusPeriodicallyFaster() {
//        let now = Date()
//        let lastChecked = pet.lastChecked
//        let timePassed = now.timeIntervalSince(lastChecked) // in seconds
//        
//        guard timePassed >= 60 else { return } // Only update if at least 1 minute has passed
//        
//        let minutesPassed = Double(timePassed / 60.0)
//        
//        // Adjust Hunger (every minute decreases by 1)
//        pet.hunger = max(0, pet.hunger - minutesPassed)
//        pet.isHungry = pet.hunger < 40
//
//        // Adjust HP based on lack of interaction
//        let hoursSinceFed = Double(now.timeIntervalSince(pet.lastFed) / 3600.0)
//        let hoursSincePetted = Double(now.timeIntervalSince(pet.lastPetted) / 3600.0)
//        let hoursSinceWalked = Double(now.timeIntervalSince(pet.lastWalked) / 3600.0)
//        let hoursSinceShowered = Double(now.timeIntervalSince(pet.lastShower) / 3600.0)
//
//        // HP decays slightly if hunger is very low or if neglected
//        if pet.hunger < 20.0 {
//            pet.hp = max(0.0, pet.hp - minutesPassed / 2.0)
//        }
//        if hoursSinceFed > 6.0 || hoursSincePetted > 8.0 || hoursSinceWalked > 12.0 || hoursSinceShowered > 24.0 {
//            pet.hp = max(0, pet.hp - minutesPassed / 3.0)
//        }
//
//        // Increase emotion levels based on neglect
//        for (name, emotion) in pet.emotions {
//            var updated = emotion
//            switch name {
//            case "Sad":
//                updated.level = min(100, updated.level + (hoursSincePetted > 8 ? minutesPassed / 3 : 0))
//            case "Angry":
//                updated.level = min(100, updated.level + (hoursSinceFed > 6 ? minutesPassed / 4 : 0))
//            case "Bored":
//                updated.level = min(100, updated.level + (hoursSinceWalked > 12 ? minutesPassed / 2 : 0))
//            case "Fear":
//                updated.level = min(100, updated.level + (hoursSinceShowered > 24 ? minutesPassed / 2 : 0))
//            case "Happy":
//                updated.level = max(0, updated.level - minutesPassed / 2)
//            default:
//                break
//            }
//            pet.emotions[name] = updated
//        }
//
//        pet.lastChecked = now
//        checkCurrEmotion()
//    }
    
    //Function untuk menjalankan function yang mengecek secara berkala
    private func startTimer() {
        timer?.invalidate() // in case it's called twice
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.updatePetStatusPeriodically()
            }
        }
    }
    
    //Panggil PetService buat update data pet ke DB
    //Bakal dilakukan tiap kali logout dan user keluar aplikasi (pencet home)
    func savePet(currentUserId: String? = Auth.auth().currentUser?.uid){
        guard let userId = currentUserId else {
            return
        }
        
        self.updatePetStatusPeriodically()
        self.checkCurrEmotion()
        
        petService.savePet(self.pet, for: userId) { success in
            if success {
                print("Pet saved successfully on app background")
            } else {
                print("Failed to save pet on app background")
            }
        }
    }
    
    //Ambil ulang setelah user keluar aplikasi (cuman leave app bukan logout)
    func refetchPetData(currentUserId: String? = Auth.auth().currentUser?.uid) {
        fetchPetData(currentUserId: currentUserId)
        self.updatePetStatusPeriodically()
        self.checkCurrEmotion()
    }
    
    //Reset view model buat dipakai sm user selanjutnya yang lagi login
    func resetViewModel(){
        currEmotion = "Happy"
        icon = "happybadge"
        hasFetchData = false
        timer?.invalidate()
    }
    
//    func sendPetToWatch(pet: PetModel) {
//        guard WCSession.default.isReachable else {
//            print("Watch is not reachable.")
//            return
//        }
//
//        do {
//            let encoder = JSONEncoder()
//            encoder.dateEncodingStrategy = .iso8601 // Or `.millisecondsSince1970` — just match on both ends
//            let data = try encoder.encode(pet)
//            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
//                WCSession.default.sendMessage(["petData": json], replyHandler: nil) { error in
//                    print("Error sending petData: \(error.localizedDescription)")
//                }
//            }
//        } catch {
//            print("Failed to encode PetModel: \(error)")
//        }
//    }
}
