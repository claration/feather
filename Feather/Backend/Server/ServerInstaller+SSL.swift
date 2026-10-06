//
//  ServerInstaller+SSL.swift
//  Feather
//
//  Created by samsam on 10/6/26.
//

import Foundation
import Crypto
import SwiftASN1
import X509

extension ServerInstaller {
	static let serverHostname = "feather.localhost"

	@discardableResult 
	static func createServerCert() throws -> (crt: URL, pem: URL) {
		let certificateURL = URL.documentsDirectory.appendingPathComponent("server.crt")
		let privateKeyURL = URL.documentsDirectory.appendingPathComponent("server.pem")
		
		if
			FileManager.default.fileExists(atPath: certificateURL.path), 
			FileManager.default.fileExists(atPath: privateKeyURL.path) 
		{
			return (certificateURL, privateKeyURL)
		}
		
		let root = try rootMaterial()
		let serverPrivateKey = X509.Certificate.PrivateKey(P256.Signing.PrivateKey())
		

		let name = try DistinguishedName {
			CommonName(Self.serverHostname)
		}

		let now = Date()

		let extensions = try X509.Certificate.Extensions {
			Critical(
				BasicConstraints.notCertificateAuthority
			)
			Critical(
				KeyUsage(digitalSignature: true)
			)
			try ExtendedKeyUsage([.serverAuth])
			SubjectAlternativeNames([
				.dnsName(Self.serverHostname),
			])
			SubjectKeyIdentifier(hash: serverPrivateKey.publicKey)
			AuthorityKeyIdentifier(keyIdentifier: SubjectKeyIdentifier(hash: root.certificate.publicKey).keyIdentifier)
		}

		let serverCertificate = try X509.Certificate(
			version: .v3,
			serialNumber: X509.Certificate.SerialNumber(),
			publicKey: serverPrivateKey.publicKey,
			notValidBefore: now,
			notValidAfter: now.addingTimeInterval(60 * 60 * 24 * 365),
			issuer: root.certificate.subject,
			subject: name,
			signatureAlgorithm: .ecdsaWithSHA256,
			extensions: extensions,
			issuerPrivateKey: root.privateKey
		)

		try Data(serverCertificate.serializeAsPEM().pemString.utf8).write(to: certificateURL, options: .atomic)
		try Data(serverPrivateKey.serializeAsPEM().pemString.utf8).write(to: privateKeyURL, options: .atomic)
		
		return (certificateURL, privateKeyURL)
	}
	
	static func rootCertificateDataURL() throws -> URL {
		let root = try rootMaterial()
		let base64 = root.der.base64EncodedString()

		guard let url = URL(
			string: "data:application/x-x509-ca-cert;base64,\(base64)"
		) else {
			throw CocoaError(.fileReadCorruptFile)
		}

		return url
	}

	private static func rootMaterial() throws -> RootMaterialModel {
		let rootPrivateKey = try createRootKey()
		let certificateURL = URL.documentsDirectory.appendingPathComponent("FeatherLocalCA.cer")
		
		if FileManager.default.fileExists(atPath: certificateURL.path) {
			let der = try Data(contentsOf: certificateURL)
			if let certificate = try? X509.Certificate(derEncoded: Array(der)),
				certificate.publicKey == rootPrivateKey.publicKey {
					return RootMaterialModel(privateKey: rootPrivateKey, certificate: certificate, der: der)
			}
		}
		
		let certificate = try createRootCA(key: rootPrivateKey)
		var serializer = DER.Serializer()
		try serializer.serialize(certificate)
		let der = Data(serializer.serializedBytes)
		try der.write(to: certificateURL, options: .atomic)
		return RootMaterialModel(privateKey: rootPrivateKey, certificate: certificate, der: der)
	}
	
	private static func createRootCA(key: X509.Certificate.PrivateKey) throws -> X509.Certificate {
		let name = try DistinguishedName {
			CommonName("Feather Local Root CA")
		}
		let now = Date()
		let extensions = try X509.Certificate.Extensions {
			Critical(
				BasicConstraints.isCertificateAuthority(maxPathLength: nil)
			)
			Critical(
				KeyUsage(keyCertSign: true)
			)
			SubjectKeyIdentifier(hash: key.publicKey)
		}
		
		return try X509.Certificate(
			version: .v3,
			serialNumber: X509.Certificate.SerialNumber(),
			publicKey: key.publicKey,
			notValidBefore: now,
			notValidAfter: now.addingTimeInterval(60 * 60 * 24 * 365 * 10),
			issuer: name,
			subject: name,
			signatureAlgorithm: .ecdsaWithSHA256,
			extensions: extensions,
			issuerPrivateKey: key
		)
	}
	
	private static func createRootKey() throws -> X509.Certificate.PrivateKey {
		let keyURL = URL.documentsDirectory.appendingPathComponent("root.key")
		if FileManager.default.fileExists(atPath: keyURL.path) {
			let key = try P256.Signing.PrivateKey(rawRepresentation: Data(contentsOf: keyURL))
			return X509.Certificate.PrivateKey(key)
		}
		let key = P256.Signing.PrivateKey()
		try key.rawRepresentation.write(to: keyURL, options: [.atomic, .completeFileProtection])
		return X509.Certificate.PrivateKey(key)
	}
}
