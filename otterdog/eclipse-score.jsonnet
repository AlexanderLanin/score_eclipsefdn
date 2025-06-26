# Overview, Defaults, Reference see https://otterdog.eclipse.org/projects/automotive.score

local orgs = import 'vendor/otterdog-defaults/otterdog-defaults.libsonnet';

local default_review_rule = {
  dismisses_stale_reviews: true,
  required_approving_review_count: 1,
  requires_code_owner_review: true,
};

// Hint: Override all options as required when creating a new repository. See below for examples.
// Parameters:
//   name: The name of the repository.
//   pages: boolean, whether to create default documentation pages for the repository.
local newScoreRepo(name, pages) = orgs.newRepo(name) {
  // These are disabled by default
  dependabot_security_updates_enabled: true,

  // Default: Squash only.
  // More details: https://eclipse-score.github.io/score/main/contribute/general/git.html
  allow_rebase_merge: false,
  allow_merge_commit: false,
  allow_squash_merge: true,

  // Remove some features, to avoid having too many options where stuff is located
  has_discussions: false,
  has_projects: false,
  has_wiki: false,

  // Setup the default review rule for main branch.
  rulesets: [
    orgs.newRepoRuleset('main') {
      include_refs+: [
        "refs/heads/main"
      ],
      required_pull_request+: default_review_rule,
    },
  ],
} + if pages then {
  gh_pages_build_type: "workflow",
  homepage: "https://eclipse-score.github.io/" + name,
} else {};

local newModuleRepo(name) = newScoreRepo(name, true) {
  template_repository: "eclipse-score/module_template",
};

local newInfrastructureTeamRepo(name, pages = false) = newScoreRepo(name, pages) {
  // Override the rulesets
  rulesets: [
    orgs.newRepoRuleset('main') {
      include_refs+: [
        "refs/heads/main"
      ],
      required_pull_request+: default_review_rule,

      // Enable emergency operations.
      bypass_actors+: [
        "@eclipse-score/infrastructure-maintainers",
      ],
    },
  ],
};

