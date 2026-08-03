#!/usr/bin/env python3
"""Attach the Cribbage+ products and submit the current app version for review.

App Store Connect submits reviewable product versions as separate review
submission items. The app version, subscription group version, monthly and
yearly subscription versions, and Lifetime in-app-purchase version all belong
to the same review submission for this app.

Pass --dry-run to inspect the planned attachments without changing ASC.
"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from asc_lib import (
    ASCClient,
    bearer_token,
    bundle_id_from_appfile,
    find_app,
    find_submittable_version,
    list_all,
    load_credentials,
)


BUNDLE = "com.jackwallner.cribbage"
SUBSCRIPTION_GROUP_NAME = "Cribbage+"
PRODUCTS = (
    ("com.jackwallner.cribbage.monthly", "subscriptionVersion", "subscription"),
    ("com.jackwallner.cribbage.yearly", "subscriptionVersion", "subscription"),
    ("com.jackwallner.cribbage.lifetime", "inAppPurchaseVersion", "iap"),
)
INCLUDE = "appStoreVersion,inAppPurchaseVersion,subscriptionVersion,subscriptionGroupVersion"
VERSION_STATES = (
    "PREPARE_FOR_SUBMISSION",
    "READY_FOR_REVIEW",
    "DEVELOPER_REJECTED",
    "REJECTED",
    "METADATA_REJECTED",
)


def review_items(client: ASCClient, submission_id: str) -> list[dict]:
    return list_all(
        client,
        f"/reviewSubmissions/{submission_id}/items?include={INCLUDE}&limit=200",
    )


def attached_version_ids(items: list[dict], relationship: str) -> set[str]:
    ids: set[str] = set()
    for item in items:
        data = item.get("relationships", {}).get(relationship, {}).get("data")
        if data:
            ids.add(data["id"])
    return ids


def add_item(
    client: ASCClient,
    submission_id: str,
    relationship: str,
    resource_type: str,
    resource_id: str,
) -> None:
    client.post(
        "/reviewSubmissionItems",
        {
            "data": {
                "type": "reviewSubmissionItems",
                "relationships": {
                    "reviewSubmission": {
                        "data": {"type": "reviewSubmissions", "id": submission_id}
                    },
                    relationship: {"data": {"type": resource_type, "id": resource_id}},
                },
            }
        },
    )


def find_open_submission(client: ASCClient, app_id: str) -> dict | None:
    submissions = list_all(client, f"/apps/{app_id}/reviewSubmissions?limit=50")
    return next(
        (s for s in submissions if s["attributes"].get("state") == "READY_FOR_REVIEW"),
        None,
    )


def find_product_resources(client: ASCClient, app_id: str) -> tuple[dict, dict, dict, dict]:
    iaps = list_all(client, f"/apps/{app_id}/inAppPurchasesV2?limit=200")
    iap = next(
        (p for p in iaps if p["attributes"].get("productId") == PRODUCTS[2][0]),
        None,
    )
    if not iap:
        raise SystemExit(f"error: ASC product missing: {PRODUCTS[2][0]}")

    subscriptions: dict[str, dict] = {}
    groups = list_all(client, f"/apps/{app_id}/subscriptionGroups?limit=50")
    group = next(
        (g for g in groups if g["attributes"].get("referenceName") == SUBSCRIPTION_GROUP_NAME),
        None,
    )
    if not group:
        raise SystemExit(f"error: ASC subscription group missing: {SUBSCRIPTION_GROUP_NAME}")

    for g in groups:
        for subscription in list_all(client, f"/subscriptionGroups/{g['id']}/subscriptions?limit=50"):
            product_id = subscription["attributes"].get("productId")
            if product_id in {PRODUCTS[0][0], PRODUCTS[1][0]}:
                subscriptions[product_id] = subscription
    missing = [product_id for product_id, _, _ in PRODUCTS[:2] if product_id not in subscriptions]
    if missing:
        raise SystemExit(f"error: ASC product(s) missing: {', '.join(missing)}")
    return iap, subscriptions[PRODUCTS[0][0]], subscriptions[PRODUCTS[1][0]], group


def version_candidates(client: ASCClient, resource: dict, kind: str) -> list[dict]:
    resource_id = resource["id"]
    if kind == "iap":
        return client.get_v2(f"/inAppPurchases/{resource_id}/versions?limit=50").get("data", [])
    if kind == "subscription":
        return client.get(f"/subscriptions/{resource_id}/versions?limit=50").get("data", [])
    return client.get(f"/subscriptionGroups/{resource_id}/versions?limit=50").get("data", [])


def choose_version(client: ASCClient, resource: dict, kind: str, label: str) -> dict:
    versions = version_candidates(client, resource, kind)
    for state in VERSION_STATES:
        candidates = [
            v for v in versions if v.get("attributes", {}).get("state") == state
        ]
        if candidates:
            return sorted(
                candidates,
                key=lambda v: v.get("attributes", {}).get("version", 0),
                reverse=True,
            )[0]
    raise SystemExit(f"error: no submittable ASC version exists for {label}")


def create_submission(client: ASCClient, app_id: str) -> dict:
    return client.post(
        "/reviewSubmissions",
        {
            "data": {
                "type": "reviewSubmissions",
                "attributes": {"platform": "IOS"},
                "relationships": {"app": {"data": {"type": "apps", "id": app_id}}},
            }
        },
    )["data"]


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    key_id, issuer_id, key_path = load_credentials()
    client = ASCClient(bearer_token(key_id, issuer_id, key_path))
    app = find_app(client, bundle_id_from_appfile())
    app_id = app["id"]
    app_version = find_submittable_version(client, app_id)
    if not app_version:
        print("No submittable app version.")
        return 1

    iap, monthly, yearly, group = find_product_resources(client, app_id)
    product_versions = (
        (monthly, "subscriptionVersion", "subscriptionVersions", PRODUCTS[0][0], "subscription"),
        (yearly, "subscriptionVersion", "subscriptionVersions", PRODUCTS[1][0], "subscription"),
        (iap, "inAppPurchaseVersion", "inAppPurchaseVersions", PRODUCTS[2][0], "iap"),
    )
    chosen_products = [
        (resource, relationship, resource_type, product_id, choose_version(client, resource, kind, product_id))
        for resource, relationship, resource_type, product_id, kind in product_versions
    ]
    group_version = choose_version(client, group, "group", SUBSCRIPTION_GROUP_NAME)

    submission = find_open_submission(client, app_id)
    if submission:
        submission_id = submission["id"]
        print(f"Reusing open reviewSubmission {submission_id}")
    elif args.dry_run:
        submission_id = "<new reviewSubmission>"
        print("Would create a new IOS reviewSubmission")
    else:
        submission = create_submission(client, app_id)
        submission_id = submission["id"]
        print(f"Created reviewSubmission {submission_id}")

    items = review_items(client, submission_id) if submission else []
    attached = {
        relationship: attached_version_ids(items, relationship)
        for relationship in (
            "appStoreVersion",
            "inAppPurchaseVersion",
            "subscriptionVersion",
            "subscriptionGroupVersion",
        )
    }

    print(
        f"App {app_id} version {app_version['attributes'].get('versionString')} "
        f"({app_version['id']}, state={app_version['attributes'].get('appStoreState')})"
    )

    attachments = [
        (
            "appStoreVersion",
            "appStoreVersions",
            app_version["id"],
            f"app version {app_version['attributes'].get('versionString')}",
        ),
        (
            "subscriptionGroupVersion",
            "subscriptionGroupVersions",
            group_version["id"],
            f"subscription group {SUBSCRIPTION_GROUP_NAME}",
        ),
    ]
    attachments.extend(
        (relationship, resource_type, version["id"], product_id)
        for _, relationship, resource_type, product_id, version in chosen_products
    )

    for relationship, resource_type, version_id, label in attachments:
        if version_id in attached[relationship]:
            print(f"already attached: {label} ({version_id})")
            continue
        if args.dry_run:
            print(f"would attach: {label} ({version_id})")
            continue
        try:
            add_item(client, submission_id, relationship, resource_type, version_id)
        except Exception as exc:
            print(f"ATTACH FAILED: {label}")
            print(str(exc)[:4000])
            return 2
        attached[relationship].add(version_id)
        print(f"attached: {label} ({version_id})")

    if args.dry_run:
        print("Dry run: nothing changed and the submission was not sent.")
        return 0

    try:
        result = client.patch(
            f"/reviewSubmissions/{submission_id}",
            {
                "data": {
                    "type": "reviewSubmissions",
                    "id": submission_id,
                    "attributes": {"submitted": True},
                }
            },
        )
        state = result["data"]["attributes"].get("state")
        print(f"SUBMITTED. reviewSubmission state = {state}")
        return 0
    except Exception as exc:
        print("SUBMIT FAILED (submission left open, nothing sent):")
        print(str(exc)[:4000])
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
