# Kubesense-Dashboards

Ready-made, read-only dashboards that KubeSense installs for every customer. The KubeSense API downloads this repository every 6 hours and stores each dashboard. Users can view and clone them but not edit them.

## Branches

The `dev` API reads `dev`, the `test` API reads `test`, and production reads `main`. Changes go into `dev` first and are promoted to `test`, then `main`.

## Adding a dashboard

1. Build the dashboard in KubeSense and use **Export**.
2. Save the exported file anywhere in this repo as a `.json` file. Folder names are up to you.
3. Add a `meta` block to the file:

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
  "preset": "..."
}
```

- `key` is the dashboard's permanent identity. Never change it. Renaming the dashboard or moving the file is fine.
- `version` starts at 1. Raise it whenever you change the file, otherwise the API keeps the old copy.
- `integration_id` is optional: `aws`, `gcp`, `azure`, `confluent` or `github`. The dashboard is shown only while the customer has at least one account of that integration connected. Leave it out to show the dashboard to everyone.
- To remove a dashboard, set `"retired": true` and raise `version`. Deleting the file does nothing.

## Checks

Every pull request is checked by kubeapi's own validator, built from the kubeapi branch with the same name as the target branch. It refuses invalid dashboards, duplicate keys, unknown integrations, changes without a version bump and deleted keys.
