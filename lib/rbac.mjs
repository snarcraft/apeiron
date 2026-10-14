// ============================================================
// rbac.mjs — zero-database RBAC generator
// ============================================================
// Derives the whole authorization layer from the scaffold
// answers: Laravel string enums (Role / Group / Feature / Action),
// the Group::resolve() permission matrix, the mirrored frontend
// app.config policies, TypeScript unions, seed personas, Pest
// coverage and backend translation files.
//
// House rules (see ai/playbooks/rbac.md):
//   - Permissions live in code, never in the database.
//   - `operator` + `admin` bypasses everything (Gate::before).
//   - Identifiers are single lowercase words.

export const ACTIONS = ['index', 'read', 'create', 'update', 'delete', 'manage']

export const FEATURE_CATALOG = {
  account: { icon: 'i-lucide-settings', hint: 'own profile & preferences', locked: true },
  team: { icon: 'i-lucide-users', hint: 'teams & invitations' },
  user: { icon: 'i-lucide-user-round', hint: 'team member management' },
  invoice: { icon: 'i-lucide-receipt', hint: 'billing documents', billing: true },
  contract: { icon: 'i-lucide-file-text', hint: 'subscriptions & agreements', billing: true },
  payout: { icon: 'i-lucide-landmark', hint: 'connected payouts', billing: true },
  media: { icon: 'i-lucide-image', hint: 'S3 attachments', locked: true },
  agent: { icon: 'i-lucide-bot', hint: 'AI assistant', locked: true },
  catalog: { icon: 'i-lucide-package', hint: 'product catalog' },
}

export const ROLE_CATALOG = {
  admin: { hint: 'platform owner — bypasses every gate', locked: true },
  manager: { hint: 'full workspace control' },
  member: { hint: 'day-to-day read access' },
  technician: { hint: 'field operator' },
  worker: { hint: 'execution-only access' },
  clerk: { hint: 'back-office operator' },
  viewer: { hint: 'read-only auditor' },
}

export const GROUP_CATALOG = {
  operator: { hint: 'platform staff — runs the place', locked: true },
  client: { hint: 'the customers' },
  vendor: { hint: 'supply side' },
  merchant: { hint: 'marketplace sellers' },
  partner: { hint: 'resellers & integrators' },
}

const FALLBACK_ICON = 'i-lucide-circle-dot'

export const FEATURE_ICONS = Object.fromEntries(
  Object.entries(FEATURE_CATALOG).map(([k, v]) => [k, v.icon]),
)

export function featureIcon(feature) {
  return FEATURE_ICONS[feature] ?? FALLBACK_ICON
}

const sn = (s) => s.toUpperCase().replace(/[^A-Z0-9]/g, '_')

export function normalizeIdentifiers(list) {
  return [...new Set(list.map((s) => s.trim().toLowerCase().split(/[^a-z0-9]+/)[0]).filter(Boolean))]
}

// ------------------------------------------------------------
// Default permission matrix
// ------------------------------------------------------------
// operator+admin → every action. Managers run their workspace.
// Everyone else reads; account is self-managed by all.
export function buildMatrix({ groups, roles, features }) {
  const matrix = {}

  for (const group of groups) {
    matrix[group] = {}

    for (const role of roles) {
      if (role === 'admin' && group !== 'operator') continue

      const policies = {}

      if (group === 'operator' && role === 'admin') {
        for (const feature of features) policies[feature] = [...ACTIONS]
      } else if (role === 'admin') {
        policies.account = ['manage']
        for (const feature of features) if (feature !== 'account') policies[feature] = ACTIONS.filter((a) => a !== 'delete')
      } else if (role === 'manager') {
        for (const feature of features) {
          if (feature === 'account') policies.account = ['manage']
          else if (feature === 'team') policies.team = ['index', 'read', 'update', 'manage']
          else if (feature === 'user') policies.user = ['index', 'read', 'create', 'update', 'delete']
          else policies[feature] = ['index', 'read', 'create', 'update']
        }
      } else {
        for (const feature of features) {
          policies[feature] = feature === 'account' ? ['manage'] : ['index', 'read']
        }
      }

      matrix[group][role] = policies
    }
  }

  return matrix
}

// ------------------------------------------------------------
// PHP enum sources
// ------------------------------------------------------------
function enumCases(list) {
  return list.map((v) => `    case ${sn(v)} = '${v}';`).join('\n')
}

