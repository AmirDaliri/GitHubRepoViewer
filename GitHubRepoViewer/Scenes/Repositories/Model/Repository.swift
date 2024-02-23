//
//  Repository.swift
//  GitHubRepoViewer
//
//  Created by Amir Daliri on 20.02.2024.
//

import Foundation

struct Repository: Codable, Equatable {
    var id: Int?
    var nodeID, name, fullName: String?
    var repositoryPrivate: Bool?
    var owner: Owner?
    var htmlURL: String?
    var description: String?
    var fork: Bool?
    var url, forksURL: String?
    var keysURL, collaboratorsURL: String?
    var teamsURL, hooksURL: String?
    var issueEventsURL: String?
    var eventsURL: String?
    var assigneesURL, branchesURL: String?
    var tagsURL: String?
    var blobsURL, gitTagsURL, gitRefsURL, treesURL: String?
    var statusesURL: String?
    var languagesURL, stargazersURL, contributorsURL, subscribersURL: String?
    var subscriptionURL: String?
    var commitsURL, gitCommitsURL, commentsURL, issueCommentURL: String?
    var contentsURL, compareURL: String?
    var mergesURL: String?
    var archiveURL: String?
    var downloadsURL: String?
    var issuesURL, pullsURL, milestonesURL, notificationsURL: String?
    var labelsURL, releasesURL: String?
    var deploymentsURL: String?
    var createdAt, updatedAt, pushedAt: Date?
    var gitURL, sshURL: String?
    var cloneURL: String?
    var svnURL: String?
    var homepage: String?
    var size, stargazersCount, watchersCount: Int?
    var language: String?
    var hasIssues, hasProjects, hasDownloads, hasWiki: Bool?
    var hasPages, hasDiscussions: Bool?
    var forksCount: Int?
    var mirrorURL: JSONNull?
    var archived, disabled: Bool?
    var openIssuesCount: Int?
    var license: License?
    var allowForking, isTemplate, webCommitSignoffRequired: Bool?
    var topics: [String]?
    var visibility: String?
    var forks, openIssues, watchers: Int?
    var defaultBranch: String?

    enum CodingKeys: String, CodingKey {
        case id
        case nodeID = "node_id"
        case name
        case fullName = "full_name"
        case repositoryPrivate = "private"
        case owner
        case htmlURL = "html_url"
        case description, fork, url
        case forksURL = "forks_url"
        case keysURL = "keys_url"
        case collaboratorsURL = "collaborators_url"
        case teamsURL = "teams_url"
        case hooksURL = "hooks_url"
        case issueEventsURL = "issue_events_url"
        case eventsURL = "events_url"
        case assigneesURL = "assignees_url"
        case branchesURL = "branches_url"
        case tagsURL = "tags_url"
        case blobsURL = "blobs_url"
        case gitTagsURL = "git_tags_url"
        case gitRefsURL = "git_refs_url"
        case treesURL = "trees_url"
        case statusesURL = "statuses_url"
        case languagesURL = "languages_url"
        case stargazersURL = "stargazers_url"
        case contributorsURL = "contributors_url"
        case subscribersURL = "subscribers_url"
        case subscriptionURL = "subscription_url"
        case commitsURL = "commits_url"
        case gitCommitsURL = "git_commits_url"
        case commentsURL = "comments_url"
        case issueCommentURL = "issue_comment_url"
        case contentsURL = "contents_url"
        case compareURL = "compare_url"
        case mergesURL = "merges_url"
        case archiveURL = "archive_url"
        case downloadsURL = "downloads_url"
        case issuesURL = "issues_url"
        case pullsURL = "pulls_url"
        case milestonesURL = "milestones_url"
        case notificationsURL = "notifications_url"
        case labelsURL = "labels_url"
        case releasesURL = "releases_url"
        case deploymentsURL = "deployments_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case pushedAt = "pushed_at"
        case gitURL = "git_url"
        case sshURL = "ssh_url"
        case cloneURL = "clone_url"
        case svnURL = "svn_url"
        case homepage, size
        case stargazersCount = "stargazers_count"
        case watchersCount = "watchers_count"
        case language
        case hasIssues = "has_issues"
        case hasProjects = "has_projects"
        case hasDownloads = "has_downloads"
        case hasWiki = "has_wiki"
        case hasPages = "has_pages"
        case hasDiscussions = "has_discussions"
        case forksCount = "forks_count"
        case mirrorURL = "mirror_url"
        case archived, disabled
        case openIssuesCount = "open_issues_count"
        case license
        case allowForking = "allow_forking"
        case isTemplate = "is_template"
        case webCommitSignoffRequired = "web_commit_signoff_required"
        case topics, visibility, forks
        case openIssues = "open_issues"
        case watchers
        case defaultBranch = "default_branch"
    }
}

