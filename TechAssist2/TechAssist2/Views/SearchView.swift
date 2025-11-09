//
//  SearchView.swift
//  TechAssist2
//
//  Troubleshooting Articles Search View
//

import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    @State private var selectedArticle: TroubleshootingArticle?
    @State private var showArticleDetail = false
    
    var filteredArticles: [TroubleshootingArticle] {
        if searchText.isEmpty {
            return TroubleshootingArticle.allArticles
        } else {
            return TroubleshootingArticle.allArticles.filter { article in
                article.title.localizedCaseInsensitiveContains(searchText) ||
                article.stack.localizedCaseInsensitiveContains(searchText) ||
                article.category.localizedCaseInsensitiveContains(searchText) ||
                article.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.backgroundPrimary.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search Bar
                    searchBar
                    
                    // Articles List
                    if filteredArticles.isEmpty {
                        emptyStateView
                    } else {
                        articlesList
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showArticleDetail) {
            if let article = selectedArticle {
                ArticleDetailView(article: article)
            }
        }
    }
    
    private var searchBar: some View {
        VStack(spacing: 16) {
            Text("Troubleshooting Articles")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(AppTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(AppTheme.textSecondary)
                
                TextField("Search articles...", text: $searchText)
                    .foregroundColor(AppTheme.textPrimary)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
            }
            .padding(AppTheme.cardPadding)
            .background(AppTheme.backgroundSecondary)
            .cornerRadius(AppTheme.cardCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(AppTheme.textSecondary)
            
            Text("No articles found")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(AppTheme.textPrimary)
            
            Text("Try a different search term")
                .font(.system(size: 14))
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private var articlesList: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(filteredArticles) { article in
                    ArticleCard(article: article)
                        .onTapGesture {
                            selectedArticle = article
                            showArticleDetail = true
                        }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 100)
        }
    }
}

struct ArticleCard: View {
    let article: TroubleshootingArticle
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Stack Badge
                Text(article.stack)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppTheme.accentPrimary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(AppTheme.accentPrimary.opacity(0.15))
                    .cornerRadius(6)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            Text(article.title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppTheme.textPrimary)
                .lineLimit(2)
            
            Text(article.category)
                .font(.system(size: 13))
                .foregroundColor(AppTheme.textSecondary)
            
            // Tags
            if !article.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(article.tags.prefix(5), id: \.self) { tag in
                            Text(tag)
                                .font(.system(size: 10))
                                .foregroundColor(AppTheme.textSecondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(AppTheme.backgroundTertiary)
                                .cornerRadius(4)
                        }
                    }
                }
            }
        }
        .padding(AppTheme.cardPadding)
        .background(AppTheme.backgroundSecondary)
        .cornerRadius(AppTheme.cardCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

struct ArticleDetailView: View {
    let article: TroubleshootingArticle
    @Environment(\.dismiss) var dismiss
    @State private var contentHeight: CGFloat = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.backgroundPrimary.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Header
                        VStack(alignment: .leading, spacing: 12) {
                            Text(article.stack)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.accentPrimary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(AppTheme.accentPrimary.opacity(0.15))
                                .cornerRadius(6)
                            
                            Text(article.title)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                            
                            Text(article.category)
                                .font(.system(size: 14))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.1))
                        
                        // Content
                        Text(article.content)
                            .font(.system(size: 15))
                            .foregroundColor(AppTheme.textPrimary)
                            .lineSpacing(4)
                        
                        // Tags
                        if !article.tags.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Tags")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppTheme.textSecondary)
                                
                                TagView(tags: article.tags)
                            }
                        }
                    }
                    .padding(AppTheme.cardPadding)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(AppTheme.textPrimary)
                    }
                }
            }
        }
    }
}

// Simple tag view that displays tags in a scrollable horizontal view
struct TagView: View {
    let tags: [String]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(tags, id: \.self) { tag in
                    Text(tag)
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.textSecondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(AppTheme.backgroundSecondary)
                        .cornerRadius(6)
                }
            }
            .padding(.horizontal, 2)
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}