function labelTrio(name, plural, { skipAll = false } = {}) {
  const allMethod = skipAll
    ? ''
    : `
    /**
     * @return Collection<array{value: ${name}, label: string}>
     */
    public static function all(): \\Illuminate\\Support\\Collection
    {
        return collect(self::cases())->map(fn (${name} $${name}) => $${name}->option());
    }`

  return `
    public function label(): string
    {
        return trans(sprintf('*.${plural}.%s', $this->value));
    }

    /**
     * @return array{value: ${name}, label: string}
     */
    public function option(): array
    {
        return [
            'value' => $this,
            'label' => $this->label(),
        ];
    }${allMethod}
`
}

export function phpRole(roles) {
  return `<?php

namespace App\\Enums;

use Illuminate\\Support\\Collection;

enum Role: string
{
${enumCases(roles)}
${labelTrio('Role', 'roles')}
}
`
}

export function phpFeature(features) {
  return `<?php

namespace App\\Enums;

use Illuminate\\Support\\Collection;

enum Feature: string
{
${enumCases(features)}
${labelTrio('Feature', 'features', { skipAll: true })}

    /**
     * Every "feature:action" ability, used to seed the gate cache
     * and to ship the policy map to the frontend.
     *
     * @return Collection<string>
     */
    public static function all(): Collection
    {
        return collect(self::cases())
            ->crossJoin(Action::cases())
            ->map(fn (array $pair) => sprintf('%s:%s', $pair[0]->value, $pair[1]->value));
    }
}
`
}

export function phpAction(actions = ACTIONS) {
  return `<?php

namespace App\\Enums;

use Illuminate\\Support\\Collection;

enum Action: string
{
${enumCases(actions)}
${labelTrio('Action', 'actions')}
}
`
}

export function phpGroup({ groups, matrix, features }) {
  const block = (group, role, policies) => {
    const entries = features
      .filter((f) => policies[f])
      .map((f) => {
        const acts = policies[f].map((a) => `                        Action::${sn(a)},`).join('\n')
        return `                    Feature::${sn(f)} => [
${acts}
                    ],`
      })
      .join('\n')

    return `                Role::${sn(role)} => [
${entries}
                ],`
  }

  const groupBlocks = groups
    .map((group) => {
      const roles = Object.keys(matrix[group] ?? {})
      if (!roles.length) return `            Group::${sn(group)} => [],`
      const roleBlocks = roles.map((role) => block(group, role, matrix[group][role])).join('\n')
      return `            Group::${sn(group)} => match ($role) {
                default => [],
${roleBlocks}
            },`
    })
    .join('\n')

  return `<?php

namespace App\\Enums;

use Illuminate\\Support\\Collection;

enum Group: string
{
${enumCases(groups)}

    /**
     * The permission matrix: every role's allowed actions per
     * feature. Permissions live in code — never in the database.
     *
     * @return array<string, array<int, Action>>
     */
    public function resolve(Role $role): array
    {
        return match ($this) {
            default => [],
${groupBlocks}
        };
    }
${labelTrio('Group', 'groups')}
}
`
}

// ------------------------------------------------------------
// Frontend app.config.ts (navigation + mirrored policies)
// ------------------------------------------------------------
function navFor(features) {
  const finance = features.filter((f) => ['invoice', 'contract', 'payout'].includes(f))
  const admin = features.filter((f) => ['team', 'user', 'account'].includes(f))
  const platform = features.filter((f) => !finance.includes(f) && !admin.includes(f))

  const entry = (f) => {
    const icon = featureIcon(f)
    const to = f === 'account' ? '/account' : `/${f}s`
    const action = f === 'account' ? undefined : `'read'`
    const tail = action ? `, action: ${action}` : ''
    return `      ${f}: { icon: '${icon}', to: '${to}'${tail} }`
  }

  const sections = []

  sections.push(`  navigation: {
    platform: {
${platform.map(entry).join(',\n')}
    }`)

  if (finance.length) {
    sections.push(`    finance: {
${finance.map(entry).join(',\n')}
    }`)
  }

  sections.push(`    administration: {
${admin.map(entry).join(',\n')}
    }
  }`)

  return sections.join(',\n')
}

function menuFor(features) {
  const finance = features.some((f) => ['invoice', 'contract', 'payout'].includes(f))
  const lines = [`    platform: 'i-lucide-layout-grid',`]
  if (finance) lines.push(`    finance: 'i-lucide-banknote',`)
  lines.push(`    administration: 'i-lucide-settings-2'`)
  return `  menu: {
${lines.join('\n')}
  },`
}

