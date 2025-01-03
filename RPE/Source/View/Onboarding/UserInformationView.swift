//
//  UserInformationView.swift
//  RPE
//
//  Created by 이상도 on 12/29/24.
//


import SwiftUI
import Realm
import RealmSwift

// MARK: - 앱의 첫 사용시에만 등장하는 뷰
struct UserInformationView: View {
    
    @State private var navigationRouter = NavigationRouter()
    @AppStorage("isFirstRun") private var isFirstRun: Bool?
    @State private var viewModel = BigThreeViewModel()
    @Binding var isPresented: Bool
    
    @State private var showAlert = false
    @State private var isSelectedGender = "Male"
    @AppStorage("isText") private var unitOfWeight: Bool = false // false면 KG
    @State private var bodyWeight: String = ""
    
    var body: some View {
        NavigationStack(path: $navigationRouter.path) {
            VStack {
                HStack {
                    Button {
                        navigationRouter.pop()
                    } label: {
                        Image(systemName: "chevron.left")
                            .frame(width: 24, height: 24)
                            .tint(.white)
                    }
                    Spacer()
                    Button {
                        //                        isFirstRun = false
                        //                        isPresented = false
                    } label: {
                        Text("SKIP")
                            .font(.setPretendard(weight: .semiBold, size: 18))
                            .foregroundStyle(.white)
                    }
                }
                .opacity(0) // 첫 온보딩은 무조건 입력하게
                
                VStack(alignment: .center, spacing: 10) {
                    Text("Fill Out Your Information")
                        .font(.setPretendard(weight: .semiBold, size: 26))
                        .foregroundStyle(.white)
                    Text("For an instant\ncalculation of your Points")
                        .font(.setPretendard(weight: .medium, size: 18))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                VStack(spacing: 22) {
                    VStack {
                        HStack {
                            Text("Gender")
                                .font(.setPretendard(weight: .bold, size: 18))
                                .foregroundStyle(.myAccentcolor)
                            Spacer()
                        }
                        HStack(spacing: 16) {
                            Button {
                                isSelectedGender = "Male"
                            } label: {
                                Text("MALE")
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                                    .font(.setPretendard(weight: isSelectedGender == "Male" ? .bold : .regular, size: 16))
                                    .foregroundStyle(isSelectedGender == "Male" ? .black : .white)
                                    .background(isSelectedGender == "Male" ? .myAccentcolor : .myB9B9B9)
                                    .cornerRadius(12)
                            }
                            
                            Button {
                                isSelectedGender = "Female"
                            } label: {
                                Text("FEMALE")
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                                    .font(.setPretendard(weight: isSelectedGender == "Female" ? .bold : .regular, size: 16))
                                    .foregroundStyle(isSelectedGender == "Female" ? .black : .white)
                                    .background(isSelectedGender == "Female" ? .myAccentcolor : .myB9B9B9)
                                    .cornerRadius(12)
                            }
                        }
                    }
                    
                    VStack {
                        HStack(spacing: 2) {
                            Text("Unit of measure")
                                .font(.setPretendard(weight: .bold, size: 18))
                                .foregroundStyle(.myAccentcolor)
                            Spacer()
                        }
                        HStack(spacing: 16) {
                            Button {
                                unitOfWeight = false
                            } label: {
                                Text("KG")
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                                    .font(.setPretendard(weight: !unitOfWeight ? .bold : .regular, size: 16))
                                    .foregroundStyle(!unitOfWeight ? .black : .white)
                                    .background(!unitOfWeight ? .myAccentcolor : .myB9B9B9)
                                    .cornerRadius(12)
                            }
                            
                            Button {
                                unitOfWeight = true
                            } label: {
                                Text("LB")
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                                    .font(.setPretendard(weight: unitOfWeight ? .bold : .regular, size: 16))
                                    .foregroundStyle(unitOfWeight ? .black : .white)
                                    .background(unitOfWeight ? .myAccentcolor : .myB9B9B9)
                                    .cornerRadius(12)
                            }
                        }
                    }
                    
                    VStack {
                        HStack(spacing: 2) {
                            Text("Body weight \(unitOfWeight ? "(lb)" : "(kg)")")
                                .font(.setPretendard(weight: .bold, size: 18))
                                .foregroundStyle(.myAccentcolor)
                            Spacer()
                        }
                        HStack {
                            ZStack {
                                TextField("Body weight", text: $bodyWeight)
                                    .multilineTextAlignment(.leading)
                                    .frame(height: 44)
                                    .padding(.horizontal)
                                    .background(.white)
                                    .cornerRadius(12)
                                    .keyboardType(.decimalPad)
                                    .onChange(of: bodyWeight) { oldValue, newValue in
                                        // 1) 숫자와 점(.)만 허용
                                        var filtered = newValue.filter { "0123456789.".contains($0) }
                                        
                                        // 2) 소수점이 2개 이상이면 제거
                                        let dotCount = filtered.filter { $0 == "." }.count
                                        if dotCount > 1 {
                                            if let lastDotIndex = filtered.lastIndex(of: ".") {
                                                filtered.remove(at: lastDotIndex)
                                            }
                                        }
                                        
                                        // 3) 소수점 1자리까지만 허용
                                        if let dotIndex = filtered.firstIndex(of: ".") {
                                            let afterDot = filtered[filtered.index(after: dotIndex)...]
                                            if afterDot.count > 1 {
                                                filtered = String(filtered.prefix(filtered.distance(from: filtered.startIndex, to: dotIndex) + 2))
                                            }
                                        }
                                        
                                        // 4) 앞자리가 0이거나 .으로 시작하는 경우 제거
                                        if filtered.hasPrefix(".") || filtered.hasPrefix("0") {
                                            if filtered.count > 1 && filtered.prefix(2) == "0." {
                                                // "0."은 허용
                                            } else {
                                                // 잘못된 경우 전체 삭제
                                                filtered = ""
                                            }
                                        }
                                        
                                        // 5) 최종적으로 수정된 filtered를 대입
                                        if filtered != newValue {
                                            bodyWeight = filtered
                                        }
                                    }
                                HStack {
                                    Spacer()
                                    XmarkButton(text: $bodyWeight)
                                }
                            }
                            Spacer()
                        }
                    }
                    Spacer()
                    
                    Button {
                        /// 3개 중 1개라도 값이 비어있다면 데이터 저장되지 않음
                        if bodyWeight.count == 0 {
                            showAlert = true
                        } else {
                            setUserProfile()
                            UIApplication.shared.closeKeyboard()
                            navigationRouter.push(to: .onboardingView)
                        }
                    } label: {
                        Text("NEXT")
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .font(.setPretendard(weight: .bold, size: 18))
                            .foregroundStyle(bodyWeight.count > 0 ? .black : .white)
                            .background(bodyWeight.count > 0 ? .myAccentcolor : .myB9B9B9)
                            .cornerRadius(12)
                    }
                    .padding(.top, 20)
                    .alert(isPresented: $showAlert) {
                        Alert(
                            title: Text("Message"),
                            message: Text("Please enter Bodyweight."),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                }
                .padding(.top, 36)
            }
            .padding()
            .applyGradientBackground()
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .onTapGesture {
                UIApplication.shared.closeKeyboard()
            }
            .navigationDestination(for: PathType.self) { pathType in
                pathType.NavigatingView()
            }
        }
        .environment(navigationRouter)
    }
    
    private func setUserProfile() {
        let realm = try! Realm()
        let weight = Double(bodyWeight) ?? 0.0
        let profileImageData = UIImage(named: "default_image")?.jpegData(compressionQuality: 0.8) // 기본 이미지 사용
        
        if let existingProfile = realm.objects(Profile.self).first {
            // 이미 존재하는 Profile이 있을 경우 업데이트
            try! realm.write {
                existingProfile.nickname = "Hello, Lifter"
                existingProfile.image = profileImageData
                existingProfile.gender = isSelectedGender
                existingProfile.bodyWeight = weight
            }
        } else {
            // 존재하지 않을 경우 새로운 Profile 생성
            let newProfile = Profile(
                nickname: "Hello, Lifter",
                image: profileImageData,
                gender: isSelectedGender,
                bodyWeight: weight
            )
            
            try! realm.write {
                realm.add(newProfile)
            }
        }
    }
}

extension NumberFormatter {
    static var decimal: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter
    }
}

#Preview {
    UserInformationView(isPresented: .constant(true))
        .environment(NavigationRouter())
}
