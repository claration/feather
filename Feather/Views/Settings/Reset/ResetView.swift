//
//  ResetView.swift
//  Feather
//
//  Created by samara on 19.06.2025.
//

import SwiftUI
import NimbleViews
import Nuke
import CoreData

// MARK: - View
struct ResetView: View {
	// MARK: Body
	var body: some View {
		NBList(.localized("Reset")) {
			_cache()
			_coredata()
			_all()
		}
	}
	
	private func _cacheSize() -> String {
		var totalCacheSize = URLCache.shared.currentDiskUsage
		if let nukeCache = ImagePipeline.shared.configuration.dataCache as? DataCache {
			totalCacheSize += nukeCache.totalSize
		}
		return "\(ByteCountFormatter.string(fromByteCount: Int64(totalCacheSize), countStyle: .file))"
	}
	
	static func resetAlert(
		title: String,
		message: String = "",
		action: @escaping () -> Void
	) {
		let action = UIAlertAction(
			title: .localized("Proceed"),
			style: .destructive
		) { _ in
			action()
			UIApplication.shared.suspendAndReopen()
		}
		
		let style: UIAlertController.Style = UIDevice.current.userInterfaceIdiom == .pad
			? .alert
			: .actionSheet
		
		var msg = ""
		if !message.isEmpty { msg = message + "\n" }
		msg.append(.localized("This action cannot be undone. Would you like to proceed?"))
	
		UIAlertController.showAlertWithCancel(
			title: title,
			message: msg,
			style: style,
			actions: [action]
		)
	}
}

// MARK: - View extension
extension ResetView {
	@ViewBuilder
	private func _cache() -> some View {
		Section {
			Button(.localized("Reset Work Cache"), systemImage: "xmark.rectangle.portrait") {
				Self.resetAlert(title: .localized("Reset Work Cache")) {
					Self.clearWorkCache()
				}
			}
			
			Button(.localized("Reset Network Cache"), systemImage: "xmark.rectangle.portrait") {
				Self.resetAlert(
					title: .localized("Reset Network Cache"),
					message: _cacheSize()
				) {
					Self.clearNetworkCache()
				}
			}
		}
	}
	
	@ViewBuilder
	private func _coredata() -> some View {
		Section {
			Button(.localized("Reset Sources"), systemImage: "xmark.circle") {
				Self.resetAlert(
					title: .localized("Reset Sources"),
					message: Storage.shared.countContent(for: AltSource.self)
				) {
					Self.resetSources()
				}
			}
			
			Button(.localized("Reset Signed Apps"), systemImage: "xmark.circle") {
				Self.resetAlert(
					title: .localized("Reset Signed Apps"),
					message: Storage.shared.countContent(for: Signed.self)
				) {
					Self.deleteSignedApps()
				}
			}
			
			Button(.localized("Reset Imported Apps"), systemImage: "xmark.circle") {
				Self.resetAlert(
					title: .localized("Reset Imported Apps"),
					message: Storage.shared.countContent(for: Imported.self)
				) {
					Self.deleteImportedApps()
				}
			}
			
			Button(.localized("Reset Certificates"), systemImage: "xmark.circle") {
				Self.resetAlert(
					title: .localized("Reset Certificates"),
					message: Storage.shared.countContent(for: CertificatePair.self)
				) {
					Self.resetCertificates()
				}
			}
		}
	}
	
	@ViewBuilder
	private func _all() -> some View {
		Section {
			Button(.localized("Reset Settings"), systemImage: "xmark.octagon") {
				Self.resetAlert(title: .localized("Reset Settings")) {
					Self.resetUserDefaults()
				}
			}
			
			Button(.localized("Reset All"), systemImage: "xmark.octagon") {
				Self.resetAlert(title: .localized("Reset All")) {
					Self.resetAll()
				}
			}
		}
		.foregroundStyle(.red)
	}
}

// MARK: - View extension: reset
extension ResetView {
	static func clearWorkCache() {
		let fileManager = FileManager.default
		let tmpDirectory = fileManager.temporaryDirectory
		
		if let files = try? fileManager.contentsOfDirectory(atPath: tmpDirectory.path()) {
			for file in files {
				try? fileManager.removeItem(atPath: tmpDirectory.appendingPathComponent(file).path())
			}
		}
	}
	
	static func clearNetworkCache() {
		URLCache.shared.removeAllCachedResponses()
		HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
		
		if let dataCache = ImagePipeline.shared.configuration.dataCache as? DataCache {
			dataCache.removeAll()
		}
		
		if let imageCache = ImagePipeline.shared.configuration.imageCache as? Nuke.ImageCache {
			imageCache.removeAll()
		}
	}
	
	static func resetSources() {
		Storage.shared.clearContext(request: AltSource.fetchRequest())
	}
	
	static func deleteSignedApps() {
		Storage.shared.deleteSourceMetadata(kind: .signed)
		Storage.shared.clearContext(request: Signed.fetchRequest())
		try? FileManager.default.removeFileIfNeeded(at: FileManager.default.signed)
	}
	
	static func deleteImportedApps() {
		Storage.shared.deleteSourceMetadata(kind: .imported)
		Storage.shared.clearContext(request: Imported.fetchRequest())
		try? FileManager.default.removeFileIfNeeded(at: FileManager.default.unsigned)
	}
	
	static func resetCertificates(resetAll: Bool = false) {
		if !resetAll { UserDefaults.standard.set(0, forKey: "feather.selectedCert") }
		Storage.shared.clearContext(request: CertificatePair.fetchRequest())
		try? FileManager.default.removeFileIfNeeded(at: FileManager.default.certificates)
	}
	
	static func resetUserDefaults() {
		UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
	}
	
	static func resetAll() {
		clearWorkCache()
		clearNetworkCache()
		resetSources()
		deleteSignedApps()
		deleteImportedApps()
		resetCertificates(resetAll: true)
		resetUserDefaults()
	}
}