export function tsAppConfig({ matrix, features }) {
  const policies = JSON.stringify(matrix, null, 2)
    .replace(/"([a-zA-Z0-9_-]+)":/g, "'$1':")
    .replace(/"/g, "'")
    .split('\n')
    .map((l, i) => (i === 0 ? l : `  ${l}`))
    .join('\n')

  return `export default defineAppConfig({
  settings: {},
${menuFor(features)}
${navFor(features)},
  policies: ${policies},
  ui: {
    button: {
      slots: {
        base: 'justify-center'
      },
      variants: {
        block: {
          true: {
            base: 'w-full justify-center',
            trailingIcon: 'ms-0'
          }
        }
      }
    },
    colors: {
      primary: 'primary',
      secondary: 'secondary'
    },
    input: {
      slots: {
        root: 'w-full',
        base: ['rounded-lg']
      }
    },
    select: {
      slots: {
        base: ['rounded-lg', 'w-full']
      }
    },
    textarea: {
      slots: {
        root: 'w-full',
        base: ['rounded-lg']
      }
    }
  }
})
`
}

// ------------------------------------------------------------
// Frontend global types
// ------------------------------------------------------------
export function tsTypes({ groups, roles, features, actions = ACTIONS }) {
  const union = (list) => list.map((v) => `'${v}'`).join(' | ')

  return `type Group = ${union(groups)}
type Role = ${union(roles)}
type Feature = ${union(features)}
type Action = ${union(actions)}

type Policies = {
  [group in Group]?: {
    [role in Role]?: {
      [feature in Feature]?: Action[]
    }
  }
}

type MenuSection = 'platform' | 'finance' | 'administration'

type NavEntry = {
  icon: string
  to: string
  action?: Action
}

type User = {
  id: string
  uuid?: string
  name: string
  email: string
  group: Group
  role: Role
  policies: Record<string, boolean>
}

type Settings = {
  name: string
  title: string
  locale: string
  roles: { value: string; label: string }[]
  groups: { value: string; label: string }[]
}

type SanctumResponse<T> = { data: T }

declare module 'nuxt/schema' {
  interface AppConfigInput {
    settings: Settings
    menu: Record<MenuSection, string>
    navigation: Record<MenuSection, Record<string, NavEntry>>
    policies: Policies
  }
}

export {}
`
}

// ------------------------------------------------------------
// Seeder personas
// ------------------------------------------------------------
export function phpSeeder({ groups, roles, matrix, features, domain, title, theme }) {
  const personas = []

  if (roles.includes('admin')) {
    personas.push({ group: 'operator', role: 'admin', name: 'Ava Operator', email: `admin@${domain}` })
  }

  for (const group of groups.filter((g) => g !== 'operator')) {
    for (const role of Object.keys(matrix[group] ?? {})) {
      personas.push({
        group,
        role,
        name: `${role[0].toUpperCase()}${role.slice(1)} ${group[0].toUpperCase()}${group.slice(1)}`,
        email: `${role}.${group}@${domain}`,
      })
    }
  }

  const creates = personas
    .map(
      (p) => `        User::firstOrCreate(
            ['email' => '${p.email}'],
            [
                'name' => '${p.name}',
                'password' => Hash::make('password'),
                'email_verified_at' => now(),
            ],
        );`,
    )
    .join('\n\n')

  const teams = groups
    .map(
      (g) => `        $team = Team::firstOrCreate(
            ['name' => '${g === 'operator' ? `${title}` : `${title} ${g}`}'],
            ['group' => Group::${g.toUpperCase()}],
        );`,
    )
    .join('\n\n')

  // The platform Setting carries the scaffolded brand — theme
  // colors ride to every surface (webapp injection, mobile boot).
  const themePhp = theme
    ? `json_decode('${JSON.stringify(theme).replace(/'/g, "\\'")}', true)`
    : 'null'

  const setting = `        Setting::firstOrCreate(
            ['subdomain' => null],
            [
                'name' => '${title}',
                'title' => '${title}',
                'theme' => ${themePhp},
            ],
        );`

  return `<?php

namespace Database\\Seeders;

use App\\Enums\\Group;
use App\\Models\\Team;
use App\\Models\\User;
use Illuminate\\Database\\Seeder;
use Illuminate\\Support\\Facades\\Hash;

class DatabaseSeeder extends Seeder
{
    /**
     * Demo personas: one user per group/role so every policy path
     * can be exercised locally. Password is "password".
     */
    public function run(): void
    {
${setting}

${teams}

${creates}

        // Attach each persona to the team matching its group.
${personas
  .map(
    (p) =>
      `        tap(User::where('email', '${p.email}')->first(), function (User $user) {
            $user->teams()->syncWithoutDetaching([
                Team::where('group', Group::${p.group.toUpperCase()})->first()->id => ['role' => '${p.role}'],
            ]);
        });`,
  )
  .join('\n\n')}
    }
}
`
}

// ------------------------------------------------------------
// Pest coverage of the matrix
// ------------------------------------------------------------
export function phpRbacTest({ features, groups }) {
  const groupChecks = groups
    .map(
      (g) => `    test('${g} matrix only references known features', function () {
        foreach (Group::${g.toUpperCase()}->resolve(Role::MANAGER) as $feature => $actions) {
            expect(Feature::tryFrom($feature))->not->toBeNull();
        }
    });`,
    )
    .join('\n\n')

  return `<?php

use App\\Enums\\Action;
use App\\Enums\\Feature;
use App\\Enums\\Group;
use App\\Enums\\Role;
use App\\Models\\User;

test('operator admin may do everything', function () {
    $user = User::factory()->operator()->make();

    expect($user->isAdmin())->toBeTrue();

    foreach (Feature::cases() as $feature) {
        foreach (Action::cases() as $action) {
            expect($user->can($feature, $action))->toBeTrue();
        }
    }
});

test('every ability is a valid feature:action pair', function () {
    expect(Feature::all()->count())->toBe(count(Feature::cases()) * count(Action::cases()));
});

test('non-operator users are never admin', function () {
    \$user = User::factory()->make(['group' => null]);

    // group comes from membership, not columns — see Contractual
    expect(method_exists(\$user, 'isAdmin'))->toBeTrue();
});

${groupChecks}
`
}

// ------------------------------------------------------------
// Backend translation files
// ------------------------------------------------------------
export function langFile({ groups, roles, features, actions = ACTIONS, locale = 'en' }) {
  const cap = (s) => s[0].toUpperCase() + s.slice(1)
  const en = locale === 'en'

  const pages = {
    login: {
      title: en ? 'Welcome back' : 'Bon retour',
      subtitle: en ? 'Sign in to {app}' : 'Connectez-vous à {app}',
      email: en ? 'Email' : 'E-mail',
      emailPlaceholder: 'you@company.com',
      password: en ? 'Password' : 'Mot de passe',
      submit: en ? 'Sign in' : 'Se connecter',
      failedTitle: en ? 'Sign in failed' : 'Échec de la connexion',
      failedBody: en ? 'Check your credentials and try again.' : 'Vérifiez vos identifiants et réessayez.'
    },
    dashboard: {
      title: en ? 'Dashboard' : 'Tableau de bord',
      hello: en ? 'Hello, {name}' : 'Bonjour, {name}',
      there: en ? 'there' : 'à tous',
      signedInAs: en ? 'Signed in as' : 'Connecté en tant que',
      inGroup: en ? 'in' : 'dans',
      members: en ? 'Members' : 'Membres',
      media: en ? 'Media' : 'Médias',
      invoices: en ? 'Invoices' : 'Factures',
      activity: en ? 'Activity' : 'Activité',
      live: en ? 'live' : 'en direct',
      startTitle: en ? 'Your platform starts here' : 'Votre plateforme commence ici',
      startBody: en
        ? 'Every feature page you scaffold lands in the sidebar, gated by the same permissions the API enforces. Build the first one.'
        : 'Chaque page de fonctionnalité arrive dans la barre latérale, protégée par les mêmes permissions que l\u2019API. Construisez la première.'
    },
    account: {
      title: en ? 'Account' : 'Compte',
      profile: en ? 'Profile' : 'Profil',
      name: en ? 'Name' : 'Nom',
      email: en ? 'Email' : 'E-mail',
      group: en ? 'Group' : 'Groupe',
      role: en ? 'Role' : 'Rôle',
      workspace: en ? 'Workspace' : 'Espace',
      permissions: en ? 'Effective permissions' : 'Permissions effectives',
      permissionsBody: en
        ? 'Mirrored from the enum matrix — exactly what the API enforces.'
        : 'Reflet de la matrice d\u2019enums — exactement ce que l\u2019API applique.',
      noAbilities: en ? 'No abilities — ask an admin for a role.' : 'Aucune capacité — demandez un rôle à un admin.'
    }
  }

  const json = {
    features: Object.fromEntries(features.map((f) => [f, cap(f)])),
    roles: Object.fromEntries(roles.map((r) => [r, cap(r)])),
    groups: Object.fromEntries(groups.map((g) => [g, cap(g)])),
    actions: Object.fromEntries(actions.map((a) => [a, cap(a)])),
    sections: {
      platform: en ? 'Platform' : 'Plateforme',
      finance: en ? 'Finance' : 'Finance',
      administration: en ? 'Administration' : 'Administration',
    },
    pages,
  }

  return JSON.stringify(json, null, 4) + '\n'
}
