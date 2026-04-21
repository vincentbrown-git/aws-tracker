import boto3
import json
from datetime import datetime
from app.config import get_settings

settings = get_settings()

def serialize(obj):
    if isinstance(obj, datetime):
        return obj.isoformat()
    raise TypeError(f"Type {type(obj)} not serializable")

def clean(data):
    return json.loads(json.dumps(data, default=serialize))

def get_boto3_client(service: str):
    return boto3.client(
        service,
        region_name=settings.aws_region,
        aws_access_key_id=settings.aws_access_key_id,
        aws_secret_access_key=settings.aws_secret_access_key
    )

def scan_vpcs():
    ec2 = get_boto3_client("ec2")
    response = ec2.describe_vpcs()
    resources = []
    for vpc in response.get("Vpcs", []):
        name = next(
            (tag["Value"] for tag in vpc.get("Tags", []) if tag["Key"] == "Name"),
            None
        )
        resources.append({
            "resource_id":   vpc["VpcId"],
            "resource_type": "vpc",
            "name":          name,
            "region":        settings.aws_region,
            "az":            None,
            "state":         vpc.get("State"),
            "details":       clean(vpc)
        })
    return resources

def scan_subnets():
    ec2 = get_boto3_client("ec2")
    response = ec2.describe_subnets()
    resources = []
    for subnet in response.get("Subnets", []):
        name = next(
            (tag["Value"] for tag in subnet.get("Tags", []) if tag["Key"] == "Name"),
            None
        )
        resources.append({
            "resource_id":   subnet["SubnetId"],
            "resource_type": "subnet",
            "name":          name,
            "region":        settings.aws_region,
            "az":            subnet.get("AvailabilityZone"),
            "state":         subnet.get("State"),
            "details":       clean(subnet)
        })
    return resources

def scan_nat_gateways():
    ec2 = get_boto3_client("ec2")
    response = ec2.describe_nat_gateways()
    resources = []
    for nat in response.get("NatGateways", []):
        name = next(
            (tag["Value"] for tag in nat.get("Tags", []) if tag["Key"] == "Name"),
            None
        )
        resources.append({
            "resource_id":   nat["NatGatewayId"],
            "resource_type": "nat_gateway",
            "name":          name,
            "region":        settings.aws_region,
            "az":            None,
            "state":         nat.get("State"),
            "details":       clean(nat)
        })
    return resources

def scan_all():
    results = []
    results.extend(scan_vpcs())
    results.extend(scan_subnets())
    results.extend(scan_nat_gateways())
    return results
