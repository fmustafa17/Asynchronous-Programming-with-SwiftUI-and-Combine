//
//  BooksListView.swift
//  BookShelf
//
//  Created by Peter Friese on 11.09.22.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import SwiftUI

struct BooksListView: View {
    var books: [Book]
    
    var body: some View {
        List(books) { book in
            BookRowView(book: book)
                .padding(.top, 20)
        }
    }
}

struct BooksListView_Previews: PreviewProvider {
  static var previews: some View {
      BooksListView(books: Book.sampleBooks)
          .previewLayout(.sizeThatFits)
  }
}

struct BookRowView: View {
    var book: Book

    var body: some View {
        HStack(alignment: .top) {
            Image(book.mediumCoverImageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 90)
            VStack(alignment: .leading) {
                Text(book.title)
                    .font(.headline)
                Text("by \(book.author)")
                    .font(.subheadline)
                // Add another Text view to display the ISBN of each book on the same line that displays the number of pages.
                HStack {
                    // Align the page number text to the left, and the ISBN to the right of the view.
                    Text("\(book.pages) pages")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("\(book.isbn)")
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .font(.caption)
            }
            Spacer()
        }
    }
}
