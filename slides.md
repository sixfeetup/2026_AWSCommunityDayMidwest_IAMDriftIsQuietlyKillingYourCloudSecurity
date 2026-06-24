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
Include intro and Bio Here
:::

# 01 {.section-header .no-logo}

## A Challenge Everyone Faces

# IAM hygiene is a challenge everyone faces {.title-body}

1. <span>Organizations often run on multiple cloud service providers: AWS, Azure, and GCP.</span>
2. <span>Each cloud service provider provides different tools.</span>
3. <span>IAM hygiene requires a holistic view of the entire cloud estate across providers.</span>
4. <span>Manual audits are tedious and just snapshots in time.</span>

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

:::notes
Leverage Cloud Custodian's autoremediation capabilities built on provider function and event services, such as AWS Lambda and AWS CloudTrail.

Automatically notify and remediate an IAM issue as soon as the underlying change is logged.
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
:::notes
Cloud Custodian provides a vendor-neutral, policy-as-code solution for continuous IAM hygiene across your entire cloud estate.
:::

# Questions & Discussions {.deck-title .no-logo}

#### #CloudCustodian
#### #AWSCommnityDayMidwest
