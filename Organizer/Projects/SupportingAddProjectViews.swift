//
//  SupportingAddProjectViews.swift
//  Organizer
//
//  Created by Parthiv Naresh on 5/3/24.
//

import SwiftUI
import Combine


struct NewProjectTitleAndDescriptionView: View {
    @Binding var projectName: String
    @Binding var projectDescription: String
    @FocusState var isInputActive: Bool
    @Binding var showError: Bool
    
    var body: some View{
        TextField("e.g. Remodel the living room", text: $projectName)
            .onReceive(Just(projectName)) { newValue in
                showError = newValue.isEmpty
            }
            .focused($isInputActive)
            .padding(EdgeInsets(top: 8, leading: 15, bottom: 4, trailing: 15))
            .background(Color.white)
            .cornerRadius(1)
            .font(.system(size: 20, weight: .semibold))
        TextField("Project Description", text: $projectDescription)
            .padding(EdgeInsets(top: 8, leading: 15, bottom: 8, trailing: 10))
            .background(Color.white)
            .cornerRadius(1)
    }
}

struct NewProjectAddProjectButtonView: View {
    var action: () -> Void
    var isEnabled: Bool

    var body: some View {
        HStack {
            Spacer()
            Button(action: action) {
                Image(systemName: "arrow.up.circle.fill")
                    .resizable()
                    .frame(width: 35, height: 35)
                    .foregroundColor(isEnabled ? .blue : .gray)
            }
            .disabled(!isEnabled)
            .padding(.trailing, 20)
        }
    }
}