orgs.newOrg('automotive.score', 'eclipse-score') {
  settings+: {
    name: "Eclipse S-CORE",
    description: "",

    discussion_source_repository: "eclipse-score/score",
    has_discussions: true,
    workflows+: {
      actions_can_approve_pull_request_reviews: false,
    },
  },
  teams+: [
    orgs.newTeam('automotive-score-technical-leads') {
      members+: [
        "FScholPer",
        "antonkri",
        "johannes-esr",
        "ltekieli",
        "markert-r",
        "qor-lb"
      ],
    },
    orgs.newTeam('cft-communication') {
      members+: [
        "FScholPer",
        "antonkri",
        "arsibo",
        "johannes-esr",
        "ltekieli",
        "markert-r",
        "qor-lb"
      ],
    },
    orgs.newTeam('cft-feo') {
      members+: [
        "AlexanderLanin",
        "FScholPer",
        "MathiasDanzeisen",
        "antonkri",
        "arsibo",
        "johannes-esr",
        "ltekieli",
        "markert-r",
        "qor-lb"
      ],
    },
    orgs.newTeam('cft-logging') {
      members+: [
        "FScholPer",
        "antonkri",
        "arsibo",
        "johannes-esr",
        "ltekieli",
        "markert-r",
        "pahmann",
        "qor-lb"
      ],
    },
    orgs.newTeam('cft-orchestration') {
      members+: [
        "AlexanderLanin",
        "FScholPer",
        "MathiasDanzeisen",
        "antonkri",
        "arsibo",
        "johannes-esr",
        "ltekieli",
        "markert-r",
        "qor-lb"
      ],
    },
    orgs.newTeam('cft-persistency') {
      members+: [
        "FScholPer",
        "antonkri",
        "arsibo",
        "johannes-esr",
        "ltekieli",
        "markert-r",
        "qor-lb"
      ],
    },
    orgs.newTeam('community-architecture') {
      members+: [
        "FScholPer",
        "antonkri",
        "arsibo",
        "johannes-esr",
        "ltekieli",
        "markert-r",
        "qor-lb"
      ],
    },
    orgs.newTeam('community-operational') {
      members+: [
        "AlexanderLanin",
        "FScholPer",
        "PhilipPartsch",
        "antonkri",
        "johannes-esr",
        "ltekieli",
        "markert-r",
        "qor-lb"
      ],
    },
    orgs.newTeam('community-process') {
      members+: [
        "FScholPer",
        "PandaeDo",
        "PhilipPartsch",
        "antonkri",
        "aschemmel-tech",
        "johannes-esr",
        "ltekieli",
        "markert-r",
        "masc2023",
        "pahmann",
        "qor-lb"
      ],
    },
    orgs.newTeam('community-testing') {
      members+: [
        "FScholPer",
        "antonkri",
        "johannes-esr",
        "ltekieli",
        "markert-r",
        "pahmann",
        "qor-lb"
      ],
    },
    orgs.newTeam('codeowner-lola') {
      members+: [
        "castler",
        "hoe-jo",
        "LittleHuba"
      ],
    },
    orgs.newTeam('codeowner-baselibs') {
      members+: [
        "castler",
        "hoe-jo",
        "LittleHuba",
        "ramceb"
      ],
    },
    orgs.newTeam('infrastructure-maintainers') {
      members+: [
        "AlexanderLanin",
        "MaximilianSoerenPollak",
      ],
    },
  ],
  secrets+: [
    orgs.newOrgSecret('DEVELOCITY_API_TOKEN') {
      value: "pass:bots/automotive.score/develocity.eclipse.org/api-token",
    },
    orgs.newOrgSecret('ECLIPSE_GITLAB_API_TOKEN') {
      value: "pass:bots/automotive.score/gitlab.eclipse.org/api-token",
    },
    orgs.newOrgSecret('SCORE_QNX_LICENSE') {
      selected_repositories+: [
        "toolchains_qnx"
      ],
      value: "********",
      visibility: "selected",
    },
    orgs.newOrgSecret('SCORE_QNX_PASSWORD') {
      selected_repositories+: [
        "toolchains_qnx"
      ],
      value: "********",
      visibility: "selected",
    },
    orgs.newOrgSecret('SCORE_QNX_USER') {
      selected_repositories+: [
        "toolchains_qnx"
      ],
      value: "********",
      visibility: "selected",
    },
    orgs.newOrgSecret('RENOVATE_TOKEN') {
      value: "pass:bots/automotive.score/github.com/renovate-token",
    },
  ],
  _repositories+:: [
    orgs.newRepo('.github') {
      description: "Houses the organisation README",
      code_scanning_default_setup_enabled: true,
      code_scanning_default_languages+: [
        "actions",
      ],
      topics+: [
        "score"
      ],
      rulesets: [
        orgs.newRepoRuleset('main') {
          include_refs+: [
            "refs/heads/main"
          ],
          required_pull_request+: default_review_rule,
        },
      ],
    },

    newInfrastructureTeamRepo('bazel_registry') {
      description: "Score project bazel modules registry",
      topics+: [
        "bazel",
        "registry",
        "score"
      ],
    },

    newScoreRepo('eclipse-score.github.io', pages = true) {
      description: "The landing page website for the Score project",
      homepage: "https://eclipse-score.github.io/",
      topics+: [
        "landing-page",
        "score"
      ],
      environments: [
        orgs.newEnvironment('github-pages') {
          branch_policies+: [
            "main"
          ],
          deployment_branch_policy: "selected",
        },
      ],
    },
    orgs.newRepo('inc_feo') {
      allow_merge_commit: true,
      allow_update_branch: false,
      code_scanning_default_setup_enabled: true,
      code_scanning_default_languages+: [
        "actions",
      ],
      description: "Incubation repository for the fixed execution order framework",
      homepage: "https://eclipse-score.github.io/inc_feo",
      rulesets: [
        orgs.newRepoRuleset('main') {
          include_refs+: [
            "refs/heads/main"
          ],
          required_pull_request+: default_review_rule,
        },
      ],
    },
    orgs.newRepo('inc_mw_com') {
      allow_merge_commit: true,
      allow_update_branch: false,
      code_scanning_default_languages+: [
        "python"
      ],
      code_scanning_default_setup_enabled: true,
      description: "Incubation repository for interprocess communication framework",
      homepage: "https://eclipse-score.github.io/inc_mw_com",
      rulesets: [
        orgs.newRepoRuleset('main') {
          include_refs+: [
            "refs/heads/main"
          ],
          required_pull_request+: default_review_rule,
        },
      ],
    },
    orgs.newRepo('inc_mw_log') {
      allow_merge_commit: true,
      allow_update_branch: false,
      code_scanning_default_setup_enabled: true,
      description: "Incubation repository for logging framework",
      homepage: "https://eclipse-score.github.io/inc_mw_log",
      rulesets: [
        orgs.newRepoRuleset('main') {
          include_refs+: [
            "refs/heads/main"
          ],
          required_pull_request+: default_review_rule,
        },
      ],
    },
    newScoreRepo('inc_mw_per', true) {
      allow_merge_commit: true,
      allow_update_branch: false,

      description: "Incubation repository for persistency framework",

    },
    orgs.newRepo('inc_process_test_management') {
      allow_merge_commit: true,
      allow_update_branch: false,
      code_scanning_default_setup_enabled: true,
      description: "Incubation repository for Process - Sphinx-Test management",
      homepage: "https://eclipse-score.github.io/inc_process_test_management",
      rulesets: [
        orgs.newRepoRuleset('main') {
          include_refs+: [
            "refs/heads/main"
          ],
          required_pull_request+: {
            dismisses_stale_reviews: true,
            required_approving_review_count: 1,
            requires_code_owner_review: false,
          },
        },
      ],
    },
    orgs.newRepo('inc_process_variant_management') {
      allow_merge_commit: true,
      allow_update_branch: false,
      code_scanning_default_setup_enabled: true,
      description: "Incubation repository for Process - Sphinx-Variant management",
      homepage: "https://eclipse-score.github.io/inc_process_variant_management",
      rulesets: [
        orgs.newRepoRuleset('main') {
          include_refs+: [
            "refs/heads/main"
          ],
          required_pull_request+: {
            dismisses_stale_reviews: true,
            required_approving_review_count: 1,
            requires_code_owner_review: false,
          },
        },
      ],
    },
    orgs.newRepo('itf') {
      allow_merge_commit: true,
      allow_update_branch: false,
      code_scanning_default_setup_enabled: true,
      description: "Integration Testing Framework repository",
      gh_pages_build_type: "legacy",
      gh_pages_source_branch: "gh-pages",
      gh_pages_source_path: "/",
      has_discussions: true,
      homepage: "https://eclipse-score.github.io/itf",
      topics+: [
        "itf",
        "score",
        "testing"
      ],
      rulesets: [
        orgs.newRepoRuleset('main') {
          include_refs+: [
            "refs/heads/main"
          ],
          required_pull_request+: default_review_rule,
          required_status_checks+: {
            status_checks+: [
              "itf-build-all",
              "itf-examples-build-all",
            ],
          },
          required_merge_queue: orgs.newMergeQueue() {
            merge_method: "MERGE",
          },
        },
      ],
      environments: [
        orgs.newEnvironment('github-pages'),
      ],
    },

    newScoreRepo('process_description', pages = true) {
      has_projects: true,

      // Custom merge settings.
      allow_merge_commit: true,
      allow_rebase_merge: true,
      allow_update_branch: false,
      description: "Score project process description",
      topics+: [
        "process",
        "score"
      ],
      environments: [
        orgs.newEnvironment('github-pages') {
          branch_policies+: [
            "main"
          ],
          deployment_branch_policy: "selected",
        },
      ],
    },
    orgs.newRepo('reference_integration') {
      allow_merge_commit: true,
      allow_update_branch: false,
      code_scanning_default_setup_enabled: true,
      description: "Score project integration repository",
      topics+: [
        "integration",
        "score"
      ],
      rulesets: [
        orgs.newRepoRuleset('main') {
          include_refs+: [
            "refs/heads/main"
          ],
          required_pull_request+: default_review_rule,
        },
      ],
    },
    orgs.newRepo('score') {
      allow_merge_commit: true,
      allow_update_branch: false,
      code_scanning_default_languages+: [
        "actions",
      ],
      code_scanning_default_setup_enabled: true,
      description: "Score project main repository",
      gh_pages_build_type: "legacy",
      gh_pages_source_branch: "gh-pages",
      gh_pages_source_path: "/",
      has_discussions: true,
      homepage: "https://eclipse-score.github.io/score",
      topics+: [
        "score"
      ],
      rulesets: [
        orgs.newRepoRuleset('main') {
          include_refs+: [
            "refs/heads/main"
          ],
          required_pull_request+: default_review_rule,
        },
      ],
      environments: [
        orgs.newEnvironment('github-pages'),
      ],
    },

    newInfrastructureTeamRepo('tooling') {
      description: "Tooling for Eclipse S-CORE",
    },

    orgs.newRepo('baselibs') {
      allow_merge_commit: false,
      allow_update_branch: false,
      code_scanning_default_setup_enabled: false,
      description: "base libraries including common functionality",
      rulesets: [
        orgs.newRepoRuleset('main') {
          include_refs+: [
            "refs/heads/main"
          ],
          required_pull_request+: default_review_rule,
          bypass_actors+: [
            "@eclipse-score/codeowner-baselibs",
          ],
          allows_force_pushes: false,
          requires_linear_history: true,
        },
      ],
    },
    orgs.newRepo('communication') {
      allow_merge_commit: false,
      allow_update_branch: false,
      code_scanning_default_setup_enabled: false,
      has_discussions: true,
      has_wiki: false,
      description: "Repository for the communication module LoLa",
      rulesets: [
        orgs.newRepoRuleset('main') {
          include_refs+: [
            "refs/heads/main"
          ],
          required_pull_request+: default_review_rule,
          bypass_actors+: [
            "@eclipse-score/codeowner-lola",
          ],
          allows_force_pushes: false,
          requires_linear_history: true,
        },
      ],
    },
    orgs.newRepo('operating_system') {
      allow_merge_commit: true,
      allow_update_branch: false,
      code_scanning_default_setup_enabled: true,
      description: "Repository for the module operating system",
      rulesets: [
        orgs.newRepoRuleset('main') {
          include_refs+: [
            "refs/heads/main"
          ],
          required_pull_request+: default_review_rule,
        },
      ],
    },
    orgs.newRepo('examples') {
      allow_merge_commit: true,
      allow_update_branch: false,
      code_scanning_default_setup_enabled: true,
      description: "Hosts templates and examples for score tools and workflows",
      homepage: "https://eclipse-score.github.io/examples",
      rulesets: [
        orgs.newRepoRuleset('main') {
          include_refs+: [
            "refs/heads/main"
          ],
          required_pull_request+: default_review_rule,
        },
      ],
    },
    orgs.newRepo('toolchains_gcc') {
      allow_merge_commit: true,
      allow_update_branch: false,
      code_scanning_default_setup_enabled: true,
      description: "Bazel toolchains for GNU GCC",
      homepage: "https://eclipse-score.github.io/toolchains_gcc",
      rulesets: [
        orgs.newRepoRuleset('main') {
          include_refs+: [
            "refs/heads/main"
          ],
          required_pull_request+: default_review_rule,
        },
      ],
    },
    orgs.newRepo('toolchains_gcc_packages') {
      allow_merge_commit: true,
      allow_update_branch: false,
      code_scanning_default_setup_enabled: true,
      description: "Bazel toolchains for GNU GCC",
      homepage: "https://eclipse-score.github.io/toolchains_gcc_packages",
      rulesets: [
        orgs.newRepoRuleset('main') {
          include_refs+: [
            "refs/heads/main"
          ],
          required_pull_request+: default_review_rule,
        },
      ],
    },
    orgs.newRepo('toolchains_qnx') {
      allow_merge_commit: true,
      allow_update_branch: false,
      code_scanning_default_languages+: [
        "python"
      ],
      code_scanning_default_setup_enabled: true,
      description: "Bazel toolchains for QNX",
      homepage: "https://eclipse-score.github.io/toolchains_qnx",
      environments: [
        orgs.newEnvironment('workflow-approval') {
          deployment_branch_policy: "all",
          reviewers+: [
            "@eclipse-score/automotive-score-committers",
          ],
          wait_timer: 1,
        },
      ],
      rulesets: [
        orgs.newRepoRuleset('main') {
          include_refs+: [
            "refs/heads/main"
          ],
          required_pull_request+: default_review_rule,
          required_status_checks+: {
            status_checks+: [
              "toolchains-qnx-build-all",
            ],
          },
          required_merge_queue: orgs.newMergeQueue() {
            merge_method: "MERGE",
          },
        },
      ],
    },
    orgs.newRepo('toolchains_rust') {
      allow_merge_commit: true,
      allow_update_branch: false,
      code_scanning_default_setup_enabled: true,
      description: "Rust toolchains",
      homepage: "https://eclipse-score.github.io/toolchains_rust",
      rulesets: [
        orgs.newRepoRuleset('main') {
          include_refs+: [
            "refs/heads/main"
          ],
          required_pull_request+: default_review_rule,
        },
      ],
    },

    newInfrastructureTeamRepo('module_template', pages = true) {
      description: "C++ & Rust Bazel Template Repository",
      is_template: true,
    },

    newInfrastructureTeamRepo('cicd-workflows') {
      description: "Reusable GitHub Actions workflows for CI/CD automation",
    },

    newInfrastructureTeamRepo('docs-as-code', pages = true) {
      description: "Docs-as-code tooling for Eclipse S-CORE",

      gh_pages_build_type: "workflow",
      homepage: "https://eclipse-score.github.io/docs-as-code",
    },

    orgs.newRepo('inc_orchestrator') {
      allow_merge_commit: true,
      allow_update_branch: false,
      code_scanning_default_setup_enabled: true,
      code_scanning_default_languages+: [
        "actions",
      ],
      description: "Incubation repo for orchestration",
      gh_pages_build_type: "workflow",
      homepage: "https://eclipse-score.github.io/inc_orchestrator",
      rulesets: [
        orgs.newRepoRuleset('main') {
          include_refs+: [
            "refs/heads/main"
          ],
          required_pull_request+: default_review_rule,
        },
      ],
    },

    newInfrastructureTeamRepo('bazel_registry_ui') {
      description: "House the ui for bazel_registry in Score",
      gh_pages_build_type: "legacy",
      gh_pages_source_branch: "gh-pages",
      gh_pages_source_path: "/",
      homepage: "https://eclipse-score.github.io/bazel_registry_ui",
      forked_repository:"bazel-contrib/bcr-ui",
    },

    newInfrastructureTeamRepo('apt-install') {
      description: "GitHub Action to execute apt-install in a clever way",
    },

    newInfrastructureTeamRepo('devcontainer') {
      description: "Common Devcontainer for Eclipse S-CORE",
    },

    orgs.newRepo('testing_tools') {
      allow_merge_commit: true,
      allow_update_branch: false,
      code_scanning_default_setup_enabled: true,
      description: "Repository for testing utilities",
      rulesets: [
        orgs.newRepoRuleset('main') {
          include_refs+: [
            "refs/heads/main"
          ],
          required_pull_request+: default_review_rule,
        },
      ],
    },

    newModuleRepo('inc_json') {
      description: "Incubation repository for JSON module",
    },
  ],
}
