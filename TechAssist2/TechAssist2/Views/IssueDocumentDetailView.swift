//
//  IssueDocumentDetailView.swift
//  TechAssist2
//
//  Detailed view for the active incident playbook.
//

import SwiftUI

struct IssueDocumentDetailView: View {
    let document: ServerIssueDocument
    let workOrder: WorkOrder
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    overviewSection
                    checklistSection(title: "Symptoms to Validate", items: document.symptoms, icon: "exclamationmark.circle.fill")
                    checklistSection(title: "Immediate Actions", items: document.immediateActions, icon: "bolt.fill")
                    checklistSection(title: "Resolution Steps", items: document.resolutionSteps, icon: "wrench.and.screwdriver.fill", numbered: true)
                    checklistSection(title: "Validation Steps", items: document.validationSteps, icon: "checkmark.seal.fill", numbered: true)
                    checklistSection(title: "Safety Notes", items: document.safetyNotes, icon: "shield.checkerboard")
                    toolsSection
                    escalationSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
            .navigationTitle("Incident Playbook")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(document.title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)
            
            Text(document.summary)
                .font(.system(size: 15))
                .foregroundColor(AppTheme.textSecondary)
            
            DetailRow(
                label: "Work Order",
                value: "\(workOrder.taskID) · \(workOrder.title)",
                color: AppTheme.textSecondary
            )
            
            DetailRow(
                label: "Estimated Duration",
                value: "\(document.estimatedTimeMinutes) minutes",
                color: AppTheme.accentPrimary
            )
        }
        .padding(AppTheme.cardPadding)
        .background(AppTheme.backgroundSecondary)
        .cornerRadius(AppTheme.cardCornerRadius)
    }
    
    private func checklistSection(title: String, items: [String], icon: String, numbered: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppTheme.accentPrimary)
                Text(title.uppercased())
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    HStack(alignment: .top, spacing: 10) {
                        if numbered {
                            Text("\(index + 1).")
                                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                                .foregroundColor(AppTheme.accentPrimary)
                                .frame(width: 24, alignment: .leading)
                        } else {
                            Circle()
                                .fill(AppTheme.accentPrimary.opacity(0.8))
                                .frame(width: 6, height: 6)
                                .padding(.top, 6)
                        }
                        
                        Text(item)
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
            }
        }
        .padding(AppTheme.cardPadding)
        .background(AppTheme.backgroundSecondary)
        .cornerRadius(AppTheme.cardCornerRadius)
    }
    
    private var toolsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("RECOMMENDED TOOLS")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
            
            ForEach(document.recommendedTools, id: \.self) { tool in
                BulletRow(text: tool)
            }
        }
        .padding(AppTheme.cardPadding)
        .background(AppTheme.backgroundSecondary)
        .cornerRadius(AppTheme.cardCornerRadius)
    }
    
    private var escalationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ESCALATION GUIDANCE")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
            
            Text(document.escalationGuidance)
                .font(.system(size: 14))
                .foregroundColor(AppTheme.textSecondary)
        }
        .padding(AppTheme.cardPadding)
        .background(AppTheme.backgroundSecondary)
        .cornerRadius(AppTheme.cardCornerRadius)
    }
}


