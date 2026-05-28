
import SwiftUI

extension View {

  func card() -> some View {
    background(
      RoundedRectangle(cornerRadius: AppLayout.cardRadius, style: .continuous)
        .fill(AppColors.background)
    )
  }

}
