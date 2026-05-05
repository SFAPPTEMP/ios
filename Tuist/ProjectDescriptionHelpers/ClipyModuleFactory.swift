//
//  ClipyModuleFactory.swift
//  Clipy
//
//  Created by 박민서 on 4/28/26.
//

import ProjectDescription

public enum ClipyModuleFactory {
    public static func makeApp(
        name: String,
        bundleIdSuffix: String,
        dependencies: [TargetDependency] = [],
        hasTests: Bool = true
    ) -> Project {
        var targets: [Target] = [
            .target(
                name: name,
                destinations: ClipyProjectConfig.defaultDestinations,
                product: .app,
                bundleId: "\(ClipyProjectConfig.bundleIdPrefix).\(bundleIdSuffix)",
                deploymentTargets: ClipyProjectConfig.deploymentTargets,
                infoPlist: .extendingDefault(with: ClipyProjectConfig.baseInfoPlist),
                sources: ["\(ClipyProjectConfig.sourcesDirectory)/**"],
                dependencies: dependencies
            )
        ]

        if hasTests {
            targets.append(
                .target(
                    name: "\(name)Tests",
                    destinations: ClipyProjectConfig.defaultDestinations,
                    product: .unitTests,
                    bundleId: "\(ClipyProjectConfig.bundleIdPrefix).\(bundleIdSuffix).tests",
                    deploymentTargets: ClipyProjectConfig.deploymentTargets,
                    infoPlist: .default,
                    sources: ["\(ClipyProjectConfig.testsDirectory)/**"],
                    dependencies: [.target(name: name)]
                )
            )
        }

        return Project(
            name: name,
            options: .options(automaticSchemesOptions: .disabled),
            targets: targets,
            schemes: [makeScheme(name: name, hasTests: hasTests)]
        )
    }

    public static func makeFramework(
        name: String,
        bundleIdSuffix: String,
        dependencies: [TargetDependency] = [],
        hasTests: Bool = true,
        coreDataModels: [CoreDataModel] = []
    ) -> Project {
        var targets: [Target] = [
            .target(
                name: name,
                destinations: ClipyProjectConfig.defaultDestinations,
                product: .framework,
                bundleId: "\(ClipyProjectConfig.bundleIdPrefix).\(bundleIdSuffix)",
                deploymentTargets: ClipyProjectConfig.deploymentTargets,
                infoPlist: .default,
                sources: ["\(ClipyProjectConfig.sourcesDirectory)/**"],
                dependencies: dependencies,
                coreDataModels: coreDataModels
            )
        ]

        if hasTests {
            targets.append(
                .target(
                    name: "\(name)Tests",
                    destinations: ClipyProjectConfig.defaultDestinations,
                    product: .unitTests,
                    bundleId: "\(ClipyProjectConfig.bundleIdPrefix).\(bundleIdSuffix).tests",
                    deploymentTargets: ClipyProjectConfig.deploymentTargets,
                    infoPlist: .default,
                    sources: ["\(ClipyProjectConfig.testsDirectory)/**"],
                    dependencies: [.target(name: name)]
                )
            )
        }

        return Project(
            name: name,
            options: .options(automaticSchemesOptions: .disabled),
            targets: targets,
            schemes: [makeScheme(name: name, hasTests: hasTests)]
        )
    }

    private static func makeScheme(name: String, hasTests: Bool) -> Scheme {
        Scheme.scheme(
            name: name,
            shared: true,
            buildAction: .buildAction(targets: [.init(stringLiteral: name)]),
            testAction: hasTests ? .targets([.init(stringLiteral: "\(name)Tests")]) : nil,
            runAction: .runAction(executable: .init(stringLiteral: name))
        )
    }
}
