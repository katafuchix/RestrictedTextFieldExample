//
//  ContentView.swift
//  RestrictedTextFieldExample
//
//  Created by cano on 2025/06/19.
//

import SwiftUI

struct ContentView: View {
    @State private var username: String = ""
    @State private var show: Bool = false
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 10) {
                Text("Usage")
                    .font(.caption2)
                    .foregroundStyle(.gray)
                
                Text(
                    """
                    RestrictedTextField(
                       **characters,**
                       **value**
                    ) { textfield, message in
                       // Custom View
                    }
                    """
                )
                .font(.callout)
                .monospaced()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(15)
                .background(.gray.opacity(0.2), in: .rect(cornerRadius: 20))
                .onTapGesture {
                    show.toggle()
                }
                
                Spacer()
            }
            //.opacity(show ? 0 : 1)
            .animation(.snappy, value: show)
            .padding(15)
            .navigationTitle("Restricted TextField")
        }
        .sheet(isPresented: $show) {
            
            // 全体のコンテナ (縦方向に要素を並べる)
            VStack(alignment: .leading, spacing: 20) {
                // ヘッダー部分 (タイトルと説明)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Account Username")
                        .font(.title.bold()) // 太字のタイトル

                    Text("Let's find a perfect username for your account")
                        .font(.caption) // 小さな説明文
                        .foregroundStyle(.gray) // グレーの文字色
                }

                // ユーザー名入力フィールドとエラーメッセージのコンテナ
                ZStack(alignment: .bottomLeading) {
                    // カスタムTextField (RestrictedTextField)
                    RestrictedTextField(
                        hint: "i_neko", // プレースホルダーテキスト
                        characters: restrictedCharacters3, // 制限する文字セット
                        value: $username // 入力値のバインディング
                    ) { textfield, errorMessage in // textfield: 元のTextField, errorMessage: エラーメッセージ
                        let isEmpty = errorMessage.isEmpty // エラーメッセージが空かどうか

                        // TextFieldの見た目をカスタマイズ
                        ZStack(alignment: .bottomLeading) {
                            textfield
                                .autocorrectionDisabled() // 自動修正を無効化
                                .textInputAutocapitalization(.never) // 自動大文字化を無効化
                                .padding(.horizontal, 15) // 水平パディング
                                .padding(.vertical, 10) // 垂直パディング
                                .contentShape(.rect) // タップ領域を長方形に設定
                                .background { // 背景のカスタマイズ
                                    Rectangle()
                                        .fill(.ultraThinMaterial) // 半透明の背景 (すりガラス効果)
                                        // エラーメッセージがあれば赤、なければ灰色で背景色を調整
                                        .background((isEmpty ? Color.gray : Color.red).opacity(isEmpty ? 0.2 : 0.3))
                                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous)) // 角丸の四角形
                                }

                            // エラーメッセージが表示される場合
                            if !isEmpty {
                                Text("Username cannot contain **\(errorMessage)** character !!!") // エラーテキスト
                                    .font(.caption) // 小さなフォント
                                    .foregroundStyle(.gray) // グレーの文字色
                                    .contentTransition(.numericText()) // 数字のトランジション (今回は文字なのであまり影響なし)
                                    .transition(.blurReplace) // ぼかしながら置換するトランジション
                                    .offset(y: 25) // 下に少しずらす
                            }
                        }
                        // エラーメッセージの値が変化したときにアニメーションを適用
                        .animation(.smooth, value: errorMessage)
                    }
                }
                .padding(.bottom, 20) // TextFieldの下にパディング

                // "Check for availability" ボタン
                Button {
                    // ボタンがタップされたときの処理をここに記述
                    print("Username: \(username) の利用可能性をチェック")
                } label: {
                    Text("Check for availability")
                        .fontWeight(.semibold) // フォントを太く
                        .foregroundStyle(.white) // 白い文字色
                        .frame(maxWidth: .infinity) // 横幅いっぱいに広げる
                        .padding(.vertical, 12) // 垂直パディング
                        .background(.blue.gradient, in: .rect(cornerRadius: 10)) // 青色のグラデーション背景、角丸
                }
            }
            .padding(20) // 全体のコンテンツにパディング
            .background { // 全体の背景
                RoundedRectangle(cornerRadius: 30) // 角丸の四角形
                    .fill(.background) // システムの背景色で塗りつぶし
            }
            .padding(.horizontal, 15) // 水平方向のパディング
            // モーダルシートとして表示される際のデテント (高さ)
            .presentationDetents([.height(250)])
            .presentationCornerRadius(0) // 角丸なし
            .presentationBackground(.clear) //
        }
    }
    
    // サンプル1: アルファベットとアンダースコア以外の全てを禁止
    var restrictedCharacters1: CharacterSet {
        var chars = CharacterSet.letters.inverted // Unicodeの「文字」以外の全て
        chars.remove(Character("_").unicodeScalars.first!) // そこからアンダースコアを除外
        return chars
    }

    // サンプル2: 数字以外の全てを禁止 (数字のみ許可)
    var restrictedCharacters2: CharacterSet {
        CharacterSet.decimalDigits.inverted
    }

    // サンプル3: スペースと特定の記号 (!@#$) を禁止
    var restrictedCharacters3: CharacterSet {
        CharacterSet.whitespaces.union(CharacterSet(charactersIn: "!@#$"))
    }

    // サンプル4: 半角カナと全角カナを禁止
    var restrictedCharacters4: CharacterSet {
        CharacterSet(charactersIn: "ァ-ヶア-ン")
    }

    // サンプル5: 一般的な絵文字を禁止 (修正版)
    var restrictedCharacters5: CharacterSet {
        var chars = CharacterSet() // 空のCharacterSetで初期化

        // 各絵文字のUnicode範囲をループして追加
        for i in (0x1F600...0x1F64F) { // Emoticons
            if let scalar = UnicodeScalar(i) {
                chars.insert(scalar)
            }
        }
        for i in (0x1F300...0x1F5FF) { // Miscellaneous Symbols and Pictographs
            if let scalar = UnicodeScalar(i) {
                chars.insert(scalar)
            }
        }
        for i in (0x1F680...0x1F6FF) { // Transport and Map Symbols
            if let scalar = UnicodeScalar(i) {
                chars.insert(scalar)
            }
        }
        for i in (0x2600...0x26FF) {   // Miscellaneous Symbols
            if let scalar = UnicodeScalar(i) {
                chars.insert(scalar)
            }
        }
        for i in (0x2700...0x27BF) {   // Dingbats
            if let scalar = UnicodeScalar(i) {
                chars.insert(scalar)
            }
        }
        // ここにさらに他の絵文字ブロックの範囲を追加できます

        return chars
    }
}

#Preview {
    ContentView()
}
