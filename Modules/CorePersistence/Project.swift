//
//  Project.swift
//  Clipy
//
//  Created by 박민서 on 5/5/26.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = ClipyModuleFactory.makeFramework(
    name: "CorePersistence",
    bundleIdSuffix: "core-persistence",
    dependencies: [
        .project(target: "CoreDomain", path: .relativeToRoot("Modules/CoreDomain"))
    ],
    coreDataModels: [
        .coreDataModel("Resources/ClipyPersistence.xcdatamodeld")
    ]
)