// MARK: Repository convenience initializers and mutators

extension Repository {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Repository.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        id: Int?? = nil,
        nodeID: String?? = nil,
        name: String?? = nil,
        fullName: String?? = nil,
        repositoryPrivate: Bool?? = nil,
        owner: Owner?? = nil,
        htmlURL: String?? = nil,
        description: String?? = nil,
        fork: Bool?? = nil,
        url: String?? = nil,
        forksURL: String?? = nil,
        keysURL: String?? = nil,
        collaboratorsURL: String?? = nil,
        teamsURL: String?? = nil,
        hooksURL: String?? = nil,
        issueEventsURL: String?? = nil,
        eventsURL: String?? = nil,
        assigneesURL: String?? = nil,
        branchesURL: String?? = nil,
        tagsURL: String?? = nil,
        blobsURL: String?? = nil,
        gitTagsURL: String?? = nil,
        gitRefsURL: String?? = nil,
        treesURL: String?? = nil,
        statusesURL: String?? = nil,
        languagesURL: String?? = nil,
        stargazersURL: String?? = nil,
        contributorsURL: String?? = nil,
        subscribersURL: String?? = nil,
        subscriptionURL: String?? = nil,
        commitsURL: String?? = nil,
        gitCommitsURL: String?? = nil,
        commentsURL: String?? = nil,
        issueCommentURL: String?? = nil,
        contentsURL: String?? = nil,
        compareURL: String?? = nil,
        mergesURL: String?? = nil,
        archiveURL: String?? = nil,
        downloadsURL: String?? = nil,
        issuesURL: String?? = nil,
        pullsURL: String?? = nil,
        milestonesURL: String?? = nil,
        notificationsURL: String?? = nil,
        labelsURL: String?? = nil,
        releasesURL: String?? = nil,
        deploymentsURL: String?? = nil,
        createdAt: Date?? = nil,
        updatedAt: Date?? = nil,
        pushedAt: Date?? = nil,
        gitURL: String?? = nil,
        sshURL: String?? = nil,
        cloneURL: String?? = nil,
        svnURL: String?? = nil,
        homepage: String?? = nil,
        size: Int?? = nil,
        stargazersCount: Int?? = nil,
        watchersCount: Int?? = nil,
        language: String?? = nil,
        hasIssues: Bool?? = nil,
        hasProjects: Bool?? = nil,
        hasDownloads: Bool?? = nil,
        hasWiki: Bool?? = nil,
        hasPages: Bool?? = nil,
        hasDiscussions: Bool?? = nil,
        forksCount: Int?? = nil,
        mirrorURL: JSONNull?? = nil,
        archived: Bool?? = nil,
        disabled: Bool?? = nil,
        openIssuesCount: Int?? = nil,
        license: License?? = nil,
        allowForking: Bool?? = nil,
        isTemplate: Bool?? = nil,
        webCommitSignoffRequired: Bool?? = nil,
        topics: [String]?? = nil,
        visibility: String?? = nil,
        forks: Int?? = nil,
        openIssues: Int?? = nil,
        watchers: Int?? = nil,
        defaultBranch: String?? = nil
    ) -> Repository {
        return Repository(
            id: id ?? self.id,
            nodeID: nodeID ?? self.nodeID,
            name: name ?? self.name,
            fullName: fullName ?? self.fullName,
            repositoryPrivate: repositoryPrivate ?? self.repositoryPrivate,
            owner: owner ?? self.owner,
            htmlURL: htmlURL ?? self.htmlURL,
            description: description ?? self.description,
            fork: fork ?? self.fork,
            url: url ?? self.url,
            forksURL: forksURL ?? self.forksURL,
            keysURL: keysURL ?? self.keysURL,
            collaboratorsURL: collaboratorsURL ?? self.collaboratorsURL,
            teamsURL: teamsURL ?? self.teamsURL,
            hooksURL: hooksURL ?? self.hooksURL,
            issueEventsURL: issueEventsURL ?? self.issueEventsURL,
            eventsURL: eventsURL ?? self.eventsURL,
            assigneesURL: assigneesURL ?? self.assigneesURL,
            branchesURL: branchesURL ?? self.branchesURL,
            tagsURL: tagsURL ?? self.tagsURL,
            blobsURL: blobsURL ?? self.blobsURL,
            gitTagsURL: gitTagsURL ?? self.gitTagsURL,
            gitRefsURL: gitRefsURL ?? self.gitRefsURL,
            treesURL: treesURL ?? self.treesURL,
            statusesURL: statusesURL ?? self.statusesURL,
            languagesURL: languagesURL ?? self.languagesURL,
            stargazersURL: stargazersURL ?? self.stargazersURL,
            contributorsURL: contributorsURL ?? self.contributorsURL,
            subscribersURL: subscribersURL ?? self.subscribersURL,
            subscriptionURL: subscriptionURL ?? self.subscriptionURL,
            commitsURL: commitsURL ?? self.commitsURL,
            gitCommitsURL: gitCommitsURL ?? self.gitCommitsURL,
            commentsURL: commentsURL ?? self.commentsURL,
            issueCommentURL: issueCommentURL ?? self.issueCommentURL,
            contentsURL: contentsURL ?? self.contentsURL,
            compareURL: compareURL ?? self.compareURL,
            mergesURL: mergesURL ?? self.mergesURL,
            archiveURL: archiveURL ?? self.archiveURL,
            downloadsURL: downloadsURL ?? self.downloadsURL,
            issuesURL: issuesURL ?? self.issuesURL,
            pullsURL: pullsURL ?? self.pullsURL,
            milestonesURL: milestonesURL ?? self.milestonesURL,
            notificationsURL: notificationsURL ?? self.notificationsURL,
            labelsURL: labelsURL ?? self.labelsURL,
            releasesURL: releasesURL ?? self.releasesURL,
            deploymentsURL: deploymentsURL ?? self.deploymentsURL,
            createdAt: createdAt ?? self.createdAt,
            updatedAt: updatedAt ?? self.updatedAt,
            pushedAt: pushedAt ?? self.pushedAt,
            gitURL: gitURL ?? self.gitURL,
            sshURL: sshURL ?? self.sshURL,
            cloneURL: cloneURL ?? self.cloneURL,
            svnURL: svnURL ?? self.svnURL,
            homepage: homepage ?? self.homepage,
            size: size ?? self.size,
            stargazersCount: stargazersCount ?? self.stargazersCount,
            watchersCount: watchersCount ?? self.watchersCount,
            language: language ?? self.language,
            hasIssues: hasIssues ?? self.hasIssues,
            hasProjects: hasProjects ?? self.hasProjects,
            hasDownloads: hasDownloads ?? self.hasDownloads,
            hasWiki: hasWiki ?? self.hasWiki,
            hasPages: hasPages ?? self.hasPages,
            hasDiscussions: hasDiscussions ?? self.hasDiscussions,
            forksCount: forksCount ?? self.forksCount,
            mirrorURL: mirrorURL ?? self.mirrorURL,
            archived: archived ?? self.archived,
            disabled: disabled ?? self.disabled,
            openIssuesCount: openIssuesCount ?? self.openIssuesCount,
            license: license ?? self.license,
            allowForking: allowForking ?? self.allowForking,
            isTemplate: isTemplate ?? self.isTemplate,
            webCommitSignoffRequired: webCommitSignoffRequired ?? self.webCommitSignoffRequired,
            topics: topics ?? self.topics,
            visibility: visibility ?? self.visibility,
            forks: forks ?? self.forks,
            openIssues: openIssues ?? self.openIssues,
            watchers: watchers ?? self.watchers,
            defaultBranch: defaultBranch ?? self.defaultBranch
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
