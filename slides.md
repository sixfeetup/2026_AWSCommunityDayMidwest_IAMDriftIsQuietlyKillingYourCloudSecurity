---
title-prefix: Six Feet Up
pagetitle: IAM Drift Is Quietly Killing Your Cloud Security
author: Calvin Hendryx-Parker, CTO, Six Feet Up
author-meta:
    - Calvin Hendryx-Parker
    - Chris Watkins
date: AWS Community Day Midwest 2026
date-meta: 2026
keywords:
    - AWS
    - Azure
    - GCP
    - Cloud Custodian
    - IAM
    - Compliance
---

# IAM Drift Is Quietly Killing Your Cloud Security {.deck-title .no-logo}

#### Calvin Hendryx-Parker
#### AWS Community Day Midwest 2026

::: notes
Hello!

Six Feet Up Co-Founder and CTO and AWS Hero

What's today about?

IAM failures are rarely dramatic at first. They accumulate quietly.

IAM is your access control layer, but unlike a firewall rule you set once, IAM is alive. Roles get created for one-time projects and never cleaned up. Keys get issued and forgotten. Permissions creep wider over time. That drift is what we're here to talk about.
:::

# 01 {.section-header .no-logo}

## A Challenge Everyone Faces

# IAM hygiene is a challenge everyone faces {.title-body}

1. <span>Organizations often run on multiple cloud service providers: AWS, Azure, and GCP.</span>
2. <span>Each cloud service provider provides different tools.</span>
3. <span>IAM hygiene requires a holistic view of the entire cloud estate across providers.</span>
4. <span>Manual audits are tedious and just snapshots in time.</span>

::: notes
Frame IAM hygiene as a challenge of time and scale. The issue is not that teams never think about IAM; it is that cloud environments keep changing after the last review.

Define IAM drift as the gap between intended access and actual access over time. Projects end, people move, emergency exceptions become permanent, and point-in-time audits miss what changes the next day.
:::

# 02 {.section-header .no-logo}

## Solutions to 4 Key Challenges

# C7N: A Unified Way to Address IAM Hygiene {.title-body}

Solutions to 4 key IAM challenges using Cloud Custodian's vendor-neutral and open-source approach:

::: {.pill-row .challenge-cards}
<span>Users Without MFA</span>
<span>Orphaned Identities</span>
<span>Overly-Permissive Policies</span>
<span>Unmet Compliance Requirements</span>
:::

::: notes
Introduce Cloud Custodian as a vendor-neutral policy-as-code approach. The clouds have different APIs and different native tools, but the operating model can stay consistent: choose a resource, apply filters, and take actions.

Keep coming back to these four failure modes: compromise risk, forgotten attack paths, excessive blast radius, and compliance evidence.
:::

# 03 {.section-header .no-logo}

## Reducing the Risk of Account Compromise

# AWS: Using Credential Report Filter {.code-example .code-large}

```{.yaml .numberLines}
---
policies:
  - name: iam-users-without-mfa
    resource: iam-user
    filters:
      - type: credential
        key: mfa_active
        value: false
```

# Azure EntraID: Using Auth-Methods Filter {.code-example .code-medium}

```{.yaml .numberLines}
---
policies:
  - name: entraid-users-no-mfa
    resource: azure.entraid-user
    filters:
      - not:
        - type: auth-methods
          key: '[]."@odata.type"'
          value:
            - '#microsoft.graph.microsoftAuthenticatorAuthenticationMethod'
            - '#microsoft.graph.phoneAuthenticationMethod'
            - '#microsoft.graph.fido2AuthenticationMethod'
            - '#microsoft.graph.windowsHelloForBusinessAuthenticationMethod'
            - '#microsoft.graph.temporaryAccessPassAuthenticationMethod'
          op: intersect
```

::: notes
Anchor this slide on initial compromise. A user without MFA is not just a hygiene finding; it is an easier path into the environment.

Do not get stuck in every YAML detail. Explain the shape: the resource says what object we are checking, the filters describe the risky condition, and later actions define what happens next. The AWS and Azure examples look different because the providers expose identity data differently, but the policy pattern is the same.
:::

