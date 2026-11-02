//
//  ServerView.swift
//  Feather
//
//  Created by samara on 6.05.2025.
//

import SwiftUI
import NimbleJSON
import NimbleViews

// MARK: - View
struct ServerView: View {
	@Environment(\.openURL) private var openURL
	
	@AppStorage("Feather.ipFix") private var _ipFix: Bool = false
	@AppStorage("Feather.serverMethod") private var _serverMethod: Int = 0
	private let _serverMethods: [String] = [.localized("Fully Local"), .localized("Semi Local")]
	
	// MARK: Body
	var body: some View {
		Group {
			Section {
				Picker(
					.localized("Server Type"), 
					systemImage: "server.rack", 
					selection: $_serverMethod
				) {
					ForEach(_serverMethods.indices, id: \.description) { index in
						Text(_serverMethods[index]).tag(index)
					}
				}
				Toggle(
					.localized("Only use localhost address"), 
					systemImage: "lifepreserver", 
					isOn: $_ipFix
				)
				.disabled(_serverMethod != 1)
			}
			
			Section {
				Button(.localized("Install Local CA"), systemImage: "folder") {
					do {
						try ServerInstaller.createServerCert()
						let url = try ServerInstaller.rootCertificateDataURL()
						// TODO: use the local server to open a path to the data url
					} catch {
						UIAlertController.showAlertWithOk(title: .localized("Error"), message: String(describing: error))
					}
				}
				.disabled(_serverMethod != 0)
			}
		}
	}
}
