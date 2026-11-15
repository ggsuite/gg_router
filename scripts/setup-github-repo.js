/*
 * @license
 * Copyright (c) ggsuite
 *
 * Use of this source code is governed by terms that can be
 * found in the LICENSE file in the root of this package.
 */

import { execSync } from 'child_process';
import { writeFileSync } from 'fs';
import { tmpdir } from 'os';
import { join } from 'path';
// ...........................................................................
// Colors
const color = (code) => (str) => `\x1b[${code}m${str}\x1b[0m`;
const red = color(31);
const green = color(32);
const yellow = color(33);
const blue = color(34);
const cyan = color(36);
const white = color(37);
const gray = color(90);

// ...........................................................................
// Execute a shell command and return trimmed output
function runCommand(command) {
  console.log(gray(command));
  return execSync(command, {
    encoding: 'utf-8',
    stdio: ['pipe', 'pipe', 'pipe'],
  }).trim();
}

// The name of the branch ruleset managed by this script
const rulesetName = 'Default';

// The status check that must pass before merging. It is provided by the
// GitHub Actions app, i.e. not by "Any source".
const requiredStatusCheck = 'Quick Check';
const gitHubActionsAppId = 15368;

// ...........................................................................
// Make sure the GitHub CLI is available and authenticated
function checkGhCli() {
  console.log(gray('Check GitHub CLI'));

  try {
    runCommand('gh --version');
  } catch {
    throw new Error(
      [
        yellow('GitHub CLI is not installed. Please install it:'),
        green('brew install gh'),
      ].join('\n'),
    );
  }

  try {
    runCommand('gh auth status');
  } catch {
    throw new Error(
      [yellow('Not yet logged in. Please run:'), green('gh auth login')].join(
        '\n',
      ),
    );
  }
}

// ...........................................................................
// Get "org/repo" either from the first argument or from the current directory
function repoSlug() {
  const fromArgs = process.argv.slice(2).find((a) => !a.startsWith('--'));
  if (fromArgs) {
    if (!/^[^/]+\/[^/]+$/.test(fromArgs)) {
      throw new Error(`Invalid repository '${fromArgs}'. Expected 'org/repo'.`);
    }
    return fromArgs;
  }

  console.log(gray('Get repository from current directory'));
  try {
    const json = runCommand('gh repo view --json nameWithOwner');
    return JSON.parse(json).nameWithOwner;
  } catch {
    throw new Error(
      [
        yellow('Could not determine the repository.'),
        yellow('Please call this script from a GitHub repository or run:'),
        green('node dna/scripts/setup-github-repo.js org/repo'),
      ].join('\n'),
    );
  }
}

// ...........................................................................
// Call the GitHub API with a JSON body
function ghApi(method, path, body) {
  const file = join(tmpdir(), `setup-github-repo-${process.pid}.json`);
  writeFileSync(file, JSON.stringify(body));
  console.log(gray(`gh api --method ${method} ${path}`));
  return execSync(`gh api --method ${method} ${path} --input ${file}`, {
    encoding: 'utf-8',
    stdio: ['pipe', 'pipe', 'pipe'],
  }).trim();
}

// ...........................................................................
// Only allow squash merges, auto merge and delete branches after merge
function pullRequestSettings() {
  return {
    allow_merge_commit: false,
    allow_squash_merge: true,
    // Default commit message: "Pull request title"
    squash_merge_commit_title: 'PR_TITLE',
    squash_merge_commit_message: 'BLANK',
    allow_rebase_merge: false,
    allow_auto_merge: true,
    allow_update_branch: true,
    delete_branch_on_merge: true,
  };
}

// ...........................................................................
function setupPullRequestSettings(slug) {
  console.log(gray('Setup pull request settings'));

  ghApi('PATCH', `repos/${slug}`, pullRequestSettings());

  console.log(green('✅ Pull request settings applied.'));
}

// ...........................................................................
// The ruleset protecting the default branch
function ruleset(requireReview) {
  return {
    name: rulesetName,
    target: 'branch',
    enforcement: 'active',
    conditions: {
      ref_name: { include: ['~DEFAULT_BRANCH'], exclude: [] },
    },
    rules: [
      { type: 'deletion' },
      { type: 'non_fast_forward' },
      { type: 'required_linear_history' },
      {
        type: 'pull_request',
        parameters: {
          required_approving_review_count: requireReview ? 1 : 0,
          dismiss_stale_reviews_on_push: false,
          require_code_owner_review: false,
          require_last_push_approval: requireReview,
          required_review_thread_resolution: requireReview,
          allowed_merge_methods: ['squash'],
        },
      },
      {
        type: 'required_status_checks',
        parameters: {
          strict_required_status_checks_policy: true,
          required_status_checks: [
            {
              context: requiredStatusCheck,
              integration_id: gitHubActionsAppId,
            },
          ],
        },
      },
    ],
  };
}

// ...........................................................................
// Find the id of an already existing ruleset with the same name
function existingRulesetId(slug) {
  const json = runCommand(`gh api repos/${slug}/rulesets`);
  const found = JSON.parse(json).find((r) => r.name === rulesetName);
  return found ? found.id : undefined;
}

// ...........................................................................
// Create the ruleset or update it when it already exists
function setupBranchRules(slug, requireReview) {
  console.log(gray('Setup branch rules'));

  const id = existingRulesetId(slug);

  if (id) {
    ghApi('PUT', `repos/${slug}/rulesets/${id}`, ruleset(requireReview));
    console.log(green(`✅ Ruleset '${rulesetName}' has been updated.`));
  } else {
    ghApi('POST', `repos/${slug}/rulesets`, ruleset(requireReview));
    console.log(green(`✅ Ruleset '${rulesetName}' has been created.`));
  }
}

// ...........................................................................
// Print the repo and the settings without changing anything
function dryRun(slug, requireReview) {
  console.log(cyan(slug));
  console.log(white(JSON.stringify(pullRequestSettings(), null, 2)));
  console.log(white(JSON.stringify(ruleset(requireReview), null, 2)));
}

// ...........................................................................
function main() {
  const requireReview = process.argv.includes('--require-review');
  const isDryRun = !process.argv.includes('--apply');

  checkGhCli();
  const slug = repoSlug();

  if (isDryRun) {
    dryRun(slug, requireReview);
    return;
  }

  console.log(blue(`https://github.com/${slug}`));

  setupPullRequestSettings(slug);
  setupBranchRules(slug, requireReview);

  console.log(green(`✅ Repository '${slug}' has been set up.`));
}

try {
  main();
} catch (error) {
  console.error(red(`Error: ${error.message}`));
  process.exit(1);
}