# 04 {.section-header .no-logo}

## Eliminating Forgotten Attack Vectors

# AWS: Unused Roles \(with remediation action\) {.code-example .code-large}

```{.yaml .numberLines}
---
policies:
  - name: iam-unused-roles
    resource: iam-role
    filters:
      - type: used
        state: false
    actions:
      - type: delete
        force: true
```

# GCP: Old Service Account Keys \(with remediation action\) {.code-example .code-large}

```{.yaml .numberLines}
---
policies:
  - name: old-service-account-keys
    resource: gcp.service-account-key
    filters:
      - type: value
        key: validAfterTime
        value_type: age
        value: 90
        op: greater-than
    actions:
      - type: delete
```

::: notes
Call these forgotten doors. Unused roles and old service account keys often started as legitimate work, then outlived the project, pipeline, vendor, or person who needed them.

Be careful with the deletion examples: this is what remediation can look like, but the practical advice is to earn trust first. In a real rollout, start by reporting and validating ownership before deleting identities or keys.
:::

# 05 {.section-header .no-logo}

## Reducing the Blast Radius of a Compromised Role

# AWS: Overly Permissive Policies {.code-example .code-large}

```{.yaml .numberLines}
---
policies:
  - name: overly-permissive-iam-policies
    resource: iam-policy
    filters:
      - type: used
      - type: has-allow-all
```

# Azure RBAC: Owner Role at Subscription Scope {.code-example .code-large}

```{.yaml .numberLines}
---
policies:
  - name: broad-owner-assignments
    resource: azure.roleassignment
    filters:
      - type: role
        key: properties.roleName
        op: eq
        value: Owner
      - type: scope
        value: subscription
```

::: notes
Use blast radius as the plain-language frame. The question is not only "can someone get in?" It is "what can they do after one identity is compromised?"

For AWS, highlight allow-all policies on used identities as especially concerning because they combine broad permission with active reachability. For Azure, Owner at subscription scope is powerful enough that it should be rare, intentional, and reviewable.
:::

# 06 {.section-header .no-logo}

## Preventing Audit Failures and Penalties

# CIS Microsoft Azure Foundations Benchmark v4.0.0 6.14 {.code-example .code-wide}

```{.yaml .numberLines}
---
# Require administrators or appropriately delegated users to
# register third-party applications.
policies:
  - name: users-can-register-applications-check
    resource: azure.entraid-authorization-policy
    filters:
      - type: value
        key: defaultUserRolePermissions.allowedToCreateApps
        value: true
```

# NIST SP 800-53 AC-7 \(partial\) {.code-example .code-wide}

```{.yaml .numberLines}
---
# Enforce a limit of [Assignment: organization-defined number]
# consecutive invalid logon attempts by a user during
# [Assignment: organization-defined time period]
policies:
  - name: password-lockout-threshold-check
    resource: azure.entraid-organization
    filters:
      - type: password-lockout-threshold
        max_threshold: 10
```

::: notes
Position compliance as repeatable evidence, not audit theater. Policy as code helps teams prove that the same control is checked the same way every time.

The point is not only passing CIS or NIST reviews. The operational benefit is that a requirement becomes a continuously checked condition instead of a spreadsheet row someone updates once a quarter.
:::

# 07 {.section-header .no-logo}

## One Concern to Detect

# Example: Old Access Keys {.code-example .code-dense}

```{.yaml .numberLines}
---
# Variables and YAML scalars are combined for code reuse in a single file.
vars:
  # This filter will detect AWS access keys that were created more than 90 days ago.
  filters: &filters
    - type: access-key
      key: CreateDate
      value_type: age
      value: 90
      op: greater-than

  # This notification action will send an email.
  notification_action: &notification_action
    - type: notify
      to:
        - security-team@example.com
      transport:
        type: sqs
        queue: custodian-notifications

policies:
  # This manually-run policy will detect and notify.
  - name: detect-old-access-keys
    resource: iam-user
    filters: *filters
    actions: *notification_action
```

