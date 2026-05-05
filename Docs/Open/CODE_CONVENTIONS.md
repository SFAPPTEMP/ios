# 코드 컨벤션

Clipy iOS 코드를 작성할 때 반복해서 보는 공개 기준입니다.
module 구조는 `PROJECT_STRUCTURE.md`, 테스트 기준은 `TESTING_GUIDE.md`에 둡니다.

## 프로젝트 파일

- Xcode에서 생성된 `.xcodeproj`, `.xcworkspace`를 직접 고치지 않습니다.
- 구조 변경은 Tuist manifest에서 합니다.
- 생성된 Xcode 파일과 `Derived/`는 commit하지 않습니다.
- Tuist 버전은 `.mise.toml`에 고정합니다.

## Swift 기본 기준

- UI는 UIKit을 기준으로 작성합니다.
- SwiftUI는 명시적으로 필요해질 때만 검토합니다.
- 앱에서 사용자에게 보이는 문구는 영어를 우선으로 작성합니다.
- 한국어는 이후 localization 단계에서 제공합니다.
- 실제로 구조가 필요해지기 전까지는 단순한 UIKit/Foundation 타입을 씁니다.
- dependency는 필요할 때만 추가하고, 추가한 이유를 남깁니다.

## Swift 파일 header

새 Swift 파일은 Xcode 기본 header 형태를 유지합니다.
project 이름은 `Clipy`로 씁니다.

```swift
//
//  FileName.swift
//  Clipy
//
//  Created by 박민서 on M/D/YY.
//
```

날짜는 파일이 들어가는 commit 날짜와 맞춥니다.
generated Swift 파일이나 외부에서 생성된 파일에는 억지로 header를 붙이지 않습니다.

## 화면 코드

UIKit 화면 코드는 가능한 한 얇게 둡니다.
ViewController는 navigation, binding, rendering에 집중합니다.

제품 규칙은 ViewController 내부에 오래 두지 않습니다.
비교, 결정, 저장/복원 같은 규칙은 Domain, State Machine, ViewModel 쪽으로 옮깁니다.

## 의존성

외부 SDK나 system service를 직접 퍼뜨리지 않습니다.
여러 곳에서 쓰거나 테스트 경계가 필요하면 project-owned protocol이나 adapter를 먼저 둡니다.

좋은 방향입니다.

```swift
protocol AnalyticsTracking {
    func track(_ event: AnalyticsEvent)
}
```

피할 방향입니다.

```swift
final class HomeViewModel {
    private let thirdPartyAnalytics: ThirdPartyAnalytics
}
```

## 테스트

테스트는 작고 동작 중심으로 둡니다.
테스트 이름만 봐도 지키는 제품 규칙이 보여야 합니다.

자세한 기준은 `TESTING_GUIDE.md`를 봅니다.
테스트 이름, fixture, mock/stub/spy, UIKit 화면 테스트 기준도 그 문서에서 다룹니다.

## Module

Module은 필요할 때만 추가합니다.
새 module을 만들기 전에는 책임, 의존 방향, test target, 검증 방법을 함께 정합니다.

자세한 구조 기준은 `PROJECT_STRUCTURE.md`를 봅니다.
