
import SwiftUI

struct SettingsView: View {

  @Environment(\.dismiss) private var dismiss

  var body: some View {
    NavigationStack {
      List {
        Section {
          if let supportURL = AppConstants.supportURL {
            Link(destination: supportURL) {
              settingsRow(
                title: String.settingsSupport,
                subtitle: supportURL.absoluteString,
                systemImage: "paperplane"
              )
            }
          }

          if let privacyPolicyURL = AppConstants.privacyPolicyURL {
            Link(destination: privacyPolicyURL) {
              settingsRow(
                title: String.settingsPrivacyPolicy,
                subtitle: privacyPolicyURL.host() ?? privacyPolicyURL.absoluteString,
                systemImages: ["hand.raised.fill", "hand.raised.fill"]
              )
            }
          }

          if let sourceCodeURL = AppConstants.sourceCodeURL {
            Link(destination: sourceCodeURL) {
              settingsRow(
                title: String.settingsSourceCode,
                subtitle: sourceCodeURL.host() ?? sourceCodeURL.absoluteString,
                systemImage: "curlybraces"
              )
            }
          }
        }
        .listRowBackground(AppColors.surface)
      }
      .navigationTitle(String.settingsTitle)
      .navigationBarTitleDisplayMode(.inline)
      .scrollContentBackground(.hidden)
      .background(AppColors.background)
      .foregroundStyle(AppColors.textPrimary)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button(String.done) {
            dismiss()
          }
        }
      }
    }
  }

  private func settingsRow(title: String, subtitle: String, systemImage: String) -> some View {
    settingsRow(title: title, subtitle: subtitle, systemImages: [systemImage])
  }

  private func settingsRow(title: String, subtitle: String, systemImages: [String]) -> some View {
    HStack(spacing: AppLayout.spacing * 3) {
      HStack(spacing: -AppLayout.spacing) {
        ForEach(systemImages.indices, id: \.self) { index in
          Image(systemName: systemImages[index])
        }
      }
      .font(.body.weight(.semibold))
      .foregroundStyle(AppColors.accent)
      .frame(width: 28, height: 28)

      VStack(alignment: .leading, spacing: AppLayout.spacing) {
        Text(title)
          .font(.body.weight(.semibold))
          .foregroundStyle(AppColors.textPrimary)

        Text(subtitle)
          .font(.footnote)
          .foregroundStyle(AppColors.textSecondary)
          .lineLimit(1)
          .truncationMode(.middle)
      }

      Spacer(minLength: AppLayout.spacing * 2)

      Image(systemName: "arrow.up.right")
        .font(.footnote.weight(.semibold))
        .foregroundStyle(AppColors.textSecondary)
    }
    .padding(.vertical, AppLayout.spacing)
  }

}