::: notes
This is the first maturity step: detect one high-confidence concern consistently.

For old access keys, the risk is straightforward and easy for teams to understand. YAML anchors keep the policy reusable, but the important message is simple: find the condition, notify the responsible team, and build confidence in the signal before taking action.
:::

# 08 {.section-header .no-logo}

## Evolving the Approach

# Start with detection {.title-body}

Begin with a small, high-confidence control before turning on remediation.

<br/>

1. <span>Pick one IAM concern.</span>
2. <span>Detect it consistently.</span>
3. <span>Notify the responsible team.</span>
4. <span>Tune false positives.</span>
5. <span>Add action only after the signal is trusted.</span>

# Specifying Actions to Take When IAM Issues are Detected {.code-example .code-dense}

```{.yaml .numberLines}
---
vars:
  filters: &filters
    - type: access-key
      key: CreateDate
      value_type: age
      value: 90
      op: greater-than

  # We can specify multiple actions to take
  remediation_actions: &remediation_actions
    - type: notify
      to:
        - security-team@example.com
      transport:
        type: sqs
        queue: custodian-notifications
    # This action will remove AWS access keys that match the filter.
    - type: remove-keys
      disable: true

policies:
  - name: remediate-old-access-keys
    resource: iam-user
    filters: *filters
    actions: *remediation_actions
```

::: notes
This is the recommended adoption path: detect, notify, tune, then remediate.

Stress that remediation should come after trust. False positives are not just noisy; they can break workloads when the action changes access. Here the action disables matching keys instead of only notifying, so ownership and exception handling need to be worked out before this runs broadly.
:::

# 09 {.section-header .no-logo}

## Automating Remediation

# Leveraging C7N's autoremediation capabilities {.code-example .code-dense}

```{.yaml .numberLines}
---
vars:
  filters: &filters
    - type: access-key
      key: CreateDate
      value_type: age
      value: 90
      op: greater-than
  autoremediation_actions: &autoremediation_actions
    - type: notify
      to:
        - security-team@example.com
      transport:
        type: sqs
        queue: custodian-notifications
    - type: remove-keys
      disable: true

policies: # This event-driven policy will detect, notify, and remediate.
- name: autoremediate-old-access-keys
  resource: iam-user
  mode: # This mode will use an AWS lambda to listen for CreateAccessKey events.
    type: cloudtrail
    events:
      - source: iam.amazonaws.com
        event: CreateAccessKey
        ids: "responseElements.accessKey.userName"
  filters: *filters
  actions: *autoremediation_actions
```

::: notes
Distinguish remediation from autoremediation. Remediation means "I found this risky condition and can take action." Autoremediation means "I react when the risky change happens."

Leverage Cloud Custodian's autoremediation capabilities built on provider function and event services, such as AWS Lambda and AWS CloudTrail.

In this example, CloudTrail sees a CreateAccessKey event, Lambda runs the policy, and Custodian can notify and disable the key as soon as the event is logged.
:::

# Conclusion {.conclusion-body}


1. Cloud Custodian provides a vendor-neutral, policy-as-code solution for continuous IAM hygiene across your entire cloud estate.
2. Start simple with detection, evolve to remediation, and eventually automate enforcement.
3. Maintain compliance and reduce security risk in an open and flexible way.

<div class="conclusion-contact">
<span class="speaker">Calvin Hendryx-Parker, CTO at Six Feet Up</span>
<span class="email">calvin@sixfeetup.com</span>
</div>
<div class="citation">
<span class="original-presentor">Chris Watkins, Dir. Sec.</span>
<span class="original-conference">Governance As Code Day 2025</span>
</div>
::: notes
Close with the maturity path: detect, notify, tune, remediate, automate.

Cloud Custodian provides a vendor-neutral, policy-as-code solution for continuous IAM hygiene across your entire cloud estate. The win is not one clever policy; it is turning IAM hygiene from occasional cleanup into a continuous control.
:::

# Questions & Discussions {.deck-title .no-logo}

#### #CloudCustodian
#### #AWSCommunityDayMidwest
