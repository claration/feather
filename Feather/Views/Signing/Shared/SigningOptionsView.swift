//
//  SigningOptionsSharedView.swift
//  Feather
//
//  Created by samara on 15.04.2025.
//

import SwiftUI
import NimbleViews

// MARK: - View
struct SigningOptionsView: View {
	@Binding var options: Options
	var temporaryOptions: Options?
	
	// MARK: Body
	var body: some View {
		if (temporaryOptions == nil) {
			NBSection(.localized("Protection")) {
				_toggle(
					.localized("PPQ Protection"),
					systemImage: "shield",
					isOn: $options.ppqProtection,
					temporaryValue: temporaryOptions?.ppqProtection
				)
			} footer: {
				Text(.localized("Enabling any protection will append a random string to the bundleidentifiers of the apps you sign, this is to ensure your Apple ID does not get flagged by Apple. However, when using a signing service you can ignore this."))
			}
		}
		
		NBSection(.localized("General")) {
			Self.picker(
				.localized("Appearance"),
				systemImage: "paintpalette",
				selection: $options.appAppearance,
				values: Options.AppAppearance.allCases
			)
			
			Self.picker(
				.localized("Minimum Requirement"),
				systemImage: "ruler",
				selection: $options.minimumAppRequirement,
				values: Options.MinimumAppRequirement.allCases
			)
		}
		
		Section {
			Self.picker(
				.localized("Signing Type"),
				systemImage: "signature",
				selection: $options.signingOption,
				values: Options.SigningOption.allCases
			)
		}
		
		if (temporaryOptions == nil) {
			NBSection(.localized("Tweaks")) {
				Self.picker(
					.localized("Injection Path"),
					systemImage: "doc.badge.gearshape",
					selection: $options.injectPath,
					values: Options.InjectPath.allCases
				)
				
				Self.picker(
					.localized("Injection Folder"),
					systemImage: "folder.badge.gearshape",
					selection: $options.injectFolder,
					values: Options.InjectFolder.allCases
				)
				
				_toggle(
					.localized("Inject into Extensions"),
					systemImage: "syringe",
					isOn: $options.injectIntoExtensions,
					temporaryValue: temporaryOptions?.injectIntoExtensions
				)
			}
		}
		
		NBSection(.localized("App Features")) {
			_toggle(
				.localized("File Sharing"),
				systemImage: "folder.badge.person.crop",
				isOn: $options.fileSharing,
				temporaryValue: temporaryOptions?.fileSharing
			)
			
			_toggle(
				.localized("iTunes File Sharing"),
				systemImage: "music.note.list",
				isOn: $options.itunesFileSharing,
				temporaryValue: temporaryOptions?.itunesFileSharing
			)
			
			_toggle(
				.localized("Pro Motion"),
				systemImage: "speedometer",
				isOn: $options.proMotion,
				temporaryValue: temporaryOptions?.proMotion
			)
			
			_toggle(
				.localized("Game Mode"),
				systemImage: "gamecontroller",
				isOn: $options.gameMode,
				temporaryValue: temporaryOptions?.gameMode
			)
			
			_toggle(
				.localized("iPad Fullscreen"),
				systemImage: "ipad.landscape",
				isOn: $options.ipadFullscreen,
				temporaryValue: temporaryOptions?.ipadFullscreen
			)
		}
		
		NBSection(.localized("Removal")) {
			_toggle(
				.localized("Remove URL Scheme"),
				systemImage: "ellipsis.curlybraces",
				isOn: $options.removeURLScheme,
				temporaryValue: temporaryOptions?.removeURLScheme
			)
			
			_toggle(
				.localized("Remove Provisioning"),
				systemImage: "doc.badge.gearshape",
				isOn: $options.removeProvisioning,
				temporaryValue: temporaryOptions?.removeProvisioning
			)
		} footer: {
			Text(.localized("Removing the provisioning file will exclude the mobileprovision file from being embedded inside of the application when signing, to help prevent any detection."))
		}
		
		Section {
			_toggle(
				.localized("Force Localize"),
				systemImage: "character.bubble",
				isOn: $options.changeLanguageFilesForCustomDisplayName,
				temporaryValue: temporaryOptions?.changeLanguageFilesForCustomDisplayName
			)
		} footer: {
			Text(.localized("By default, localized titles for the app won't be changed, however this option overrides it."))
		}
		
		NBSection(.localized("Post Signing")) {
			_toggle(
				.localized("Install After Signing"),
				systemImage: "arrow.down.circle",
				isOn: $options.post_installAppAfterSigned,
				temporaryValue: temporaryOptions?.post_installAppAfterSigned
			)
			_toggle(
				.localized("Delete After Signing"),
				systemImage: "trash",
				isOn: $options.post_deleteAppAfterSigned,
				temporaryValue: temporaryOptions?.post_deleteAppAfterSigned
			)
		} footer: {
			Text(.localized("This will delete your imported application after signing, to save on using unneeded space."))
		}
		
		Section {
			_toggle(
				.localized("Merge Entitlements"),
				systemImage: "doc.plaintext",
				isOn: $options.mergeEntitlements,
				temporaryValue: temporaryOptions?.mergeEntitlements
			).disabled(options.appEntitlementsFile != nil)
		} footer: {
			Text(.localized("This option merges entitlements with the embedded entitlements from the app you're signing."))
		}
		
		NBSection(.localized("Experiments")) {			
			_toggle(
				.localized("Replace Substrate with ElleKit"),
				systemImage: "pencil",
				isOn: $options.experiment_replaceSubstrateWithEllekit,
				temporaryValue: temporaryOptions?.experiment_replaceSubstrateWithEllekit
			)
			
			_toggle(
				.localized("Disable Liquid Glass"),
				systemImage: "18.circle",
				isOn: $options.experiment_disableLiquidGlass,
				temporaryValue: temporaryOptions?.experiment_disableLiquidGlass
			).disabled(options.experiment_supportLiquidGlass)
			
			_toggle(
				.localized("Enable Liquid Glass"),
				systemImage: "26.circle",
				isOn: $options.experiment_supportLiquidGlass,
				temporaryValue: temporaryOptions?.experiment_supportLiquidGlass
			).disabled(options.experiment_disableLiquidGlass)
		} footer: {
			Text(.localized("This option force converts apps to try to use the new liquid glass redesign iOS 26 introduced, this may not work for all applications due to differing frameworks."))
		}
	}
	
	@ViewBuilder
	static func picker<SelectionValue: Hashable, T: Hashable & LocalizedDescribable>(
		_ title: String,
		systemImage: String,
		selection: Binding<SelectionValue>,
		values: [T]
	) -> some View {
		Picker(selection: selection) {
			ForEach(values, id: \.self) { value in
				Text(value.localizedDescription)
			}
		} label: {
			Label(title, systemImage: systemImage)
		}
	}
	
	@ViewBuilder
	private func _toggle(
		_ title: String,
		systemImage: String,
		isOn: Binding<Bool>,
		temporaryValue: Bool? = nil
	) -> some View {
		Toggle(isOn: isOn) {
			Label {
				if let tempValue = temporaryValue, tempValue != isOn.wrappedValue {
					Text(title).bold()
				} else {
					Text(title)
				}
			} icon: {
				Image(systemName: systemImage)
			}
		}
	}
}
