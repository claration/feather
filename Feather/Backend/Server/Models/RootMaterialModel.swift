//
//  RootMaterialModel.swift
//  Feather
//
//  Created by Nagata Asami on 17/9/26.
//

import X509

struct RootMaterialModel {
	let privateKey: X509.Certificate.PrivateKey
	let certificate: X509.Certificate
	let der: Data
}
