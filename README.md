# Kubesense-Dashboards

Ready-made, read-only dashboards that KubeSense installs for every customer. The KubeSense API downloads this repository every 6 hours and stores each dashboard. Users can view and clone them but not edit them.

## Branches

The `dev` API reads `dev`, the `test` API reads `test`, and production reads `main`. Changes go into `dev` first and are promoted to `test`, then `main`.

## Adding a dashboard

1. Build the dashboard in KubeSense and use **Export**.
2. Save the exported file anywhere in this repo as a `.json` file. Folder names are up to you.
3. Export writes `preset` as a JSON string. Replace it with the object itself so pull requests show readable diffs. Both forms load the same.
4. Add a `meta` block to the file:

```json
{
  "meta": {
    "key": "aws-ec2-overview",
    "version": 1,
    "integration_id": "aws",
    "tags": ["aws", "ec2"]
  },
  "name": "AWS EC2 Overview",
  "description": "...",
  "preset": {
    "panels": [...],
    "gridLayout": [...],
    "variables": [...]
  }
}
```

- `key` is the dashboard's permanent identity. Never change it. Renaming the dashboard or moving the file is fine.
- `version` starts at 1. Raise it whenever you change the dashboard, otherwise the API keeps the old copy. Reformatting the file, or turning a string `preset` into an object, is not a change and needs no bump.
- `integration_id` is optional: `aws`, `gcp`, `azure`, `confluent`, `github`, `mongodbatlas` or `synthetics`. It groups the dashboard under that integration's tab on the Integrations page and gives it the logo. When `requires` is absent, it also means the dashboard needs that integration's check (see below). Leave it out for a dashboard that belongs to no integration.
- `requires` is optional. It says when the dashboard is copied into an install and shown:

```json
"requires": {
  "match": "any",
  "conditions": [
    { "check": "kubernetes" },
    { "metric": "kubesense_cloud_resource_metric{service=\"rds\"}" }
  ]
}
```

  - `match` is `any` (one condition is enough) or `all` (every condition must hold).
  - A `check` condition is one of `aws`, `gcp`, `azure`, `confluent`, `github`, `mongodbatlas`, `synthetics`, `kubernetes`, `rum_browser` or `rum_mobile`. `synthetics` counts as met while the install runs the Synthetics gateway (`synthetics.enabled` with a `synthetics.base_url`).
  - A `metric` condition is a MetricsQL series selector, with labels if you need them. It is met when the selector had any sample in the last 7 days.
  - With no `requires` and no `integration_id`, the dashboard is copied and shown everywhere. With no `requires` and an `integration_id`, the requirement is that integration's check.
  - The API re-checks every requirement on each sync. When one is no longer met, an already-copied dashboard is hidden and no new copies are made. If a check cannot be evaluated (an error, or the metrics store is off), nothing changes.
- Never put anything specific to one customer (cluster names, account IDs, hostnames) in a query, a filter default or a condition. This repository is public.
- To remove a dashboard, set `"retired": true` and raise `version`. Deleting the file does nothing.

## Checks

Every pull request and every push is checked by kubeapi's own validator. It is built from the kubeapi branch with the same name as the dashboards branch being changed, so a dashboard can be tested against an unmerged kubeapi change. When kubeapi has no such branch, it uses the branch being merged into (`dev` for a plain push). It refuses invalid dashboards, duplicate keys, unknown integrations, changes without a version bump and deleted keys.
