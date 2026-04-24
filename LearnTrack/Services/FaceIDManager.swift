//
//  FaceIDManager.swift
//  LearnTrack
//
//  Created by COBSCCOMP242P-028 on 2026-04-24.
//

import Foundation
import LocalAuthentication

class FaceIDManager {
    static let shared = FaceIDManager()
    
    func authenticate(completion: @escaping (Bool, String?) -> Void) {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Unlock LearnTrack to access your study data."
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authError in
                DispatchQueue.main.async {
                    if success {
                        completion(true, nil)
                    } else {
                        completion(false, authError?.localizedDescription ?? "Authentication failed.")
                    }
                }
            }
        } else {
            // Biometry not available or not configured
            DispatchQueue.main.async {
                completion(false, "Face ID / Touch ID not available.")
            }
        }
    }
}
