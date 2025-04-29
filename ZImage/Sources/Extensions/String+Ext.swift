//
//  String+Ext.swift
//  ZImage
//
//  Created by Olzhas S
//

import CryptoKit
import Foundation

extension String {
    func sha256() -> String {
        let digest = SHA256.hash(data: Data(self.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
