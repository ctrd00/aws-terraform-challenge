import boto3
from botocore.exceptions import ClientError

PARAMETER_NAME = "dynamic_string"
ssm = boto3.client("ssm")

def get_dynamic_string() -> str:
    response = ssm.get_parameter(Name=PARAMETER_NAME, WithDecryption=True)
    return response["Parameter"]["Value"]


def set_dynamic_string(value: str) -> None:
    ssm.put_parameter(
        Name=PARAMETER_NAME,
        Value=value,
        Type="String",
        Overwrite=True,
    )
