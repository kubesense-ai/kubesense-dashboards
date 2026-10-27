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
- `integration_id` is optional: `aws`, `gcp`, `azure`, `confluent`, `github` or `mongodbatlas`. The dashboard is copied into an install only once the customer connects an account of that integration, and is listed only while one is connected. Leave it out to copy and show the dashboard everywhere.
- To remove a dashboard, set `"retired": true` and raise `version`. Deleting the file does nothing.

## Checks

Every pull request and every push is checked by kubeapi's own validator. It is built from the kubeapi branch with the same name as the dashboards branch being changed, so a dashboard can be tested against an unmerged kubeapi change. When kubeapi has no such branch, it uses the branch being merged into (`dev` for a plain push). It refuses invalid dashboards, duplicate keys, unknown integrations, changes without a version bump and deleted keys.
