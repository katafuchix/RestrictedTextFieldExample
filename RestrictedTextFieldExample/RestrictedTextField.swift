//
//  RestrictedTextField.swift
//  RestrictedTextFieldExample
//
//  Created by cano on 2025/06/19.
//

import SwiftUI

/// 入力制限付きTextFieldをカスタマイズできるビュー
struct RestrictedTextField<Content: View>: View {
    var hint: String // TextFieldのプレースホルダー
    var characters: CharacterSet // 入力を禁止したい文字のセット
    @Binding var value: String // 入力値（親ビューからバインディング）
    @ViewBuilder var content: (TextField<Text>, String) -> Content
    // TextFieldとエラーメッセージを使ってカスタムビューを構築

    /// エラーメッセージ（内部状態）
    @State private var errorMessage: String = ""

    var body: some View {
        // contentクロージャでUIを構築（TextFieldとエラーメッセージを渡す）
        content(
            TextField(hint, text: $value),
            errorMessage
        )
        .onChange(of: value) { oldValue, newValue in
            // 新しい入力値に禁止文字が含まれているかチェック
            let restrictedCharacters = newValue.unicodeScalars.filter { characters.contains($0) }

            if !restrictedCharacters.isEmpty {
                // 禁止文字が含まれていた場合、それらを削除
                value.unicodeScalars.removeAll(where: { characters.contains($0) })

                // エラーメッセージを更新（どの文字が削除されたか表示）
                errorMessage = "\(restrictedCharacters)"
            } else {
                // 禁止文字が含まれていなかった場合で、
                // 前の値にも禁止文字が含まれていないならエラーメッセージを消す
                if !oldValue.unicodeScalars.contains(where: { characters.contains($0) }) {
                    errorMessage = ""
                }
            }
        }
    }
}

#Preview {
    PreviewWrapper()
}

// PreviewProvider のヘルパーストラクチャはそのまま使用します。
// RestrictedTextField_Previews と同じ内容です。
struct PreviewWrapper: View {
    @State private var name: String = ""
    @State private var age: String = ""
    @State private var customInput: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section("名前（数字と記号を制限）") {
                    RestrictedTextField(
                        hint: "名前を入力",
                        characters: .alphanumerics.inverted.union(.symbols),
                        value: $name
                    ) { textField, error in
                        VStack(alignment: .leading) {
                            textField
                                .padding()
                                .border(Color.gray, width: 0.5)
                            if !error.isEmpty {
                                Text("禁止文字が入力されました: \(error)")
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                        }
                    }
                    Text("現在の入力: \(name)")
                }

                Section("年齢（数字以外を制限）") {
                    RestrictedTextField(
                        hint: "年齢を入力",
                        characters: CharacterSet(charactersIn: "0123456789").inverted,
                        value: $age
                    ) { textField, error in
                        VStack(alignment: .leading) {
                            textField
                                .keyboardType(.numberPad) // 数字キーパッドを表示
                                .padding()
                                .border(Color.gray, width: 0.5)
                            if !error.isEmpty {
                                Text("数字のみ入力してください")
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                        }
                    }
                    Text("現在の入力: \(age)")
                }

                Section("カスタム制限（'a', 'b', 'c' を制限）") {
                    RestrictedTextField(
                        hint: "自由に入力（'a', 'b', 'c' は不可）",
                        characters: CharacterSet(charactersIn: "abc"),
                        value: $customInput
                    ) { textField, error in
                        VStack(alignment: .leading) {
                            textField
                                .padding()
                                .background(error.isEmpty ? Color.clear : Color.red.opacity(0.1))
                                .cornerRadius(5)
                            if !error.isEmpty {
                                Text("許可されていない文字が見つかりました: \(error)")
                                    .foregroundColor(.orange)
                                    .font(.caption)
                            }
                        }
                    }
                    Text("現在の入力: \(customInput)")
                }
            }
            .navigationTitle("RestrictedTextField 例")
        }
    }
}
