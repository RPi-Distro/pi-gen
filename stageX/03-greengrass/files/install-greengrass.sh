#!/bin/sh
#
# Copyright 2019 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# GreengrassDeviceSetup helps to simplify the getting started process with AWS IoT Greengrass Core.
#
# This is the wrapper shell script part, the entry point for GreengrassDeviceSetup.
# This shell script executes a series of commands to check if the device environment is ready to run the core Python
# logic. Specifically, it will:
# 1. check and try install/bootstrap Python 3.7 if it is not available via the identified package management tool.
# 2. fallback to use Python 2 if Python 3.7 is not available and cannot be installed.
# 3. install the following Python dependencies required by core Python logic:
#  1. boto3
#  2. distro
#  3. configparser
#  4. retrying
#  5. yaspin
# 4. kick off the core Python logic
#
# The wrapper shell script has the following assumptions:
#
# Commands assume to be present on the device:
# 1. echo
# 2. exit
# 3. export
# 4. type
# 5. rm
#
# The script promptly checks the existence of the following commands:
# 1. id
# 2. cat
# 3. cd
# 4. date
# 5. mkdir
# 6. printf
# 7. sleep
# 8. kill
# 9. trap
# 10. seq
# 11. find
# Commands below are checked in core Python logic
# 11. chmod
# 12. sed
# 13. sysctl
# 14. grep
#

# Error codes
NO_ERR=0
ERR_NO_ROOT=200
ERR_NO_TMP_DIR=199
ERR_LOG_FILE=198
ERR_PREREQ=197
ERR_PKG_TOOL=196
ERR_UPDATE_PKG_LIST=195
ERR_PYTHON=194
ERR_WGET=193
ERR_GET_PIP_PY=192
ERR_BOTO3=191
ERR_DISTRO=190
ERR_CD=189
ERR_CONFIGPARSER=188
ERR_RETRYING=187
ERR_YASPIN=186
ERR_SETUPTOOLS=185
ERR_WHEEL=184
ERR_PARAM=183

# Constants
GG_DEVICE_SETUP_VERSION="1.0.0"
ECHO_HEADER="[GreengrassDeviceSetup]"
TMP_DIR="/tmp"
GET_PIP_PY="get-pip.py"
GET_PIP_PY_DOWNLOAD_DIR="$TMP_DIR"
GET_PIP_PY_URL="https://bootstrap.pypa.io/$GET_PIP_PY"
ID="id"
CAT="cat"
CD="cd"
DATE="date"
MKDIR="mkdir"
APT="apt"
APT_GET="apt-get"
YUM="yum"
OPKG="opkg"
PYTHON="python"
PYTHON27="${PYTHON}2.7"
PYTHON3="${PYTHON}3"
PYTHON37="${PYTHON}3.7"
PYTHON_USED="python"
PIP="pip"
RM="rm"
PIP_INSTALL_PATH="$TMP_DIR/greengrass-device-setup-bootstrap-tmp"
PIP_IMPORT_PATH="$TMP_DIR/greengrass-device-setup-bootstrap-tmp/lib/python3.7/site-packages"
GG_DEVICE_SETUP_SHELL_LOG_PATH="$TMP_DIR"
WGET="wget"
BOTO3="boto3"
DISTRO="distro"
CONFIGPARSER="ConfigParser"
RETRYING="retrying"
SPIN_PID="spin_pid"
SETUPTOOLS="setuptools"
WHEEL="wheel"
YASPIN="yaspin"

# Params
PKG_TOOL="@missing@"
PKG_LIST_UPDATED=1  # init to non-zero, which means package list is never updated
MY_PWD="@missing@"
GG_DEVICE_SETUP_SHELL_LOG_FILE="@missing@"
LOG_MSG="@missing@"
CMD_EXIT_CODE=1  # init to non-zero to prevent blind passes
SLEEP_TIME=0.1

# Python code
CODE=$($CAT <<EOF
# Copyright 2019 Amazon.com, Inc. or its affiliates. All Rights Reserved.

# GreengrassDeviceSetup helps to simplify the getting started process with AWS IoT Greengrass Core.
#
# This is the single Python script to master the core logic to bootstrap Greengrass Core on the target device.
# It is invoked by GreengrassDeviceSetup wrapper shell script.
#
# It has the following assumptions/limits:
# 1. Python should be fully bootstrapped on the target device and have installed all of GreengrassDeviceSetup Python
#    script required libraries.
#    GreengrassDeviceSetup Python script will NOT attempt to install any of its required dependencies. Python
#    bootstrapping should be handled by GreengrassDeviceSetup wrapper shell script or explicitly by the user.
# 2. GreengrassDeviceSetup requires sudo permission to run.
# 3. Basic linux commands and tools should be available on the target device. GreengrassDeviceSetup Python script will
#    NOT attempt to install any of these basic linux commands from package management tool. A full list could be found
#    in SUPPORTED_PKG_MANAGEMENT_TOOLS and REQUIRED_LINUX_CMD.
# 4. GreengrassDeviceSetup Python script only bootstraps a device from scratch. It will not pick up resources that
#    exist on the device or pre-created in the cloud.
# 5. GreengrassDeviceSetup Python script will only pull down the latest version of GGC software.
#
# It performs the following steps:
# 1. Environment Pre-validation: check if all the required basic linux commands/tools are available on the device.
# 2. Greengrass Environment Bootstrap: install and configure environment to run GGC software.
# 3. Greengrass Cloud Bootstrap: create and configure required resources in AWS IoT Greengrass cloud for this GGC.
# 4. Greengrass Core Kick-off: start GGC on the device.
# 5. PostBootstrap: execute extra tasks remained after the above bootstrap, e.g., triggering and waiting for a
#    deployment.


import argparse
import copy
import datetime
import grp
import json
import logging
import os
import platform
import pwd
import random
import re
import string
import subprocess
import sys
import tarfile
import tempfile
import uuid
from zipfile import ZipFile

import boto3
import distro
from botocore.exceptions import ClientError
from retrying import retry
from yaspin import yaspin

if sys.version_info.major < 3:
    import ConfigParser
    from urllib import urlretrieve

    INPUT = raw_input
    # HelloWorld Lambda function uses features of python 3 and will break if run on python 2,
    # since Python2.7 is approaching its end-of-life.

else:
    import configparser
    from urllib.request import urlretrieve

    INPUT = input  # Py3.x no longer has raw_input

NAME_PREFIX = "GreengrassDeviceSetup_"
NUM_REGEX = "([0-9]+)"
INT_REGEX = NUM_REGEX + "$"
AWS_REGION_REGEX = "([a-z]{2}(-[a-z]+)+-[0-9]{1})"
GGC_VERSION_REGEX = "^" + NUM_REGEX + "\." + NUM_REGEX + "\." + NUM_REGEX + "$"  # X.Y.Z
STDOUT_FORMAT = "[GreengrassDeviceSetup] %(message)s"
LOGGING_FORMAT = "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
IAM = "iam"
IOT = "iot"
LAMBDA = "lambda"
GREENGRASS = "greengrass"

DEFAULT_AWS_REGION = "us-west-2"
DEFAULT_GROUP_NAME = NAME_PREFIX + "Group_" + str(uuid.uuid4())
DEFAULT_CORE_NAME = NAME_PREFIX + "Core_" + str(uuid.uuid4())
DEFAULT_GGC_ROOT_PATH = "/"

GGC_DEPENDENCY_CHECKER_FORMAT = "greengrass-dependency-checker-GGCv{}"
GGC_DEPENDENCY_CHECKER_ZIP_FORMAT = GGC_DEPENDENCY_CHECKER_FORMAT + ".zip"
GGC_DEPENDENCY_CHECKER_REMOTE_LOCATION_FORMAT = "https://github.com/aws-samples/aws-greengrass-samples/raw/master/" + \
                                                GGC_DEPENDENCY_CHECKER_ZIP_FORMAT
LATEST_GG_PYTHON_SDK_REMOTE_LOCATION = "https://github.com/aws/aws-greengrass-core-sdk-python/archive/master.zip"
LATEST_GG_HELLO_WORLD_LAMBDA_REMOTE_LOCATION = "https://raw.githubusercontent.com/aws-samples/aws-greengrass-samples/" \
                                               "master/hello-world-python/greengrassHelloWorld.py"
CGROUPFS_MOUNT_SCRIPT_REMOTE_LOCATION = "https://raw.githubusercontent.com/tianon/cgroupfs-mount/" \
                                        "951c38ee8d802330454bdede20d85ec1c0f8d312/cgroupfs-mount"
GGC_SOFTWARE_REMOTE_LOCATION_FORMAT = "https://d1onfpft10uf5o.cloudfront.net/greengrass-core/downloads/" \
                                      "{0}/greengrass-{1}-{2}-{0}.tar.gz"
ATS_ROOT_CA_RSA_2048_REMOTE_LOATION = "https://www.amazontrust.com/repository/AmazonRootCA1.pem"

LATEST_GGC_VERSION_AWARE = "1.10.0"  # TODO : Automatically check the latest version
# TODO: The following should be updated per GreengrassDeviceSetup release through its release configuration
# https://issues.amazon.com/issues/GG-24677

DEFAULT_LOG_PATH = "./"
DEFAULT_DEPLOYMENT_TIMEOUT = 3 * 60  # 3 minutes
DEFAULT_GGC_MQTT_KEEP_ALIVE = 600  # 600 seconds
CONFIG_DEPLOYMENT_TIMEOUT = DEFAULT_DEPLOYMENT_TIMEOUT
DEFAULT_HAS_HELLO_WORLD_LAMBDA = False

CMD_BOOTSTRAP_GG = "bootstrap-greengrass"
CMD_BOOTSTRAP_GG_INTERACTIVE = CMD_BOOTSTRAP_GG + "-interactive"

KEY_SUB_CMD = "subcommand"
KEY_HAS_HELLO_WORLD_LAMBDA = "HasHelloWorldLambda"
KEY_AWS_ACCESS_KEY_ID = "AwsAccessKeyId"
KEY_AWS_SECRET_ACCESS_KEY = "AwsSecretAccessKey"
KEY_AWS_SESSION_TOKEN = "AwsSessionToken"
KEY_AWS_REGION = "Region"
KEY_GROUP_NAME = "GroupName"
KEY_CORE_NAME = "CoreName"
KEY_GGC_ROOT_PATH = "GGCRootPath"
KEY_GGC_VERSION = "GGCVersion"
KEY_DEPLOYMENT_TIMEOUT = "DeploymentTimeout"
KEY_LOG_PATH = "LogPath"
KEY_LOG_FILE = "LogFile"

KEY_LOGGER = "Logger"
KEY_DEVICE_PLATFORM = "DevicePlatform"
KEY_ARCHITECTURE = "Architecture"
KEY_DISTRIBUTION = "Distribution"
KEY_PKG_MANAGEMENT_TOOL = "PackageManagementTool"
KEY_ADD_USER_TOOL = "AddUserTool"
KEY_ADD_GROUP_TOOL = "AddGroupTool"
KEY_NEED_REBOOT = "NeedReboot"
KEY_RECOVER_OR_REBOOT_FROM_LAST_RUN = "RecoverFromReboot"
KEY_BOTO_SESSION = "BotoSession"
KEY_GG_ACCOUNT_SERVICE_ROLE = "GGServiceRole"
KEY_LAMBDA_EXECUTION_ROLE = "LambdaExecutionRole"
KEY_CORE_THING_ARN = "CoreThingArn"
KEY_CORE_CERT_ARN = "CoreCertArn"
KEY_CORE_CERT_ID = "CoreCertId"
KEY_CORE_CERT_PEM = "CoreCertPem"
KEY_CORE_CERT_FILE_LOCATION = "CoreCertFilePath"
KEY_CORE_PRIV_KEY = "CorePrivKey"
KEY_CORE_PRIV_KEY_FILE_LOCATION = "CorePrivKeyFilePath"
KEY_ROOT_CA_FILE_LOCATION = "RootCAFilePath"
KEY_CORE_DEF_VER_ARN = "CoreDefinitionVersionArn"
KEY_FUNCTION_DEF_VER_ARN = "FunctionDefinitionVersionArn"
KEY_SUBSCRIPTION_VER_ARN = "SubscriptionVersionArn"
KEY_LOGGER_VER_ARN = "LoggerVersionArn"
KEY_GROUP_ID = "GroupId"
KEY_GROUP_DEF_VER_ARN = "GroupVersionArn"
KEY_GROUP_DEF_VER_ID = 'GroupVersionId'
KEY_DEPLOYMENT_ARN = 'DeploymentArn'
KEY_DEPLOYMENT_ID = 'DeploymentId'
KEY_IOT_DATA_ENDPOINT = "IotDataEndpoint"
KEY_LOGGER_NAME = "LoggerName"
KEY_USE_SYSTEMD = "UseSystemd"
KEY_HELLO_WORLD_LAMBDA_VERSIONED_ARN = "HelloWorldLambdaVersionedArn"
KEY_IS_CONFIG_FILE_EXIST = "IsConfigFileExist"
KEY_CONFIG_INFO_FILE_PATH = ""
KEY_CONTINUE_WITH_OLD_CONFIG_OR_NOT = "ContinueRebootOrNot"
KEY_RESPONSE_METADATA = "ResponseMetadata"
KEY_HTTP_STATUS_CODE = "HTTPStatusCode"
KEY_VERBOSE = "verbose"

REQUIRED_LINUX_CMD = {
    "chmod", "sysctl", "grep", "sed"
}
PLATFORM_X86_64 = "x86_64"
PLATFORM_ARMV7L = "armv7l"
PLATFORM_AARCH64 = "aarch64"
SUPPORTED_PLATFORMS = {
    PLATFORM_X86_64,
    PLATFORM_ARMV7L,
    PLATFORM_AARCH64,
}

PKG_MANAGEMENT_TOOL_APT = "apt"
PKG_MANAGEMENT_TOOL_APT_GET = "apt-get"
PKG_MANAGEMENT_TOOL_YUM = "yum"
PKG_MANAGEMENT_TOOL_OPKG = "opkg"
SUPPORTED_PKG_MANAGEMENT_TOOLS = {
    PKG_MANAGEMENT_TOOL_APT,
    PKG_MANAGEMENT_TOOL_APT_GET,
    PKG_MANAGEMENT_TOOL_YUM,
    PKG_MANAGEMENT_TOOL_OPKG,
}

UPDATE = "update"
USER_ADD = "useradd"
GROUP_ADD = "groupadd"
ADD_USER = "adduser"
ADD_GROUP = "addgroup"
# runbook that captures how to install all kinds of dependencies
OPKG_INSTALL_RUNBOOK = {
    UPDATE: "opkg update",
    USER_ADD: "opkg install shadow-useradd",
    GROUP_ADD: "opkg install shadow-groupadd",
}
YUM_INSTALL_RUNBOOK = {
    UPDATE: "yum -y update",
    USER_ADD: "yum -y install shadow-utils",
    GROUP_ADD: "yum -y install shadow-utils",
}
APT_GET_INSTALL_RUNBOOK = {
    UPDATE: "apt-get -y update",
}
INSTALL_RUNBOOKS = {
    PKG_MANAGEMENT_TOOL_APT: APT_GET_INSTALL_RUNBOOK,  # apt-get is the lower level backend for apt
    PKG_MANAGEMENT_TOOL_APT_GET: APT_GET_INSTALL_RUNBOOK,
    PKG_MANAGEMENT_TOOL_YUM: YUM_INSTALL_RUNBOOK,
    PKG_MANAGEMENT_TOOL_OPKG: OPKG_INSTALL_RUNBOOK,
}

AWS = "aws"
AWS_CN = "aws-cn"
AWS_US_GOV = "aws-us-gov"
PARTITION_OVERRIDES = {
    "cn-north-1": AWS_CN,
    "us-gov-west-1": AWS_US_GOV,
}


def main():
    try:
        GGCBootstrapper_1_x().install()
    except StepError as e:
        print(e)
    except Exception as e:
        print("Unexpected error: %s" %e)

# aiming at bootstrapping GGC v1.x
class GGCBootstrapper_1_x(object):

    def __init__(self):
        self._args = {}
        # step sequence matters
        # Steps for Installation
        self._install_steps = [
            ArgsCollection,
            EnvironmentPreValidation,
            GreengrassEnvironmentBootstrap,
            CoreSoftwareBootstrap,
        ]
        # Steps for Bootstrapping
        self._boostrap_steps = [
            ArgsCollection,
            EnvironmentPreValidation,
            GreengrassEnvironmentBootstrap,
            GreengrassCloudBootstrap,
            GreengrassCoreKickoff,
            PostBootstrap,
        ]

    def install(self):
        for step in self._install_steps:
            self._args = step(self._args).execute()

    def bootstrap(self):
        for step in self._boostrap_steps:
            self._args = step(self._args).execute()


# bootstrap steps
class Step(object):

    def __init__(self, args):
        self._args = args

    def execute(self):
        return self._args

    @staticmethod
    def cmd_exist(cmd):
        code, _, _ = Step.run_linux_cmd("type {} > /dev/null 2>&1".format(cmd))
        return code == 0

    @staticmethod
    def run_linux_cmd_raise_on_failure(cmd_string, err_code, err_msg):
        ret_code, std_out, std_err = Step.run_linux_cmd(cmd_string)
        if ret_code != 0:
            raise StepError(code=err_code, message=err_msg + " Stdout: {} Stderr: {}".format(std_out, std_err))
        return ret_code, std_out, std_err

    @staticmethod
    def run_linux_cmd(cmd_string):
        proc = subprocess.Popen(cmd_string, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
        std_out, std_err = proc.communicate()
        return proc.returncode, std_out, std_err

    @staticmethod
    def get_random_string(length):
        return "".join(random.sample(string.ascii_letters + string.digits, length))


# args validators
def _validate_with_regex(val, regex):
    return val is not None and re.compile(regex).match(val) is not None


def validate_yes_or_no(val):
    return val == "yes" or val == "no"


def validate_string_not_none_non_empty(val):
    return val is not None and len(val) > 0


def validate_aws_region(val):
    return _validate_with_regex(val, AWS_REGION_REGEX)


def validate_ggc_version(val):
    return _validate_with_regex(val, GGC_VERSION_REGEX)


def validate_int_string(val):
    return _validate_with_regex(val, INT_REGEX)


class ArgsCollection(Step):
    ARGS_SHOULD_ALWAYS_RETRY = {KEY_HAS_HELLO_WORLD_LAMBDA}
    ARG_DEFAULTS = {
        KEY_HAS_HELLO_WORLD_LAMBDA: DEFAULT_HAS_HELLO_WORLD_LAMBDA,
        KEY_AWS_REGION: DEFAULT_AWS_REGION,
        KEY_GROUP_NAME: DEFAULT_GROUP_NAME,
        KEY_CORE_NAME: DEFAULT_CORE_NAME,
        KEY_GGC_ROOT_PATH: DEFAULT_GGC_ROOT_PATH,
        KEY_GGC_VERSION: LATEST_GGC_VERSION_AWARE,
        KEY_DEPLOYMENT_TIMEOUT: DEFAULT_DEPLOYMENT_TIMEOUT,
        KEY_LOG_PATH: DEFAULT_LOG_PATH,
    }
    ARG_MESSAGES = {
        KEY_HAS_HELLO_WORLD_LAMBDA: "Do you want to include a Hello World Lambda function and "
                                    "deploy the Greengrass group? Enter 'yes' or 'no'.",
        KEY_AWS_ACCESS_KEY_ID: "Enter your AWS access key ID, or press 'Enter' to read it from"
                               " your environment variables.",
        KEY_AWS_SECRET_ACCESS_KEY: "Enter your AWS secret access key, or press 'Enter' to "
                                   "read it from your environment variables.",
        KEY_AWS_SESSION_TOKEN: "Enter your AWS session token, which is required only when you are "
                               "using temporary security credentials. Press 'Enter' to read it from "
                               "your environment variables or if the session token is not required.",
        KEY_AWS_REGION: "Enter the AWS Region where you want to create a Greengrass group, "
                        "or press 'Enter' to use '{}'.".format(DEFAULT_AWS_REGION),
        KEY_GROUP_NAME: "Enter a name for the Greengrass group, or press 'Enter' to use '{}'.".format(DEFAULT_GROUP_NAME),
        KEY_CORE_NAME: "Enter a name for the Greengrass core, or press 'Enter' to use '{}'.".format(DEFAULT_CORE_NAME),
        KEY_GGC_ROOT_PATH: "Enter the installation path for the Greengrass core software, "
                           "or press 'Enter' to use '{}'.".format(DEFAULT_GGC_ROOT_PATH),
        KEY_GGC_VERSION: "Enter a number for the Greengrass core version,"
                         " or press 'Enter' to use latest version '{}'.".format(LATEST_GGC_VERSION_AWARE),
        KEY_DEPLOYMENT_TIMEOUT: "Enter a deployment timeout (in seconds), "
                                "or press 'Enter' to use '{}'.".format(DEFAULT_DEPLOYMENT_TIMEOUT),
        KEY_LOG_PATH: "Enter the path for the Greengrass environment setup log file, "
                      "or press 'Enter' to use '{}'. ".format(DEFAULT_LOG_PATH),
        KEY_CONTINUE_WITH_OLD_CONFIG_OR_NOT: "Do you want to reuse the configuration from your previous session? "
                                             "Enter 'yes' to reuse the configuration or 'no' to restart the installation.",
    }

    REQUIRED_CREDENTIALS_ARGS_IN_ORDER = [
        KEY_AWS_ACCESS_KEY_ID,
        KEY_AWS_SECRET_ACCESS_KEY,
        KEY_AWS_SESSION_TOKEN,
    ]

    REQUIRED_ARGS_IN_ORDER = [
        KEY_AWS_REGION,
        KEY_GROUP_NAME,
        KEY_CORE_NAME,
        KEY_GGC_ROOT_PATH,
        KEY_GGC_VERSION,
        KEY_HAS_HELLO_WORLD_LAMBDA,
        KEY_DEPLOYMENT_TIMEOUT,
        KEY_LOG_PATH,
    ]

    ARG_VALIDATORS = {
        KEY_HAS_HELLO_WORLD_LAMBDA: validate_yes_or_no,
        KEY_CONTINUE_WITH_OLD_CONFIG_OR_NOT: validate_yes_or_no,
        KEY_AWS_REGION: validate_aws_region,
        KEY_GROUP_NAME: validate_string_not_none_non_empty,
        KEY_CORE_NAME: validate_string_not_none_non_empty,
        KEY_GGC_ROOT_PATH: validate_string_not_none_non_empty,
        KEY_GGC_VERSION: validate_ggc_version,
        KEY_DEPLOYMENT_TIMEOUT: validate_int_string,
        KEY_LOG_PATH: validate_string_not_none_non_empty,
    }
    ARG_CONVERTERS = {
        KEY_HAS_HELLO_WORLD_LAMBDA: lambda x: x == "yes" or x is True,
        KEY_DEPLOYMENT_TIMEOUT: lambda x: int(x),
        KEY_CONTINUE_WITH_OLD_CONFIG_OR_NOT: lambda x: x == "yes",
    }

    TMP_DIR = tempfile.gettempdir()
    GG_DEVICE_SETUP_CONFIG_FILE = "GreengrassDeviceSetup.config.info"

    def __init__(self, args=None):
        super(ArgsCollection, self).__init__(args)

    def execute(self):
        self._args = ArgsCollection.collect_cmdline_args()
        ArgsCollection.pre_validation()
        ArgsCollection.check_config_info_file(self._args)
        ArgsCollection.collect_or_generate_args(self._args)
        ArgsCollection.prepare_logger(self._args)
        ArgsCollection.log_config_info_source(self._args)
        ArgsCollection.set_deploy_time_out(self._args)
        ArgsCollection.validate_latest_ggc_version(self._args)
        ArgsCollection.disable_helloworld_lambda_if_runtime_python27(self._args)

        return self._args

    # Check whether the conditions are suitable for GGC running. Stop immediately, if checking has failed
    @staticmethod
    def pre_validation():
        if ArgsCollection.check_whether_ggc_is_running() is True:
            print("GreengrassDeviceSetup has stopped because the Greengrass core software is already running on the device.")
            exit(StepError.ERR_ENV_PREVALIDATE)

    @staticmethod
    def check_whether_ggc_is_running():
        proc_str = "/proc"
        pattern = re.compile('.*/greengrass/ggc/packages/[0-9]+\.[0-9]+\.[0-9]+/bin/daemon.*')
        pids = [pid for pid in os.listdir(proc_str) if pid.isdigit()]
        for pid in pids:
            try:
                process = open(os.path.join(proc_str, pid, 'cmdline'), 'rb').read().decode('utf-8')
                if pattern.match(process):
                    return True
            except IOError:
                # proc has already terminated
                continue
        return False

    @classmethod
    def check_config_info_file(cls, args):
        gg_device_setup_config_info_file = os.path.abspath(
            os.path.join("./", ArgsCollection.GG_DEVICE_SETUP_CONFIG_FILE))
        args[KEY_CONFIG_INFO_FILE_PATH] = gg_device_setup_config_info_file

        args[KEY_IS_CONFIG_FILE_EXIST] = os.path.exists(args[KEY_CONFIG_INFO_FILE_PATH])
        args[KEY_RECOVER_OR_REBOOT_FROM_LAST_RUN] = False
        if args[KEY_IS_CONFIG_FILE_EXIST]:  # The device should has been rebooted
            # if judgement is False, the previous config info would not be reused
            if not ArgsCollection._collect_args_helper(args, KEY_CONTINUE_WITH_OLD_CONFIG_OR_NOT):
                remove_file_or_dir(args[KEY_CONFIG_INFO_FILE_PATH])
            else:
                args[KEY_RECOVER_OR_REBOOT_FROM_LAST_RUN] = True
                # Read the customer's inputs from the file "GreengrassDeviceSetup.config.info"
                ArgsCollection.read_config_info_file(args)

    @classmethod
    def read_config_info_file(cls, args):
        gg_device_setup_config_info_file = args[KEY_CONFIG_INFO_FILE_PATH]
        with open(gg_device_setup_config_info_file, 'r') as f:
            inputs_before_reboot = json.load(f)
            for key, value in inputs_before_reboot.items():
                converter = ArgsCollection.ARG_CONVERTERS.get(key, lambda x: x)
                stored_input = value
                args[key] = converter(stored_input)

    @classmethod
    def collect_cmdline_args(cls, inputs=None):
        arg_parser = argparse.ArgumentParser()

        subparsers = arg_parser.add_subparsers(dest=KEY_SUB_CMD)

        # TODO: Expand to have more sub-commands per new features
        ArgsCollection._build_subcommand_bootstrap_gg(subparsers)
        ArgsCollection._build_subcommand_bootstrap_gg_interactive(subparsers)

        # make parsed args into dict and get a deep copy of it so as not to mess around with arg parsing results
        return copy.deepcopy(vars(arg_parser.parse_args(args=inputs)))

    @classmethod
    def _build_subcommand_bootstrap_gg(cls, subparsers):
        subparser = subparsers.add_parser(CMD_BOOTSTRAP_GG)
        subparser.add_argument("--hello-world-lambda", action="store_true", required=False,
                               dest=KEY_HAS_HELLO_WORLD_LAMBDA,
                               default=DEFAULT_HAS_HELLO_WORLD_LAMBDA,
                               help="If specified, a Hello World Lambda function is included in the Greengrass group. "
                                    "This function continuously publishes MQTT messages to the "
                                    "'hello/world' topic through the Greengrass core.")
        subparser.add_argument("--aws-access-key-id", action="store", required=False, dest=KEY_AWS_ACCESS_KEY_ID,
                               help="(string) The access key ID from the user's AWS account. This is required only to"
                                    " enter the access key ID as an input value "
                                    "(not from environment variables).")
        subparser.add_argument("--aws-secret-access-key", action="store", required=False,
                               dest=KEY_AWS_SECRET_ACCESS_KEY,
                               help="(string) The secret access key from the user's AWS account. "
                                    "This is required only to enter the secret access key as an input value "
                                    "(not from environment variables).")
        subparser.add_argument("--aws-session-token", action="store", required=False, dest=KEY_AWS_SESSION_TOKEN,
                               help="(string) [Optional] The session token from the user's AWS account. "
                                    "This is required only when you are using temporary security credentials and "
                                    "to enter session token as an input value (not from environment variables).")
        subparser.add_argument("--region", action="store", required=False, dest=KEY_AWS_REGION,
                               default=DEFAULT_AWS_REGION,
                               help="(string) The AWS Region where the Greengrass group should be created. "
                                    "Defaults to 'us-west-2'.")
        subparser.add_argument("--group-name", action="store", required=False, dest=KEY_GROUP_NAME,
                               help="(string) The name of the Greengrass group. "
                                    "Defaults to 'GreengrassDeviceSetup_Group_<guid>'.")
        subparser.add_argument("--core-name", action="store", required=False, dest=KEY_CORE_NAME,
                               help="(string) The thing name of the Greengrass core. "
                                    "Defaults to 'GreengrassDeviceSetup_Core_<guid>'.")
        subparser.add_argument("--ggc-root-path", action="store", required=False, dest=KEY_GGC_ROOT_PATH,
                               default=DEFAULT_GGC_ROOT_PATH,
                               help="(string) The location where the Greengrass core software should be installed. "
                                    "Defaults to '/'.")
        subparser.add_argument("--ggc-version", action="store", required=False, dest=KEY_GGC_VERSION,
                               default=LATEST_GGC_VERSION_AWARE,
                               help="(string) The version of Greengrass core software that GreengrassDeviceSetup "
                                    "should install. Defaults to the latest version."
                                    "This option is currently not supported and is reserved for future use.")
        subparser.add_argument("--deployment-timeout", action="store", type=int, required=False,
                               default=DEFAULT_DEPLOYMENT_TIMEOUT,
                               dest=KEY_DEPLOYMENT_TIMEOUT,
                               help="(integer) The number of seconds before GreengrassDeviceSetup stops checking "
                                    "the status of the Greengrass group deployment. This is used only when the "
                                    "Greengrass group includes the Hello World Lambda function. "
                                    "Otherwise, the group is not deployed. Defaults to '180'.")
        subparser.add_argument("--log-path", action="store", required=False, dest=KEY_LOG_PATH,
                               default=DEFAULT_LOG_PATH,
                               help="(string) The location of the log file that contains information about "
                                    "Greengrass environment setup operations. Defaults to './'.")
        subparser.add_argument("--verbose", action="store_true", dest=KEY_VERBOSE, help="Makes GreengrassDeviceSetup"
                               " verbose during the operation. Useful for debugging and seeing what's going "
                               "on 'under the  hood'.")

    @classmethod
    def _build_subcommand_bootstrap_gg_interactive(cls, subparsers):
        subparser = subparsers.add_parser(CMD_BOOTSTRAP_GG_INTERACTIVE)
        subparser.add_argument("--verbose", action="store_true", dest=KEY_VERBOSE, help="Makes GreengrassDeviceSetup"
                               " verbose during the operation. Useful for debugging and seeing what's going "
                               "on 'under the  hood'.")

    @classmethod
    def collect_or_generate_args(cls, args):
        if args.get(KEY_SUB_CMD) == CMD_BOOTSTRAP_GG_INTERACTIVE:
            ArgsCollection._collect_args_from_input(args)
        else:
            # not validating credentials as we only install
            # ArgsCollection.validate_credentials(args)
            ArgsCollection._set_args_to_default_if_missing(args)

    @classmethod
    def _collect_args_from_input(cls, args):
        for key in cls.REQUIRED_CREDENTIALS_ARGS_IN_ORDER:
            if not args[KEY_RECOVER_OR_REBOOT_FROM_LAST_RUN] or (key not in cls.ARG_VALIDATORS):
                args[key] = ArgsCollection._collect_args_helper(args, key)
        ArgsCollection.validate_credentials(args)
        for key in cls.REQUIRED_ARGS_IN_ORDER:
            if not args[KEY_RECOVER_OR_REBOOT_FROM_LAST_RUN] or (key not in cls.ARG_VALIDATORS):
                args[key] = ArgsCollection._collect_args_helper(args, key)

    @classmethod
    def _collect_args_helper(cls, args, key):
        if key == KEY_HAS_HELLO_WORLD_LAMBDA and not (sys.version_info.major == 3 and sys.version_info.minor == 7):
            return DEFAULT_HAS_HELLO_WORLD_LAMBDA

        if key == KEY_GGC_VERSION:
            return LATEST_GGC_VERSION_AWARE

        msg = cls.ARG_MESSAGES[key]
        converter = cls.ARG_CONVERTERS.get(key, lambda x: x)
        should_retry = True
        validate = cls.ARG_VALIDATORS.get(key, lambda x: True)
        while should_retry:
            print(msg)
            input_val = INPUT()
            if not validate(input_val):

                if key in cls.ARGS_SHOULD_ALWAYS_RETRY:  # for those that always need valid inputs from user
                    print("Invalid input.")
                    continue

                default_val = cls.ARG_DEFAULTS.get(key, None)
                if len(input_val) > 0 or default_val is None:
                    print("Invalid input.")
                    continue
                input_val = default_val  # received newline from stdin, use default
            should_retry = False
        return converter(input_val)

    @classmethod
    def _check_both_exist_access_id_and_secret_key(cls, args):
        if not args[KEY_AWS_ACCESS_KEY_ID] or not args[KEY_AWS_SECRET_ACCESS_KEY]:
            args[KEY_AWS_SESSION_TOKEN] = None
            return False
        return True

    @classmethod
    def _check_key_in_env(cls, args):
        args[KEY_AWS_ACCESS_KEY_ID] = os.environ.get('AWS_ACCESS_KEY_ID')
        args[KEY_AWS_SECRET_ACCESS_KEY] = os.environ.get('AWS_SECRET_ACCESS_KEY')
        args[KEY_AWS_SESSION_TOKEN] = os.environ.get('AWS_SESSION_TOKEN')
        return cls._check_both_exist_access_id_and_secret_key(args)

    @classmethod
    def validate_credentials(cls, args):
        # Check custom config
        if cls._check_both_exist_access_id_and_secret_key(args):
            return
        # Check environment variables
        if cls._check_key_in_env(args):
            return
        err_msg = "The credentials were not acquired by GreengrassDeviceSetup."
        raise StepError(code=StepError.ERR_INVALID_CREDENTIALS, message=err_msg)

    @classmethod
    def _set_args_to_default_if_missing(cls, args):
        for key in cls.ARG_VALIDATORS.keys():
            default_val = cls.ARG_DEFAULTS.get(key)
            if args.get(key) is None and default_val is not None:
                args[key] = default_val

    @classmethod
    def prepare_logger(cls, args):
        verbose_name = "VERBOSE"
        verbose_logging_level = 15
        logging.addLevelName(verbose_logging_level, verbose_name)

        def verbose(self, message, *args, **kws):
            if self.isEnabledFor(verbose_logging_level):
                self._log(verbose_logging_level, message, args, **kws)

        logging.Logger.verbose = verbose

        root_logger = logging.getLogger(__name__)
        root_logger.setLevel(logging.DEBUG)
        args[KEY_LOGGER] = root_logger

        logging_formatter = logging.Formatter(LOGGING_FORMAT)
        stdout_formatter = logging.Formatter(STDOUT_FORMAT)

        log_to_std_out = logging.StreamHandler(sys.stdout)
        if args[KEY_VERBOSE]:
            log_to_std_out.setLevel(verbose_logging_level)
        else:
            log_to_std_out.setLevel(logging.INFO)
        log_to_std_out.setFormatter(stdout_formatter)

        log_file_name = "GreengrassDeviceSetup-{}.log".format(datetime.datetime.now().strftime("%Y%m%d-%H%M%S"))
        args[KEY_LOG_FILE] = log_file_name

        log_to_file = logging.FileHandler(os.path.join(args[KEY_LOG_PATH], log_file_name))
        log_to_file.setLevel(logging.DEBUG)
        log_to_file.setFormatter(logging_formatter)

        root_logger.addHandler(log_to_std_out)
        root_logger.addHandler(log_to_file)

    @classmethod
    def log_config_info_source(cls, args):
        logger = args.get(KEY_LOGGER)
        if args[KEY_IS_CONFIG_FILE_EXIST] and args[KEY_RECOVER_OR_REBOOT_FROM_LAST_RUN]:
            logger.debug("GreengrassDeviceSetup.config.info is found. Continuing with previous configuration values.")
        elif args[KEY_IS_CONFIG_FILE_EXIST] and not args[KEY_RECOVER_OR_REBOOT_FROM_LAST_RUN]:
            logger.debug("Discarding the existing GreengrassDeviceSetup.config.info. Starting with new configuration.")
        else:
            logger.debug("Starting GreengrassDeviceSetup with new configuration.")

    @classmethod
    def set_deploy_time_out(cls, args):
        global CONFIG_DEPLOYMENT_TIMEOUT
        CONFIG_DEPLOYMENT_TIMEOUT = args[KEY_DEPLOYMENT_TIMEOUT]

    # Currently, GreengrassDeviceSetup only support for the latest version. Remove this method, if GreengrassDeviceSetup support more version in future.
    @classmethod
    def validate_latest_ggc_version(cls, args):
        if args[KEY_GGC_VERSION] != LATEST_GGC_VERSION_AWARE:
            err_msg = "Currently, GreengrassDeviceSetup only supports the latest " \
                      "GGC version: {}.".format(LATEST_GGC_VERSION_AWARE)
            raise StepError(code=StepError.ERR_ARG_COLLECTION, message=err_msg)

    # Python2.7 is on its deprecation path. Disable this option, if python2.7 is running.
    @classmethod
    def disable_helloworld_lambda_if_runtime_python27(cls, args):
        if sys.version_info.major == 2 and args[KEY_HAS_HELLO_WORLD_LAMBDA] is True:
            err_msg = "The HelloWorld Lambda function requires Python 3.7, but GreengrassDeviceSetup was unable to " \
                      "install Python 3.7. To include the function, you must install Python 3.7 manually and restart " \
                      "the script. To omit the function, restart the script and enter 'no' " \
                      "when prompted to include the function."
            raise StepError(code=StepError.ERR_ARG_COLLECTION, message=err_msg)


class EnvironmentPreValidation(Step):

    def __init__(self, args):
        super(EnvironmentPreValidation, self).__init__(args)

    def execute(self):
        logger = self._args.get(KEY_LOGGER)
        logger.info("Validating the device environment...")

        EnvironmentPreValidation.validate_platform(self._args)
        EnvironmentPreValidation.validate_required_linux_cmd(self._args)
        EnvironmentPreValidation.clarify_pkg_management_tool(self._args)

        logger.info("Validation of the device environment is complete.\n")

        return self._args

    @staticmethod
    def validate_platform(args):
        logger = args.get(KEY_LOGGER)
        msg = "Validating the device platform..."
        logger.verbose(msg)

        device_platform = platform.platform()
        args[KEY_DEVICE_PLATFORM] = device_platform

        for supported_platform in SUPPORTED_PLATFORMS:
            if supported_platform in device_platform:
                args[KEY_ARCHITECTURE] = supported_platform
                msg = "Found supported platform: {}.".format(device_platform)
                logger.verbose(msg)
                return

        err_msg = "Platform {} not supported".format(device_platform)
        logger.error(err_msg)
        raise StepError(code=StepError.ERR_ENV_PREVALIDATE, message=err_msg)

    @classmethod
    def validate_required_linux_cmd(cls, args):
        logger = args.get(KEY_LOGGER)
        msg = "Validating required Linux commands..."
        logger.verbose(msg)

        # all required linux cmd should be there
        for cmd in REQUIRED_LINUX_CMD:
            if not Step.cmd_exist(cmd):
                err_msg = "Required Linux command {} not found.".format(cmd)
                logger.error(err_msg)
                raise StepError(code=StepError.ERR_ENV_PREVALIDATE, message=err_msg)

    @staticmethod
    def clarify_pkg_management_tool(args):
        logger = args.get(KEY_LOGGER)
        msg = "Validating the package management tool..."
        logger.verbose(msg)

        for pkg_management_tool in SUPPORTED_PKG_MANAGEMENT_TOOLS:
            # any one of the supported pkg tool is good enough
            if Step.cmd_exist(pkg_management_tool):
                args[KEY_PKG_MANAGEMENT_TOOL] = pkg_management_tool
                msg = "Using package management tool: {}.".format(pkg_management_tool)
                logger.verbose(msg)
                return

        err_msg = "Not able to find any of the supported package management tools: {}." \
            .format(SUPPORTED_PKG_MANAGEMENT_TOOLS)
        logger.error(err_msg)
        raise StepError(code=StepError.ERR_ENV_PREVALIDATE, message=err_msg)


class GreengrassEnvironmentBootstrap(Step):

    def __init__(self, args):
        super(GreengrassEnvironmentBootstrap, self).__init__(args)
        # step sequence matters
        self._steps = [
            UserGroupBootstrap,
            HardSoftLinkProtectionBootstrap,
            CGroupBootstrap,
            GGCDependencyCheck,
        ]

    def execute(self):
        logger = self._args.get(KEY_LOGGER)
        logger.info("Running the Greengrass environment setup...")

        for step in self._steps:
            self._args = step(self._args).execute()

        logger.info("The Greengrass environment setup is complete.\n")

        return self._args


def check_if_user_exists(username):
    try:
        pwd.getpwnam(username)
        return True
    except KeyError:
        return False


def check_if_group_exists(groupname):
    try:
        grp.getgrnam(groupname)
        return True
    except KeyError:
        return False


class UserGroupBootstrap(Step):
    KEY_USER = "user"
    KEY_GROUP = "group"
    ADD_TARGET_RUNBOOK = {
        KEY_USER: ADD_USER,
        KEY_GROUP: ADD_GROUP,
    }
    TARGET_ADD_RUNBOOK = {
        KEY_USER: USER_ADD,
        KEY_GROUP: GROUP_ADD,
    }
    ARGS_KEY_RUNBOOK = {
        KEY_USER: KEY_ADD_USER_TOOL,
        KEY_GROUP: KEY_ADD_GROUP_TOOL,
    }
    VERIFY_TARGET_EXISTS_RUNBOOK = {
        KEY_USER: check_if_user_exists,
        KEY_GROUP: check_if_group_exists,
    }

    def __init__(self, args):
        super(UserGroupBootstrap, self).__init__(args)

    def execute(self):
        logger = self._args.get(KEY_LOGGER)
        msg = "Configuring the Greengrass access identity: 'ggc_user' and 'ggc_group'..."
        logger.verbose(msg)

        UserGroupBootstrap.bootstrap_user_group(self._args)
        return self._args

    @classmethod
    def bootstrap_user_group(cls, args):
        cls._bootstrap_user(args)
        cls._bootstrap_group(args)

    @classmethod
    def _bootstrap_user(cls, args):
        cls._bootstrap_target(args, cls.KEY_USER)

    @classmethod
    def _bootstrap_group(cls, args):
        cls._bootstrap_target(args, cls.KEY_GROUP)

    @classmethod
    def _bootstrap_target(cls, args, target):
        # check if we already configured target. If not, proceed:
        # check if we have [target]add or add[target]
        # if not, try install any of them, fail if nothing can be installed
        # configure target
        logger = args.get(KEY_LOGGER)
        logger.debug("Checking if {} has already been configured...".format(target))
        verify_exist_func = cls.VERIFY_TARGET_EXISTS_RUNBOOK.get(target)
        if verify_exist_func("ggc_{}".format(target)):
            logger.debug("{} has already been configured.".format(target))
            return

        logger.debug("{} has not been configured. Proceeding to install configuration tools.".format(target))
        target_add = cls.TARGET_ADD_RUNBOOK.get(target)
        add_target = cls.ADD_TARGET_RUNBOOK.get(target)
        target_args_key = cls.ARGS_KEY_RUNBOOK.get(target)

        if Step.cmd_exist(target_add):
            logger.debug("Tool {} exists.".format(target_add))
            args[target_args_key] = target_add
        elif Step.cmd_exist(add_target):
            logger.debug("Tool {} exists.".format(add_target))
            args[target_args_key] = add_target
        else:
            logger.debug("Installing configuration tools...")
            pkg_tool_runbook = INSTALL_RUNBOOKS.get(args[KEY_PKG_MANAGEMENT_TOOL])
            cmd_install_target_add = pkg_tool_runbook.get(target_add)
            cmd_install_add_target = pkg_tool_runbook.get(add_target)
            installed = False

            if not installed and cmd_install_target_add is not None:
                ret_code, _, _ = Step.run_linux_cmd(cmd_install_target_add)
                logger.debug("Running command: {}.".format(cmd_install_target_add))
                if ret_code == 0:
                    args[target_args_key] = target_add
                    logger.debug("Installed tool {}.".format(target_add))
                    installed = True
                logger.debug("Installing tool {} failed.".format(target_add))

            if not installed and cmd_install_add_target is not None:
                ret_code, _, _ = Step.run_linux_cmd(cmd_install_add_target)
                logger.debug("Running command: {}.".format(cmd_install_add_target))
                if ret_code == 0:
                    args[target_args_key] = add_target
                    logger.debug("Installed tool {}.".format(add_target))
                    installed = True
                logger.debug("Installing tool {} failed.".format(add_target))

            if not installed:
                err_msg = "Not able to use {} to install {} or {}.".format(
                    args[KEY_PKG_MANAGEMENT_TOOL], target_add, add_target
                )
                logger.error(err_msg)
                raise StepError(code=StepError.ERR_GG_ENV_BOOTSTRAP, message=err_msg)

        cmd_add_ggc_target = "{} --system ggc_{}".format(args[target_args_key], target)
        logger.debug("Running command: {}.".format(cmd_add_ggc_target))
        Step.run_linux_cmd_raise_on_failure(cmd_string=cmd_add_ggc_target,
                                            err_code=StepError.ERR_GG_ENV_BOOTSTRAP,
                                            err_msg="Not able to add ggc_{}.".format(target))


class HardSoftLinkProtectionBootstrap(Step):
    SYSCTL_OVERRIDE_CONFIG = "/etc/sysctl.conf"

    def __init__(self, args):
        super(HardSoftLinkProtectionBootstrap, self).__init__(args)

    def execute(self):
        logger = self._args.get(KEY_LOGGER)
        msg = "Configuring hardlink and softlink protection..."
        logger.verbose(msg)

        HardSoftLinkProtectionBootstrap.bootstrap_hard_soft_link_protection(self._args)
        return self._args

    @staticmethod
    def bootstrap_hard_soft_link_protection(args):
        logger = args.get(KEY_LOGGER)
        # we will make sure we always have an overridden configuration that enables hard/soft link protection

        # skip if we already enabled hardlink protection
        cmd_enable_hardlink_protection = \
            "grep -q \"fs.protected_hardlinks = 1\" {0} || echo \"fs.protected_hardlinks = 1\" >> {0}".format(
                HardSoftLinkProtectionBootstrap.SYSCTL_OVERRIDE_CONFIG,
            )
        # skip if we already enabled softlink protection
        cmd_enable_softlink_protection = \
            "grep -q \"fs.protected_symlinks = 1\" {0} || echo \"fs.protected_symlinks = 1\" >> {0}".format(
                HardSoftLinkProtectionBootstrap.SYSCTL_OVERRIDE_CONFIG,
            )

        logger.debug("Running command: {}.".format(cmd_enable_hardlink_protection))
        Step.run_linux_cmd_raise_on_failure(cmd_string=cmd_enable_hardlink_protection,
                                            err_code=StepError.ERR_GG_ENV_BOOTSTRAP,
                                            err_msg="Not able to enable hardlink protection.")

        logger.debug("Running command: {}.".format(cmd_enable_softlink_protection))
        Step.run_linux_cmd_raise_on_failure(cmd_string=cmd_enable_softlink_protection,
                                            err_code=StepError.ERR_GG_ENV_BOOTSTRAP,
                                            err_msg="Not able to enable softlink protection.")

        # now we make sure this change takes effect immediately
        cmd_set_sysctl_values = "sysctl -p"
        logger.debug("Running command: {}.".format(cmd_set_sysctl_values))
        Step.run_linux_cmd_raise_on_failure(cmd_string=cmd_set_sysctl_values,
                                            err_code=StepError.ERR_GG_ENV_BOOTSTRAP,
                                            err_msg="Not able to make sysctl changes immediately effective.")


class CGroupBootstrap(Step):
    CGROUPFS_MOUNT_SH = "./cgroupfs-mount.sh"

    def __init__(self, args):
        super(CGroupBootstrap, self).__init__(args)

    def execute(self):
        logger = self._args.get(KEY_LOGGER)
        msg = "Configuring cgroups..."
        logger.verbose(msg)

        # pull down cgroupfs-mount script and run it
        # if it fails, try enabling memory cgroups in boot file. This will require a restart.
        linux_distribution = repr(distro.linux_distribution()).lower()
        if not self._args.get(KEY_RECOVER_OR_REBOOT_FROM_LAST_RUN):

            # Raspbian OS always require boot file edits and a restart to enable cgroups memory
            if "raspbian" in linux_distribution or 'openwrt' in linux_distribution:
                CGroupBootstrap.add_cgroup_mem_mount_to_boot_cmd(self._args)
            else:
                script_succeeds = CGroupBootstrap.run_cgroupfs_mount_script(self._args)
                if not script_succeeds:
                    CGroupBootstrap.add_cgroup_mem_mount_to_boot_cmd(self._args)
        else:
            # What need to do after rebooting
            if 'openwrt' in linux_distribution:
                CGroupBootstrap.add_symlink_to_boot_cmd(self._args)

        return self._args

    @staticmethod
    def run_cgroupfs_mount_script(args):
        logger = args.get(KEY_LOGGER)
        logger.debug("Configuring cgroups using cgroupfs mount script.")

        try:
            logger.debug("Downloading script from: {}.".format(CGROUPFS_MOUNT_SCRIPT_REMOTE_LOCATION))
            urlretrieve(url=CGROUPFS_MOUNT_SCRIPT_REMOTE_LOCATION, filename=CGroupBootstrap.CGROUPFS_MOUNT_SH)

            cmd_change_script_permissions = "chmod +x {}".format(CGroupBootstrap.CGROUPFS_MOUNT_SH)
            logger.debug("Running command: {}.".format(cmd_change_script_permissions))
            Step.run_linux_cmd_raise_on_failure(cmd_string=cmd_change_script_permissions,
                                                err_code=StepError.ERR_GG_ENV_BOOTSTRAP,
                                                err_msg="Not able to change the permissions for cgroupfs-mount.sh.")

            ret_code, std_out, std_err = Step.run_linux_cmd(CGroupBootstrap.CGROUPFS_MOUNT_SH)
            logger.debug("Running command: {}.".format(CGroupBootstrap.CGROUPFS_MOUNT_SH))
            logger.debug("Script output: stdout: {} stderr: {}".format(std_out, std_err))

            return ret_code == 0

        finally:
            cmd_rm_script = "rm {}".format(CGroupBootstrap.CGROUPFS_MOUNT_SH)
            logger.debug("Running command: {}.".format(cmd_rm_script))
            # regardless of results, clean up the script once the execution is done.
            Step.run_linux_cmd(cmd_rm_script)

    @staticmethod
    def add_cgroup_mem_mount_to_boot_cmd(args):
        logger = args.get(KEY_LOGGER)
        logger.debug("Not able to configure cgroups using cgroupfs mount script. Updating the boot cmdline file...")

        # add if missing
        cmd_string = "grep -qxF 'cgroup_enable=memory cgroup_memory=1' /boot/cmdline.txt || " \
                     "sed -i '$ s/$/ cgroup_enable=memory cgroup_memory=1/' /boot/cmdline.txt"
        logger.debug("Running command: {}.".format(cmd_string))
        Step.run_linux_cmd_raise_on_failure(cmd_string=cmd_string,
                                            err_code=StepError.ERR_GG_ENV_BOOTSTRAP,
                                            err_msg="Not able to configure cgroup memory mount in boot file.")
        logger.info("A reboot is required to make cgroups configuration change effective.")
        build_config_info_file(args)
        CGroupBootstrap.notify_reboot_and_exit()

    @staticmethod
    def notify_reboot_and_exit():
        print("You must reboot your device manually and then restart GreengrassDeviceSetup.")
        exit(0)  # Use exit code 0 just to indicate that there is no failure and we just need a reboot

    @staticmethod
    def add_symlink_to_boot_cmd(args):
        logger = args.get(KEY_LOGGER)
        logger.verbose(
            "The symlink is not consistent across reboot. Adding symlinks to the boot sequence...")

        try:
            os.symlink("/proc/self/fd/0", "/dev/stdin")
            logger.verbose("Adding symlink of /proc/self/fd/0 -> /dev/stdin")
        except:
            logger.verbose("Failed to add symlink of /proc/self/fd/0 -> /dev/stdin")

        try:
            os.symlink("/proc/self/fd/1", "/dev/stdout")
            logger.verbose("Adding symlink of /proc/self/fd/1 -> /dev/stdout")
        except:
            logger.verbose("Failed to add symlink of /proc/self/fd/1 -> /dev/stdout")

        try:
            os.symlink("/proc/self/fd/2", "/dev/stderr")
            logger.verbose("Adding symlink of /proc/self/fd/2 -> /dev/stderr")
        except:
            logger.verbose("Failed to add symlink of /proc/self/fd/2 -> /dev/stderr")


class GGCDependencyCheck(Step):
    RUN_CHECKER = "./check_ggc_dependencies"

    def __init__(self, args):
        super(GGCDependencyCheck, self).__init__(args)

    def execute(self):
        logger = self._args.get(KEY_LOGGER)
        msg = "Running the Greengrass dependency checker..."
        logger.verbose(msg)

        core_major_minor_version = None
        try:
            core_major_minor_version = GGCDependencyCheck.parse_ggc_major_minor_version(self._args[KEY_GGC_VERSION])
            GGCDependencyCheck.prepare_kernel_config_file_if_missing(self._args)
            GGCDependencyCheck.download_checker(self._args, core_major_minor_version)
            GGCDependencyCheck.run_checker(self._args, core_major_minor_version)
        finally:
            # regardless of results, clean up the checker files once the execution is done.
            if core_major_minor_version is not None:
                GGCDependencyCheck.clean_up_checker_files(self._args, core_major_minor_version)
        return self._args

    @staticmethod
    def parse_ggc_major_minor_version(version):
        # at this point, "matched" should never be none, otherwise it fails in earlier GreengrassDeviceSetup stages
        matched = re.match(GGC_VERSION_REGEX, version)
        return "{}.{}.x".format(matched.group(1), matched.group(2))

    @staticmethod
    def prepare_kernel_config_file_if_missing(args):
        linux_distribution = repr(distro.linux_distribution()).lower()
        if "raspbian" in linux_distribution:
            logger = args.get(KEY_LOGGER)
            cmd_mount_cgroup = "modprobe configs"
            logger.debug("Running command: {}.".format(cmd_mount_cgroup))
            Step.run_linux_cmd_raise_on_failure(cmd_string=cmd_mount_cgroup,
                                                err_code=StepError.ERR_MOUNT_CGROUP,
                                                err_msg="The file '/proc/config.gz' was not found.")

    @staticmethod
    def download_checker(args, major_minor_version):
        logger = args.get(KEY_LOGGER)
        checker_remote_location = GGC_DEPENDENCY_CHECKER_REMOTE_LOCATION_FORMAT.format(major_minor_version)
        logger.debug("Downloading GGC dependency checker from: {}.".format(checker_remote_location))
        urlretrieve(url=checker_remote_location, filename=GGC_DEPENDENCY_CHECKER_ZIP_FORMAT.format(major_minor_version))

    @staticmethod
    def run_checker(args, major_minor_version):
        logger = args.get(KEY_LOGGER)
        checker_dir = GGC_DEPENDENCY_CHECKER_FORMAT.format(major_minor_version)
        checker_zip = GGC_DEPENDENCY_CHECKER_ZIP_FORMAT.format(major_minor_version)

        logger.debug("Unpacking {}.".format(checker_zip))
        with ZipFile(checker_zip, 'r') as zf:
            zf.extractall()

        # we need "cd" here because the dependency checker script assumes all sub-scripts are under the same directory
        with ChangeDirectory("./{}".format(checker_dir)):
            # TODO: See if we can fix some issues reported from dependency checker so that customers don't need to do it
            # https://issues.amazon.com/issues/GG-25320
            cmd_chmod_x = "chmod +x {}".format(GGCDependencyCheck.RUN_CHECKER)
            logger.debug("Running command: {}.".format(cmd_chmod_x))
            Step.run_linux_cmd_raise_on_failure(cmd_string=cmd_chmod_x,
                                                err_code=StepError.ERR_GG_ENV_BOOTSTRAP,
                                                err_msg="GreengrassDeviceSetup cannot continue: "
                                                        "Not able to add execute permission to GGC dependency checker.")

            checker_result_file = os.path.abspath(os.path.join(os.getcwd(), "checker_result.txt"))
            cmd_run_gg_dependency_checker = GGCDependencyCheck.RUN_CHECKER + " > " + checker_result_file
            ret_code, std_out, std_err = Step.run_linux_cmd(cmd_run_gg_dependency_checker)
            dependency_checker_result_info = GGCDependencyCheck.read_dependency_checker_result(checker_result_file)
            if ret_code != 0:
                for info in dependency_checker_result_info:
                    print(info)
                raise StepError(code=ret_code, message="Error" + " Stdout: {} Stderr: {}".format(std_out, std_err))
            GGCDependencyCheck.parse_dependency_checker_result(args, dependency_checker_result_info)

    @staticmethod
    def read_dependency_checker_result(checker_result_file):
        with open(checker_result_file, "r") as f:
            res_info = f.readlines()
        return res_info

    @staticmethod
    def parse_dependency_checker_result(args, res_info):
        user_group_info = []
        lambda_isolation_mode_info = []
        systemd_info_list = []
        user_group_flag = False
        lambda_flag = False
        systemd_flag = False

        for line in res_info:
            if "----User and group----" in line:
                user_group_flag = True
                continue
            if "----(Optional) Greengrass container dependency check----" in line:
                user_group_flag = False

            if "Note:" in line:
                systemd_flag = True
                continue
            if systemd_flag and ("Missing optional dependencies:" in line or
                                 "Missing required dependencies:" in line or
                                 "(Optional) Greengrass container dependencies" in line or
                                 "Errors:" in line or
                                 "Supported lambda isolation modes:" in line):
                systemd_flag = False

            if "Supported lambda isolation modes:" in line:
                lambda_flag = True
                continue
            if "---Exit status----" in line:
                lambda_flag = False

            if user_group_flag:
                user_group_info.append(line)
            if lambda_flag:
                lambda_isolation_mode_info.append(line)
            if systemd_flag:
                systemd_info_list.append(line)

        systemd_info = " ".join(systemd_info_list)
        GGCDependencyCheck.check_whether_use_systemd(args, systemd_info)
        GGCDependencyCheck.check_both_ggc_user_and_ggc_group_exist(user_group_info)
        GGCDependencyCheck.check_lambda_isolation_mode(lambda_isolation_mode_info)

    @staticmethod
    def check_whether_use_systemd(args, systemd_info):
        if "kernel uses 'systemd'" in systemd_info:
            args[KEY_USE_SYSTEMD] = "yes"
        if "kernel does NOT use 'systemd'" in systemd_info:
            args[KEY_USE_SYSTEMD] = "no"

    @staticmethod
    def check_both_ggc_user_and_ggc_group_exist(user_group_info):
        ggc_user_flag = False
        ggc_group_flag = False
        for line in user_group_info:
            if "ggc_user" in line and "Present" in line:
                ggc_user_flag = True
            if "ggc_group" in line and "Present" in line:
                ggc_group_flag = True
        if not ggc_user_flag or not ggc_group_flag:
            raise StepError(code=StepError.ERR_GG_ENV_BOOTSTRAP,
                            message="There is no ggc_user/ggc_group to run Greengrass core.")

    @staticmethod
    def check_lambda_isolation_mode(lambda_isolation_mode_info):
        for line in lambda_isolation_mode_info:
            if "Greengrass Container" in line and "Not supported" in line:
                raise StepError(code=StepError.ERR_GG_ENV_BOOTSTRAP,
                                message="GreengrassDeviceSetup cannot continue: "
                                        "Greengrass containers are not supported on this platform.")

    @staticmethod
    def clean_up_checker_files(args, major_minor_version):
        logger = args.get(KEY_LOGGER)
        cmd_remove_zip_file = "rm ./{}".format(GGC_DEPENDENCY_CHECKER_ZIP_FORMAT.format(major_minor_version))
        cmd_remove_zip_dir = "rm -rf ./{}".format(GGC_DEPENDENCY_CHECKER_FORMAT.format(major_minor_version))

        logger.debug("Running command: {}.".format(cmd_remove_zip_file))
        Step.run_linux_cmd(cmd_remove_zip_file)

        logger.debug("Running command: {}.".format(cmd_remove_zip_dir))
        Step.run_linux_cmd(cmd_remove_zip_dir)


class GreengrassCloudBootstrap(Step):

    def __init__(self, args):
        super(GreengrassCloudBootstrap, self).__init__(args)
        # step sequence matters
        self._steps = [
            CloudPermissionBootstrap,
            CoreDefinitionBootstrap,
            LoggerDefinitionBootstrap,
            FunctionDefinitionBootstrap,
            SubscriptionDefinitionBootstrap,
            GroupDefinitionBootstrap
        ]

    def execute(self):
        logger = self._args.get(KEY_LOGGER)
        logger.info("Configuring cloud-based Greengrass group management...")

        self._args[KEY_BOTO_SESSION] = boto3.Session(
            aws_access_key_id=self._args[KEY_AWS_ACCESS_KEY_ID],
            aws_secret_access_key=self._args[KEY_AWS_SECRET_ACCESS_KEY],
            aws_session_token=self._args[KEY_AWS_SESSION_TOKEN],
            region_name=self._args.get(KEY_AWS_REGION),
        )

        for step in self._steps:
            self._args = step(self._args).execute()
        logger.info("The Greengrass group configuration is complete.\n")
        return self._args


class CloudPermissionBootstrap(Step):
    KEY_ROLE = "Role"
    KEY_ARN = "Arn"
    KEY_ROLE_ARN = KEY_ROLE + KEY_ARN
    RC_NOT_FOUND = 404

    def __init__(self, args):
        super(CloudPermissionBootstrap, self).__init__(args)

    def execute(self):
        logger = self._args.get(KEY_LOGGER)
        msg = "Configuring the 'Greengrass_ServiceRole'..."
        logger.verbose(msg)

        session = self._args[KEY_BOTO_SESSION]
        if not CloudPermissionBootstrap.is_gg_account_service_role_attached(self._args, session):
            CloudPermissionBootstrap.configure_gg_account_service_role(self._args, session)
        logger.debug("Permissions for the Greengrass service role were configured.")
        return self._args

    @classmethod
    def is_gg_account_service_role_attached(cls, args, session):
        gg_client = session.client(GREENGRASS)
        logger = args.get(KEY_LOGGER)
        logger.debug("Checking whether a Greengrass service role has been attached to the account...")
        try:
            resp = gg_client.get_service_role_for_account()
            args[KEY_GG_ACCOUNT_SERVICE_ROLE] = resp[cls.KEY_ROLE_ARN]
            logger.debug("A Greengrass service role was attached to the account.")
            return True
        except ClientError as e:
            err_code = e.response[KEY_RESPONSE_METADATA][KEY_HTTP_STATUS_CODE]
            logger.debug(e.response)
            if err_code != cls.RC_NOT_FOUND:  # 404s are handled by the following logic to attach the missing role
                raise e
            logger.debug("There is no Greengrass Service Role attached to this AWS account. "
                         "Attaching a service role to the account...")
            return False

    @classmethod
    def configure_gg_account_service_role(cls, args, session):
        logger = args.get(KEY_LOGGER)
        iam_client = session.client(IAM)
        gg_client = session.client(GREENGRASS)
        region = args[KEY_AWS_REGION]

        # create a role under with proper trust entity
        logger.debug("Creating a Greengrass service role for the account.")
        role_name = "GreengrassServiceRole_" + Step.get_random_string(5)
        assume_role_policy = {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Principal": {
                        "Service": [
                            "greengrass.amazonaws.com"
                        ]
                    },
                    "Action": "sts:AssumeRole"
                }
            ]
        }
        create_role_resp = iam_client.create_role(
            RoleName=role_name,
            AssumeRolePolicyDocument=json.dumps(assume_role_policy),
        )
        role_arn = create_role_resp[cls.KEY_ROLE][cls.KEY_ARN]
        logger.debug("A service role was successfully created.")
        # attach aws managed Greengrass resource policy to this role
        iam_client.attach_role_policy(
            RoleName=role_name,
            PolicyArn="arn:{}:iam::aws:policy/service-role/AWSGreengrassResourceAccessRolePolicy"
                .format(PARTITION_OVERRIDES.get(region, AWS)),
        )

        # attach this role as gg service role
        logger.debug("Attaching the service role to the account.")
        gg_client.associate_service_role_to_account(
            RoleArn=role_arn,
        )

        # capture arn for this role
        args[KEY_GG_ACCOUNT_SERVICE_ROLE] = role_arn


class CoreDefinitionBootstrap(Step):
    KEY_CERT_ID = "certificateId"
    KEY_CERT_ARN = "certificateArn"
    KEY_THING_ARN = "thingArn"
    KEY_POLICY_NAME = "policyName"
    KEY_CERT_PEM = "certificatePem"
    KEY_KEY_PAIR = "keyPair"
    KEY_PRIV_KEY = "PrivateKey"
    KEY_LATEST_VER_ARN = "LatestVersionArn"
    POLICY_DOCUMENT = "policyDocument"
    RC_ALREADY_EXIST = 409

    def __init__(self, args):
        super(CoreDefinitionBootstrap, self).__init__(args)

    def execute(self):
        logger = self._args.get(KEY_LOGGER)
        msg = "Configuring the core definition..."
        logger.verbose(msg)
        session = self._args[KEY_BOTO_SESSION]
        CoreDefinitionBootstrap.prepare_core_thing(self._args, session)
        CoreDefinitionBootstrap.prepare_core_definition(self._args, session)
        logger.debug("The core definition was configured.")
        return self._args

    @classmethod
    def prepare_core_thing(cls, args, session):
        logger = args.get(KEY_LOGGER)
        iot_client = session.client(IOT)
        region = args[KEY_AWS_REGION]
        core_name = args[KEY_CORE_NAME]

        # create core iot thing and its credentials
        logger.debug("Creating an IoT thing and credentials for the Greengrass core.")
        core_thing = iot_client.create_thing(thingName=core_name)
        key_cert = iot_client.create_keys_and_certificate(setAsActive=True)
        thing_arn = core_thing[cls.KEY_THING_ARN]
        cert_arn = key_cert[cls.KEY_CERT_ARN]
        logger.debug("The IoT thing for Greengrass core was successfully created.")

        # associate core iot thing with its cert
        logger.debug("Attaching the certificate to the Greengrass core...")
        iot_client.attach_thing_principal(
            thingName=core_name,
            principal=cert_arn,
        )
        logger.debug("The certificate was successfully attached to Greengrass core.")

        # create iot policy
        logger.debug("Creating an IoT policy for the Greengrass core...")
        core_policy_doc = {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    # iot data plane
                    "Action": ["iot:Publish", "iot:Subscribe", "iot:Connect", "iot:Receive", "iot:GetThingShadow",
                               "iot:DeleteThingShadow", "iot:UpdateThingShadow"],
                    "Resource": ["arn:{}:iot:{}:*:*".format(PARTITION_OVERRIDES.get(region, AWS), region)]
                },
                {
                    "Effect": "Allow",
                    # Greengrass data plane
                    "Action": ["greengrass:AssumeRoleForGroup", "greengrass:CreateCertificate",
                               "greengrass:GetConnectivityInfo", "greengrass:GetDeployment",
                               "greengrass:GetDeploymentArtifacts", "greengrass:UpdateConnectivityInfo",
                               "greengrass:UpdateCoreDeploymentStatus"],
                    "Resource": ["*"]
                }
            ]
        }

        policy_name = "{}_basic_policy".format(core_name)
        try:
            iot_client.create_policy(
                policyName=policy_name,
                policyDocument=json.dumps(core_policy_doc)
            )
            logger.debug("The IoT policy for the Greengrass core was successfully created.")
        except ClientError as e:
            err_code = e.response[KEY_RESPONSE_METADATA][KEY_HTTP_STATUS_CODE]
            if err_code != cls.RC_ALREADY_EXIST:
                raise e
            # check if document in cloud is same with what we have
            policy = iot_client.get_policy(policyName=policy_name)
            policy_document = json.loads(policy[cls.POLICY_DOCUMENT])
            recursive_sort(policy_document)
            recursive_sort(core_policy_doc)
            if core_policy_doc == policy_document:
                logger.debug("The policy for the Greengrass core already exist, skipping this step.")
            else:
                raise StepError(code=StepError.ERR_GG_CLOUD_BOOTSTRAP,
                                message="The policy {} for the Greengrass core already exists but "
                                        "it has different content than expected. "
                                        "You should manually rename or delete this policy.".format(policy_name))

        # associate iot policy with core cert
        logger.debug("Attaching the policy to certificate...")
        iot_client.attach_policy(
            policyName=policy_name,
            target=cert_arn,
        )
        logger.debug("The policy was successfully attached to the Greengrass core.")

        # capture info in args
        args[KEY_CORE_THING_ARN] = thing_arn
        args[KEY_CORE_CERT_ARN] = cert_arn
        args[KEY_CORE_CERT_ID] = key_cert[cls.KEY_CERT_ID]
        args[KEY_CORE_CERT_PEM] = key_cert[cls.KEY_CERT_PEM]
        args[KEY_CORE_PRIV_KEY] = key_cert[cls.KEY_KEY_PAIR][cls.KEY_PRIV_KEY]

    @classmethod
    def prepare_core_definition(cls, args, session):
        logger = args.get(KEY_LOGGER)
        gg_client = session.client(GREENGRASS)
        core_name = args[KEY_CORE_NAME]
        cert_arn = args[KEY_CORE_CERT_ARN]
        thing_arn = args[KEY_CORE_THING_ARN]

        # create core definition with version
        logger.debug("Creating the core definition with an initial version.")
        initial_core_definition_version = {
            'Cores': [
                {
                    'Id': core_name,
                    'CertificateArn': cert_arn,
                    'SyncShadow': False,
                    'ThingArn': thing_arn,
                }
            ]
        }
        core_definition = gg_client.create_core_definition(
            Name="{}_def".format(core_name),
            InitialVersion=initial_core_definition_version,
        )
        logger.debug("The core definition was successfully created.")
        # capture info in args
        args[KEY_CORE_DEF_VER_ARN] = core_definition[cls.KEY_LATEST_VER_ARN]


class FunctionDefinitionBootstrap(Step):
    TMP_DIR = tempfile.gettempdir()
    HELLO_WORLD_PY = "greengrassHelloWorld.py"
    GG_PY_SDK_ZIP = "greengrass-core-python-sdk.zip"
    HELLO_WORLD_LAMBDA_ZIP = "hello_world_python_lambda.zip"
    UNZIPPED_GG_PY_SDK_DIR = "aws-greengrass-core-sdk-python-master"
    GG_PY_SDK_DIR = "greengrasssdk"
    KEY_LAMBDA_ARN = 'FunctionArn'
    KEY_VERSION = "Version"
    KEY_LATEST_VER_ARN = 'LatestVersionArn'
    KEY_ROLE = 'Role'
    KEY_ARN = 'Arn'

    def __init__(self, args):
        super(FunctionDefinitionBootstrap, self).__init__(args)

    def execute(self):
        logger = self._args.get(KEY_LOGGER)
        if self._args[KEY_HAS_HELLO_WORLD_LAMBDA]:  # only do the following if a hello-world lambda is requested
            msg = "Configuring the function definition..."
            logger.verbose(msg)

            try:
                session = self._args[KEY_BOTO_SESSION]

                FunctionDefinitionBootstrap.prepare_code_package(self._args)
                lambda_execution_role_name = FunctionDefinitionBootstrap.prepare_lambda_execution_role(self._args,
                                                                                                       session)

                with yaspin().shark:
                    FunctionDefinitionBootstrap.prepare_lambda(self._args, session, lambda_execution_role_name)

                FunctionDefinitionBootstrap.prepare_function_definition(self._args, session)
                logger.debug("The function definition was configured.")

            finally:
                FunctionDefinitionBootstrap.clean_up(self._args)
        return self._args

    @classmethod
    def prepare_lambda_execution_role(cls, args, session):
        logger = args[KEY_LOGGER]
        # create lambda execution role
        region = args[KEY_AWS_REGION]
        iam_client = session.client(IAM)
        lambda_execution_role_name = "LambdaRole_" + Step.get_random_string(5)
        logger.debug("Creating an execution role: {} for the HelloWorld Lambda function.".format(lambda_execution_role_name))
        assume_role_policy = {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Principal": {
                        "Service": [
                            "lambda.amazonaws.com"
                        ]
                    },
                    "Action": "sts:AssumeRole"
                }
            ]
        }

        create_lambda_execution_role = iam_client.create_role(
            RoleName=lambda_execution_role_name,
            AssumeRolePolicyDocument=json.dumps(assume_role_policy),
        )
        logger.debug("The execution role was successfully created.")
        lambda_execution_role_arn = create_lambda_execution_role[cls.KEY_ROLE][cls.KEY_ARN]

        # Attach a policy to the lambda execution role
        logger.debug("Attaching a policy to the Lambda execution role...")
        iam_client.attach_role_policy(
            RoleName=lambda_execution_role_name,
            PolicyArn="arn:{}:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole".format(
                PARTITION_OVERRIDES.get(region, AWS)),
        )

        logger.debug("A policy was successfully attached to the Lambda execution role.")
        return lambda_execution_role_arn

    @classmethod
    def prepare_code_package(cls, args):
        logger = args.get(KEY_LOGGER)
        logger.debug("Preparing the files for the HelloWorld function...")

        with ChangeDirectory(cls.TMP_DIR):
            # download gg python sdk and unzip
            urlretrieve(url=LATEST_GG_PYTHON_SDK_REMOTE_LOCATION, filename="./" + cls.GG_PY_SDK_ZIP)
            with ZipFile(cls.GG_PY_SDK_ZIP, "r") as zf:
                zf.extractall()

            # construct Greengrass hello world lambda package
            with ChangeDirectory("./" + cls.UNZIPPED_GG_PY_SDK_DIR):
                # download gg hello-world lambda
                urlretrieve(url=LATEST_GG_HELLO_WORLD_LAMBDA_REMOTE_LOCATION,
                            filename="./" + cls.HELLO_WORLD_PY)
                # zip up the required files/directories
                with ZipFile(cls.HELLO_WORLD_LAMBDA_ZIP, "w") as lambda_pkg:
                    # add hello world py
                    lambda_pkg.write(cls.HELLO_WORLD_PY)
                    # add gg py sdk
                    for root, dirs, files in os.walk(cls.GG_PY_SDK_DIR):
                        for file in files:
                            lambda_pkg.write(os.path.join(root, file))

        logger.debug("The code package for the HelloWorld function was created.")

    @classmethod
    def prepare_lambda(cls, args, session, role_arn):
        logger = args.get(KEY_LOGGER)
        logger.debug("Creating the HelloWorld function in AWS Lambda.")
        with ChangeDirectory(os.path.join(cls.TMP_DIR, cls.UNZIPPED_GG_PY_SDK_DIR)):
            with open(cls.HELLO_WORLD_LAMBDA_ZIP, "rb") as f:
                lambda_client = session.client(LAMBDA)
                zip_bytes = f.read()
                functionName = "Greengrass_HelloWorld_" + Step.get_random_string(5)
                try:
                    retry_template(cls.create_hello_world_lambda_function, args, lambda_client, functionName, role_arn,
                                   zip_bytes)
                except Exception as e:
                    logger.debug('Failed to create the function. Exceeded the maximum number of retries.')
                    raise e

    @classmethod
    def create_hello_world_lambda_function(cls, args, lambda_client, functionName, role_arn, zip_bytes):
        logger = args.get(KEY_LOGGER)
        try:
            function_creation_resp = lambda_client.create_function(
                FunctionName=functionName,
                Runtime="python3.7",
                Role=role_arn,
                Handler="greengrassHelloWorld.function_handler",
                Code={
                    "ZipFile": zip_bytes,
                },
                Timeout=25,
                MemorySize=3008,
                Publish=True,
            )
            args[KEY_HELLO_WORLD_LAMBDA_VERSIONED_ARN] = function_creation_resp[cls.KEY_LAMBDA_ARN] + ":" + \
                                                         function_creation_resp[cls.KEY_VERSION]
            logger.debug("The HelloWorld function was successfully created.")

        except Exception as e:
            logger.debug('Failed to create the HelloWorld Lambda function. Retrying...')
            raise Exception

    @classmethod
    def prepare_function_definition(cls, args, session):
        logger = args.get(KEY_LOGGER)
        logger.debug("Creating the function definition...")

        gg_client = session.client(GREENGRASS)
        initial_function_version = {
            'Functions': [
                {
                    'FunctionArn': args[KEY_HELLO_WORLD_LAMBDA_VERSIONED_ARN],
                    'FunctionConfiguration': {
                        'Executable': "greengrassHelloWorld.function_handler",
                        'MemorySize': 25600,
                        'Pinned': True,
                        'Timeout': 25,
                    },
                    'Id': 'LambdaHelloWorld' + Step.get_random_string(5),
                },
            ]
        }

        # create the initial version of lambda function - "HelloWorld"
        create_function_definition = gg_client.create_function_definition(
            InitialVersion=initial_function_version,
            Name='function_def_' + Step.get_random_string(5),
        )
        args[KEY_FUNCTION_DEF_VER_ARN] = create_function_definition[cls.KEY_LATEST_VER_ARN]
        logger.debug('The function definition was created.')

    @classmethod
    def clean_up(cls, args):
        logger = args.get(KEY_LOGGER)
        greengrasssdk_zip_path = os.path.join(cls.TMP_DIR, cls.GG_PY_SDK_ZIP)
        greengrasssdk_dir_path = os.path.join(cls.TMP_DIR, cls.GG_PY_SDK_DIR)
        remove_file_or_dir(greengrasssdk_zip_path)
        logger.debug("Removing {}.".format(greengrasssdk_zip_path))
        remove_file_or_dir(greengrasssdk_dir_path)
        logger.debug("Removing {}.".format(greengrasssdk_dir_path))


class GroupDefinitionBootstrap(Step):
    KEY_ID = 'Id'
    KEY_LATEST_VER_ARN = 'LatestVersionArn'
    KEY_GROUP_CERT_ARN = 'GroupCertificateAuthorityArn'
    KEY_LATEST_VER_ID = 'LatestVersion'

    def __init__(self, args):
        super(GroupDefinitionBootstrap, self).__init__(args)

    def execute(self):
        logger = self._args.get(KEY_LOGGER)
        msg = "Configuring the group definition..."
        logger.verbose(msg)
        session = self._args[KEY_BOTO_SESSION]
        GroupDefinitionBootstrap.prepare_group(self._args, session)
        logger.debug("The group definition was configured.")
        return self._args

    @classmethod
    def prepare_group(cls, args, session):
        gg_client = session.client(GREENGRASS)
        logger = args.get(KEY_LOGGER)
        logger.debug('Creating the group definition...')
        group_name = args[KEY_GROUP_NAME]

        initial_group_definition_version = {
            'CoreDefinitionVersionArn': args[KEY_CORE_DEF_VER_ARN],
            'LoggerDefinitionVersionArn': args[KEY_LOGGER_VER_ARN],
        }
        # The Function/Subscription Definition are created as requested
        if args[KEY_HAS_HELLO_WORLD_LAMBDA]:
            initial_group_definition_version.update([
                ('FunctionDefinitionVersionArn', args[KEY_FUNCTION_DEF_VER_ARN]),
                ('SubscriptionDefinitionVersionArn', args[KEY_SUBSCRIPTION_VER_ARN]),
            ])

        # Create the Group Definition with version
        create_group_definition = gg_client.create_group(
            InitialVersion=initial_group_definition_version,
            Name=group_name,
        )

        logger.debug('The group definition was created.')

        args[KEY_GROUP_ID] = create_group_definition[cls.KEY_ID]
        args[KEY_GROUP_DEF_VER_ARN] = create_group_definition[cls.KEY_LATEST_VER_ARN]
        args[KEY_GROUP_DEF_VER_ID] = create_group_definition[cls.KEY_LATEST_VER_ID]


class SubscriptionDefinitionBootstrap(Step):
    KEY_LATEST_VER_ARN = 'LatestVersionArn'

    def __init__(self, args):
        super(SubscriptionDefinitionBootstrap, self).__init__(args)

    def execute(self):
        if self._args[KEY_HAS_HELLO_WORLD_LAMBDA]:  # only do the following if a hello-world lambda is requested
            logger = self._args.get(KEY_LOGGER)
            msg = "Configuring the subscription definition..."
            logger.verbose(msg)
            session = self._args[KEY_BOTO_SESSION]
            SubscriptionDefinitionBootstrap.prepare_subscription_definition(self._args, session)
            logger.debug("The subscription definition was configured.")
        return self._args

    @classmethod
    def prepare_subscription_definition(cls, args, session):
        gg_client = session.client(GREENGRASS)
        logger = args.get(KEY_LOGGER)

        logger.debug("Creating the subscription definition...")
        create_subscription_definition = gg_client.create_subscription_definition(
            InitialVersion={
                'Subscriptions': [
                    {
                        'Id': 'Subscription_helloworld_to_cloud_' + Step.get_random_string(5),
                        'Source': args[KEY_HELLO_WORLD_LAMBDA_VERSIONED_ARN],
                        'Subject': 'hello/world',
                        'Target': 'cloud'
                    },
                ]
            },
            Name='Subscription_definition_' + Step.get_random_string(5),
        )
        logger.debug("The subscription definition was created.")

        args[KEY_SUBSCRIPTION_VER_ARN] = create_subscription_definition[cls.KEY_LATEST_VER_ARN]


class LoggerDefinitionBootstrap(Step):
    KEY_NAME = 'Name'
    KEY_LATEST_VER_ARN = 'LatestVersionArn'

    def __init__(self, args):
        super(LoggerDefinitionBootstrap, self).__init__(args)

    def execute(self):
        logger = self._args.get(KEY_LOGGER)
        msg = "Configuring the logger definition..."
        logger.verbose(msg)
        session = self._args[KEY_BOTO_SESSION]
        LoggerDefinitionBootstrap.prepare_logger_definition(self._args, session)
        logger.debug("The logger definition was configured.")
        return self._args

    @classmethod
    def prepare_logger_definition(cls, args, session):
        gg_client = session.client(GREENGRASS)
        logger = args.get(KEY_LOGGER)

        logger.debug("Creating the logger definition...")
        create_logger_definition = gg_client.create_logger_definition(
            InitialVersion={
                'Loggers': [
                    {
                        'Component': 'GreengrassSystem',
                        'Id': 'Logger_definition_to_greengrass_system_' + Step.get_random_string(5),
                        'Level': 'INFO',
                        'Space': 1280,
                        'Type': 'FileSystem',
                    },
                    {
                        'Component': 'Lambda',
                        'Id': 'Logger_definition_to_lambda_' + Step.get_random_string(5),
                        'Level': 'INFO',
                        'Space': 1280,
                        'Type': 'FileSystem',
                    },
                ]
            },
            Name='Logger_definition_' + Step.get_random_string(5),
        )
        logger.debug("The logger definition was created.")

        args[KEY_LOGGER_VER_ARN] = create_logger_definition[cls.KEY_LATEST_VER_ARN]
        args[KEY_LOGGER_NAME] = create_logger_definition[cls.KEY_NAME]


class GreengrassCoreKickoff(Step):
    def __init__(self, args):
        super(GreengrassCoreKickoff, self).__init__(args)
        # step sequence matters
        # Removing CoreSoftwareBootstrap to put it higher in install
        self._steps = [
            CertKeyBootstrap,
            ConfigJsonBootstrap,
        ]

    def execute(self):
        logger = self._args.get(KEY_LOGGER)

        logger.info("Preparing the Greengrass core software...")
        for step in self._steps:
            self._args = step(self._args).execute()

        ggc_daemon_dir = os.path.abspath(os.path.join(self._args[KEY_GGC_ROOT_PATH], "/greengrass/ggc/core"))
        with ChangeDirectory(ggc_daemon_dir):
            cmd_start_ggc = "./greengrassd start"
            logger.debug("Running command: {}.".format(cmd_start_ggc))
            Step.run_linux_cmd_raise_on_failure(cmd_string=cmd_start_ggc,
                                                err_code=StepError.ERR_GG_START,
                                                err_msg="Not able to start GGC")

        logger.info("The Greengrass core software is running.\n")

        return self._args


class ConfigJsonBootstrap(Step):
    CONFIG_DIR = "/greengrass/config/"
    CONFIG_JSON_FILE = "config.json"
    IOT_ENDPOINT_TYPE_ATS = "iot:Data-ATS"

    KEY_ENDPOINT_ADDR = "endpointAddress"
    KEY_CORE_THING = "coreThing"
    KEY_RUNTIME = "runtime"
    KEY_MANAGED_RESPAWN = "managedRespawn"
    KEY_CRYPTO = "crypto"
    KEY_CA_PATH = "caPath"
    KEY_CERT_PATH = "certPath"
    KEY_PRIV_KEY_PATH = "keyPath"
    KEY_THING_ARN = "thingArn"
    KEY_IOT_HOST = "iotHost"
    KEY_GG_HOST = "ggHost"
    KEY_KEEP_ALIVE = "keepAlive"
    KEY_CGROUP = "cgroup"
    KEY_USE_SYSTEMD = "UseSystemd"
    KEY_PRINCIPALS = "principals"
    KEY_SECRETS_MANAGER = "SecretsManager"
    KEY_IOT_CERTIFICATE = "IoTCertificate"
    KEY_CERTIFICATE_PATH = "certificatePath"
    KEY_PRIVATE_KEY_PATH = "privateKeyPath"

    def __init__(self, args):
        super(ConfigJsonBootstrap, self).__init__(args)

    def execute(self):
        logger = self._args.get(KEY_LOGGER)
        session = self._args[KEY_BOTO_SESSION]

        logger.debug("Bootstrapping config.json...")
        config_json = ConfigJsonBootstrap.construct_config_json(self._args, session)
        ConfigJsonBootstrap.persist_config_json(self._args, config_json)

        return self._args

    @classmethod
    def construct_config_json(cls, args, session):
        iot_client = session.client(IOT)
        describe_endpoint_resp = iot_client.describe_endpoint(endpointType=cls.IOT_ENDPOINT_TYPE_ATS)
        args[KEY_IOT_DATA_ENDPOINT] = describe_endpoint_resp[cls.KEY_ENDPOINT_ADDR]

        return {
            cls.KEY_CORE_THING: ConfigJsonBootstrap.construct_core_thing_section(args),
            cls.KEY_RUNTIME: ConfigJsonBootstrap.construct_runtime_section(args),
            cls.KEY_MANAGED_RESPAWN: False,
            cls.KEY_CRYPTO: ConfigJsonBootstrap.construct_crypto_section(args),
        }

    @classmethod
    def construct_core_thing_section(cls, args):
        return {
            cls.KEY_CA_PATH: args[KEY_ROOT_CA_FILE_LOCATION],
            cls.KEY_CERT_PATH: args[KEY_CORE_CERT_FILE_LOCATION],
            cls.KEY_PRIV_KEY_PATH: args[KEY_CORE_PRIV_KEY_FILE_LOCATION],
            cls.KEY_THING_ARN: args[KEY_CORE_THING_ARN],
            cls.KEY_IOT_HOST: args[KEY_IOT_DATA_ENDPOINT],
            cls.KEY_GG_HOST: get_gg_ats_data_endpoint(args[KEY_AWS_REGION]),
            cls.KEY_KEEP_ALIVE: DEFAULT_GGC_MQTT_KEEP_ALIVE,
        }

    @classmethod
    def construct_runtime_section(cls, args):
        return {
            cls.KEY_CGROUP: {
                cls.KEY_USE_SYSTEMD: args[KEY_USE_SYSTEMD],
            }
        }

    @classmethod
    def construct_crypto_section(cls, args):
        return {
            cls.KEY_CA_PATH: "file://{}".format(args[KEY_ROOT_CA_FILE_LOCATION]),
            cls.KEY_PRINCIPALS: {
                cls.KEY_SECRETS_MANAGER: {
                    cls.KEY_PRIVATE_KEY_PATH: "file://{}".format(args[KEY_CORE_PRIV_KEY_FILE_LOCATION]),
                },
                cls.KEY_IOT_CERTIFICATE: {
                    cls.KEY_CERTIFICATE_PATH: "file://{}".format(args[KEY_CORE_CERT_FILE_LOCATION]),
                    cls.KEY_PRIVATE_KEY_PATH: "file://{}".format(args[KEY_CORE_PRIV_KEY_FILE_LOCATION]),
                }
            },
        }

    @classmethod
    def persist_config_json(cls, args, config_json):
        config_dir_full_path = os.path.abspath(os.path.join(args[KEY_GGC_ROOT_PATH], cls.CONFIG_DIR))
        if not os.path.exists(config_dir_full_path):
            os.makedirs(config_dir_full_path)

        with ChangeDirectory(config_dir_full_path):
            # owner read/write, group and others read-only
            with os.fdopen(os.open(cls.CONFIG_JSON_FILE, os.O_CREAT | os.O_WRONLY, 0o644), 'w') as cjf:
                json.dump(config_json, cjf, indent=4)


class CertKeyBootstrap(Step):
    CERT_KEY_DIR = "/greengrass/certs/"
    CERT_PEM_FILE_FORMAT = "{}.cert.pem"
    PRIV_KEY_FILE_FORMAT = "{}.private.key"
    ROOT_CA_FILE = "root.ca.pem"

    def __init__(self, args):
        super(CertKeyBootstrap, self).__init__(args)

    def execute(self):
        logger = self._args.get(KEY_LOGGER)
        logger.debug("Persisting the core certificate and key...")

        CertKeyBootstrap.persist_cert_key(self._args)

        return self._args

    @classmethod
    def persist_cert_key(cls, args):
        cert_key_full_dir_path = os.path.abspath(os.path.join(args[KEY_GGC_ROOT_PATH], cls.CERT_KEY_DIR))
        if not os.path.exists(cert_key_full_dir_path):
            os.makedirs(cert_key_full_dir_path)

        with ChangeDirectory(cert_key_full_dir_path):
            file_prefix = args[KEY_CORE_CERT_ID][:10]
            cert_file = cls.CERT_PEM_FILE_FORMAT.format(file_prefix)
            key_file = cls.PRIV_KEY_FILE_FORMAT.format(file_prefix)

            # owner read/write, group and others read-only
            with os.fdopen(os.open(cert_file, os.O_CREAT | os.O_WRONLY, 0o644), 'w') as cf:
                cf.write(args[KEY_CORE_CERT_PEM])
                args[KEY_CORE_CERT_FILE_LOCATION] = os.path.join(cert_key_full_dir_path, cert_file)
            del args[KEY_CORE_CERT_PEM]

            # owner read/write, group and others no permission, as this is **private key**
            with os.fdopen(os.open(key_file, os.O_CREAT | os.O_WRONLY, 0o600), 'w') as kf:
                kf.write(args[KEY_CORE_PRIV_KEY])
                args[KEY_CORE_PRIV_KEY_FILE_LOCATION] = os.path.join(cert_key_full_dir_path, key_file)
            del args[KEY_CORE_PRIV_KEY]

            # owner read/write, group and others read-only
            urlretrieve(url=ATS_ROOT_CA_RSA_2048_REMOTE_LOATION, filename=cls.ROOT_CA_FILE)
            os.chmod(cls.ROOT_CA_FILE, 0o644)
            args[KEY_ROOT_CA_FILE_LOCATION] = os.path.join(cert_key_full_dir_path, cls.ROOT_CA_FILE)


class CoreSoftwareBootstrap(Step):
    CORE_SOFTWARE_FILE = "greengrass.tar.gz"
    OPEN_WRT = "openwrt"
    ARCHITECTURE_OVERRIDE = {
        PLATFORM_X86_64: "x86-64",
    }

    def __init__(self, args):
        super(CoreSoftwareBootstrap, self).__init__(args)

    def execute(self):
        logger = self._args.get(KEY_LOGGER)
        msg = "Configuring the Greengrass core software..."
        logger.verbose(msg)

        with yaspin().shark:
            CoreSoftwareBootstrap.download_and_unpack(self._args)

        return self._args

    @classmethod
    def download_and_unpack(cls, args):
        logger = args.get(KEY_LOGGER)
        try:
            software_url = cls.find_ggc_software_remote_location(args)
            logger.debug("Downloading the GGC software package from {}.".format(software_url))
            urlretrieve(url=software_url, filename=cls.CORE_SOFTWARE_FILE)

            ggc_full_root_path = os.path.abspath(args[KEY_GGC_ROOT_PATH])
            logger.debug("Unpacking the GGC software package to {}.".format(ggc_full_root_path))

            # TarFile does not provide an easy context manager that manages fd closure
            tf = None
            try:
                tf = tarfile.open(cls.CORE_SOFTWARE_FILE, "r:gz")
                tf.extractall(path=ggc_full_root_path)
            finally:
                if tf is not None:
                    tf.close()
        finally:
            remove_file_or_dir(cls.CORE_SOFTWARE_FILE)
            logger.debug("Remove {}.".format(cls.CORE_SOFTWARE_FILE))

    @classmethod
    def find_ggc_software_remote_location(cls, args):
        distribution = "linux"
        if cls.OPEN_WRT in repr(distro.linux_distribution()).lower():
            distribution = cls.OPEN_WRT
        architecture = cls.ARCHITECTURE_OVERRIDE.get(args[KEY_ARCHITECTURE], args[KEY_ARCHITECTURE])

        return GGC_SOFTWARE_REMOTE_LOCATION_FORMAT.format(args[KEY_GGC_VERSION], distribution, architecture)


class PostBootstrap(Step):
    KEY_DEPLOYMENT_ID = 'DeploymentId'
    KEY_DEPLOYMENT_ARN = 'DeploymentArn'
    KEY_DEPLOYMENT_STATUS = 'DeploymentStatus'
    KEY_ERROR_MESSAGE = 'ErrorMessage'

    def __init__(self, args):
        super(PostBootstrap, self).__init__(args)

    def execute(self):
        try:
            session = self._args[KEY_BOTO_SESSION]
            PostBootstrap.try_handle_deployment(self._args, session)
            PostBootstrap.display_bootstrap_result(self._args)
        finally:
            remove_config_file(self._args)
        return self._args

    @classmethod
    def try_handle_deployment(cls, args, session):
        if args[KEY_HAS_HELLO_WORLD_LAMBDA] is True:
            logger = args.get(KEY_LOGGER)
            logger.info("Configuring the group deployment...")

            PostBootstrap.prepare_deployment(args, session)

            spinner = yaspin().shark
            spinner.start()
            try:
                PostBootstrap.wait_until_deployment_done(args, session)
            except:
                spinner.stop()
                raise

            spinner.stop()
            logger.info("The group deployment is complete.\n")

    @classmethod
    def prepare_deployment(cls, args, session):
        logger = args.get(KEY_LOGGER)
        logger.debug("Creating a deployment for the group...")
        gg_client = session.client(GREENGRASS)

        # To create a deployment for HelloWorld Function
        create_deployment_response = gg_client.create_deployment(
            DeploymentType='NewDeployment',
            GroupId=args[KEY_GROUP_ID],
            GroupVersionId=args[KEY_GROUP_DEF_VER_ID],
        )
        args[KEY_DEPLOYMENT_ARN] = create_deployment_response[cls.KEY_DEPLOYMENT_ARN]
        args[KEY_DEPLOYMENT_ID] = create_deployment_response[cls.KEY_DEPLOYMENT_ID]

    @classmethod
    def wait_until_deployment_done(cls, args, session):
        gg_client = session.client(GREENGRASS)
        logger = args.get(KEY_LOGGER)
        logger.debug("Getting the deployment status...")
        try:
            deployment_status_response = retry_template(cls.check_deployment_status, args, gg_client)
            final_deployment_result = deployment_status_response[cls.KEY_DEPLOYMENT_STATUS]
            logger.debug("The status of group deployment is %s" % final_deployment_result)
            if final_deployment_result == "Failure":
                raise StepError(code=StepError.ERR_POST_BOOTSTRAP, message="Group deployment has failed. Detail: %s"
                                % deployment_status_response[cls.KEY_ERROR_MESSAGE])
        except StepError:
            raise
        except Exception:
            msg = "Group deployment has failed. Exceeded the upper bound time for deployment."
            logger.debug(msg)
            raise StepError(code=StepError.ERR_POST_BOOTSTRAP, message=msg)

    @classmethod
    def check_deployment_status(cls, args, gg_client):
        logger = args.get(KEY_LOGGER)
        deployment_status_response = gg_client.get_deployment_status(
            DeploymentId=args[KEY_DEPLOYMENT_ID],
            GroupId=args[KEY_GROUP_ID]
        )
        deployment_status_detail = deployment_status_response[cls.KEY_DEPLOYMENT_STATUS]
        if deployment_status_detail != "Success" and deployment_status_detail != "Failure":
            logger.debug('Deployment is {}. Querying the deployment status again.'.format(deployment_status_detail))
            raise Exception
        return deployment_status_response

    @staticmethod
    def display_bootstrap_result(args):
        print("\n=======================================================================================\n")

        print("Your device is running the Greengrass core software. ")
        if args[KEY_HAS_HELLO_WORLD_LAMBDA]:
              print("Your Greengrass group and Hello World Lambda function were deployed to the core device.\n")
        else:
              print("Your Greengrass group was created.\n")
        print("\nSetup information:\n")
        print("Device info: " + str(args[KEY_DEVICE_PLATFORM]))
        print("Greengrass core software location: " + str(args[KEY_GGC_ROOT_PATH]))
        print("Installed Greengrass core software version: " + str(args[KEY_GGC_VERSION]))
        print("Greengrass core: " + str(args[KEY_CORE_THING_ARN]))
        print("Greengrass core IoT certificate: " + str(args[KEY_CORE_CERT_ARN]))
        print("Greengrass core IoT certificate location: " + str(args[KEY_CORE_CERT_FILE_LOCATION]))
        print("Greengrass core IoT key location: " + str(args[KEY_CORE_PRIV_KEY_FILE_LOCATION]))
        print("Deployed Greengrass group name: " + str(args[KEY_GROUP_NAME]))
        print("Deployed Greengrass group ID: " + str(args[KEY_GROUP_ID]))
        print("Deployed Greengrass group version: " + str(args[KEY_GROUP_DEF_VER_ARN]))
        print("Greengrass service role: " + str(args[KEY_GG_ACCOUNT_SERVICE_ROLE]))
        print("GreengrassDeviceSetup log location: " + args[KEY_LOG_FILE])

        if args[KEY_HAS_HELLO_WORLD_LAMBDA]:
            print("Deployed the HelloWorld Lambda function: " + args.get(KEY_HELLO_WORLD_LAMBDA_VERSIONED_ARN, "None"))
            print("Hello-world subscriber topic: hello/world")
            print("\nYou can now use the AWS IoT Console to subscribe \n"
                  "to the 'hello/world' topic to receive messages published from your \n"
                  "Greengrass core.")
        else:
            print("\nYou can now use AWS IoT Console to manage your Greengrass group.\n")

        print("\n=======================================================================================\n")


def remove_config_file(args):
    logger = args.get(KEY_LOGGER)
    gg_device_setup_config_info_file = args[KEY_CONFIG_INFO_FILE_PATH]
    remove_file_or_dir(gg_device_setup_config_info_file)
    logger.debug("Remove GreengrassDeviceSetup.config.info")


# util methods/classes
def recursive_sort(data):
    if isinstance(data, list):
        for item in data:
            recursive_sort(item)
        data.sort(key=lambda x: str(x))
    if isinstance(data, dict):
        for value in data.values():
            recursive_sort(value)


def remove_file_or_dir(file_or_dir_path):
    if not os.path.exists(file_or_dir_path):
        return
    if not os.path.isdir(file_or_dir_path):
        os.remove(file_or_dir_path)
    else:
        os.rmdir(file_or_dir_path)


def build_config_info_file(args):
    config_info = {}
    for key, value in args.items():
        # We persist the user input required by GreengrassDeviceSetup but skip the sensitive ones,
        # which we request another round of user input after reboot.
        if key in ArgsCollection.ARG_VALIDATORS.keys() and \
                key in ArgsCollection.REQUIRED_ARGS_IN_ORDER:
            config_info[key] = value
    config_info_file = args.get(KEY_CONFIG_INFO_FILE_PATH)
    with open(config_info_file, "w") as f:
        json.dump(config_info, f)


def get_gg_ats_data_endpoint(region):
    if region == "cn-north-1":  # BJS is so special
        return "greengrass.ats.iot.cn-north-1.amazonaws.com.cn"
    return "greengrass-ats.iot.{}.amazonaws.com".format(region)


# wait 2^n * 1000 milliseconds between each retry, up to CONFIG_DEPLOYMENT_TIMEOUT milliseconds
@retry(wait_exponential_multiplier=1000, wait_exponential_max=16000, stop_max_delay=CONFIG_DEPLOYMENT_TIMEOUT*1000)
def retry_template(func, *args):
    return func(*args)


# util classes
class StepError(Exception):
    # Available error codes
    ERR_ENV_PREVALIDATE = 1
    ERR_GG_ENV_BOOTSTRAP = 2
    ERR_GG_CLOUD_BOOTSTRAP = 3
    ERR_GG_START = 4
    ERR_POST_BOOTSTRAP = 5
    ERR_INVALID_CREDENTIALS = 6
    ERR_MOUNT_CGROUP = 7
    ERR_ARG_COLLECTION = 8
    ERR_UNKNOWN = 255

    EXCP_MSG_FMT = "Code {}, Message: {}"

    def __init__(self, code, message):
        super(Exception, self).__init__(StepError.EXCP_MSG_FMT.format(code, message))
        self._code = code
        self._msg = message

    @property
    def code(self):
        return self._code

    @property
    def msg(self):
        return self._msg


# context manager that guarantees switching back to original directory when outside the context
class ChangeDirectory:

    def __init__(self, new_path):
        self.new_path = os.path.expanduser(new_path)

    def __enter__(self):
        self.saved_path = os.getcwd()
        os.chdir(self.new_path)

    def __exit__(self, etype, value, traceback):
        os.chdir(self.saved_path)


# entry point
if __name__ == "__main__":
    main()

EOF
)

# show spinning wheel
spin()
{
    sp='/-\|'
    while true; do
        printf '\b%.1s\b' "$sp"
        sp=${sp#?}${sp%???}
        sleep $SLEEP_TIME
    done
}

# Start the spinner
start_spinner(){
    # sleep time in Openwrt must be integer
    if [ "$PKG_TOOL" = "$OPKG" ]; then
        SLEEP_TIME=1
    fi
    spin &
    SPIN_PID=$!
    trap 'kill -9 $SPIN_PID' $(seq 1 15)
}

# Stop the spinner
stop_spinner(){
    if [ ! "$SPIN_PID" = "spin_pid" ]; then
        printf "\b"

        kill -9 $SPIN_PID
        CMD_EXIT_CODE=$?
        if [ $CMD_EXIT_CODE -eq 0 ]; then
          SPIN_PID="spin_pid"
        fi
    fi
}

# Functions for clean-ups
clean_up_pip()
{
    if [ -d "$PIP_INSTALL_PATH" ]; then

      LOG_MSG="$ECHO_HEADER Cleaning up the dedicated $PIP for greengrass device setup..."
      log

      LOG_MSG="$ECHO_HEADER Cleaning up $GET_PIP_PY_DOWNLOAD_DIR/$GET_PIP_PY ..."
      log
      $RM -f "$GET_PIP_PY_DOWNLOAD_DIR/$GET_PIP_PY" >> $GG_DEVICE_SETUP_SHELL_LOG_FILE 2>&1

      LOG_MSG="$ECHO_HEADER Cleaning up $PIP_INSTALL_PATH ..."
      log
      $RM -rf $PIP_INSTALL_PATH >> $GG_DEVICE_SETUP_SHELL_LOG_FILE 2>&1

    fi
}

clean_up_all()
{
    clean_up_pip
}

# Functions for clean exit
clean_exit()
{
    stop_spinner
    clean_up_all
    exit $CMD_EXIT_CODE
}

# Functions to emit message to log file
log()
{
    echo "$LOG_MSG" >> $GG_DEVICE_SETUP_SHELL_LOG_FILE
}

print()
{
    echo "$LOG_MSG"
}

print_and_log()
{
    print
    log
}

print_help_info()
{
    echo "Usage:"
    echo "sudo -E ./gg-device-setup-latest.sh"
    echo "    [ -h | --help ]"
    echo "    [ -v | --version ]"
    echo "    { bootstrap-greengrass-interactive | bootstrap-greengrass }"
    echo ""
    echo ""
    echo "--help"
    echo "Prints this help info. Can also be run as ./gg-device-setup-latest.sh --help"
    echo ""
    echo "--version"
    echo "Prints the version of GreengrassDeviceSetup. Can also be run as ./gg-device-setup-latest.sh --version"
    echo ""
    echo "bootstrap-greengrass-interactive"
    echo "Starts bootstrapping the Greengrass core in interactive mode."
    echo ""
    echo "bootstrap-greengrass"
    echo "Starts bootstrapping the Greengrass core in CLI mode."
    echo "To see more optional arguments, run as sudo -E ./gg-device-setup-latest.sh bootstrap-greengrass -h"
    echo ""
    echo "--verbose"
    echo "Makes GreengrassDeviceSetup verbose during the operation. e.g. sudo -E ./gg-device-setup-latest.sh bootstrap-greengrass-interactive --verbose"
}

# Functions to parse command line params
parse_cmdline()
{
    # Block wrong param
    if [ "$#" -eq 0 ]; then
        print_help_info
        CMD_EXIT_CODE=$ERR_PARAM
        exit $CMD_EXIT_CODE
    fi

    while [ "$#" -gt 0 ]
    do
        case "$1" in
            -v | --version)
                echo "v$GG_DEVICE_SETUP_VERSION"
                CMD_EXIT_CODE=$NO_ERR
                exit
                ;;
            bootstrap-greengrass-interactive)
                break
                ;;
            bootstrap-greengrass)
                break
                ;;
            -h | --help)
                print_help_info
                CMD_EXIT_CODE=$NO_ERR
                exit $CMD_EXIT_CODE
                ;;
            *)
                print_help_info
                CMD_EXIT_CODE=$ERR_PARAM
                exit $CMD_EXIT_CODE
                ;;
        esac
        shift
    done
}

# Functions to validate root permissions
validate_run_as_root()
{
    if [ ! "$($ID -u)" = 0 ]; then
        echo "The script needs to be run using sudo"
        CMD_EXIT_CODE=$ERR_NO_ROOT
        exit $CMD_EXIT_CODE
    fi
}

# Functions to prepare /tmp
prepare_root_tmp_dir()
{
    $MKDIR -p $TMP_DIR > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Not able to create directory: $TMP_DIR"
        CMD_EXIT_CODE=$ERR_NO_TMP_DIR
        exit $CMD_EXIT_CODE
    fi
}

# Functions to prepare GreengrassDeviceSetup shell log file
prepare_gg_device_setup_shell_log()
{
    LINUX_EPOCH=$(${DATE} +"%s")
    GG_DEVICE_SETUP_SHELL_LOG_FILE="$GG_DEVICE_SETUP_SHELL_LOG_PATH/greengrass-device-setup-bootstrap-$LINUX_EPOCH.log"

    type > "$GG_DEVICE_SETUP_SHELL_LOG_FILE"
    if [ $? -ne 0 ]; then
        echo "Not able to create log file for GreengrassDeviceSetup bootstrap at: $GG_DEVICE_SETUP_SHELL_LOG_FILE"
        CMD_EXIT_CODE=$ERR_LOG_FILE
        clean_exit
    fi
}

# Functions to display banner
display_banner()
{
    LOG_MSG="############### Greengrass Device Setup v$GG_DEVICE_SETUP_VERSION ###############"
    print_and_log

    LOG_MSG="$ECHO_HEADER The Greengrass Device Setup bootstrap log is available at: $GG_DEVICE_SETUP_SHELL_LOG_FILE"
    print_and_log
}

check_if_command_present()
{
  INPUT_CMD="$1"

  if ! type "$INPUT_CMD" > /dev/null 2>&1; then
      LOG_MSG="The '$INPUT_CMD' command not found."
      print_and_log

      CMD_EXIT_CODE=$ERR_PREREQ
      clean_exit
  fi
}

validate_prereq()
{
    LOG_MSG="$ECHO_HEADER Validating pre-requisites..."
    log

    check_if_command_present "id"
    check_if_command_present "cat"
    check_if_command_present "cd"
    check_if_command_present "date"
    check_if_command_present "mkdir"
    check_if_command_present "printf"
    check_if_command_present "sleep"
    check_if_command_present "kill"
    check_if_command_present "trap"
    check_if_command_present "seq"
    check_if_command_present "find"
}


# Functions to identify package tool
identify_package_tool()
{
    LOG_MSG="$ECHO_HEADER Identifying package management tool..."
    log

    if type $APT_GET > /dev/null 2>&1; then
        PKG_TOOL=$APT_GET
        export DEBIAN_FRONTEND=noninteractive
    elif type $APT > /dev/null 2>&1; then
        PKG_TOOL=$APT
        export DEBIAN_FRONTEND=noninteractive
    elif type $YUM > /dev/null 2>&1; then
        PKG_TOOL=$YUM
    elif type $OPKG > /dev/null 2>&1; then
        PKG_TOOL=$OPKG
    fi

    if [ "$PKG_TOOL" = "@missing@" ]; then
        LOG_MSG="$ECHO_HEADER Not able to find any of the supported package management tools: $APT, $APT_GET, $YUM, $OPKG."
        print_and_log
        CMD_EXIT_CODE=$ERR_PKG_TOOL
        clean_exit
    fi

    LOG_MSG="$ECHO_HEADER Using package management tool: $PKG_TOOL..."
    print_and_log
}

# Functions to update package list
update_package_list_standard()
{
    $PKG_TOOL update -y >> "$GG_DEVICE_SETUP_SHELL_LOG_FILE" 2>&1
    CMD_EXIT_CODE=$?
}

update_package_list_opkg()
{
    $PKG_TOOL update >> "$GG_DEVICE_SETUP_SHELL_LOG_FILE" 2>&1  # opkg does not require '-y' option
    CMD_EXIT_CODE=$?
}

update_package_list()
{
    LOG_MSG="$ECHO_HEADER Updating package list..."
    log

    case $PKG_TOOL in
        "$APT_GET")
            update_package_list_standard
            ;;
        "$APT")
            update_package_list_standard
            ;;
        "$YUM")
            update_package_list_standard
            ;;
        "$OPKG")
            update_package_list_opkg
            ;;
    esac

    if [ $CMD_EXIT_CODE -ne 0 ]; then
        LOG_MSG="$ECHO_HEADER Not able to update package list."
        print_and_log
        CMD_EXIT_CODE=$ERR_UPDATE_PKG_LIST
        clean_exit
    fi
}

try_update_package_list()
{
    if [ "$PKG_LIST_UPDATED" -ne 0 ]; then
        update_package_list
        PKG_LIST_UPDATED=0
    fi
}

# Functions to validate python version
install_python_standard()
{
    $PKG_TOOL install -y $PYTHON37 >> "$GG_DEVICE_SETUP_SHELL_LOG_FILE" 2>&1
    CMD_EXIT_CODE=$?
}

install_python_opkg()
{
    $PKG_TOOL install $PYTHON3 >> "$GG_DEVICE_SETUP_SHELL_LOG_FILE" 2>&1
    CMD_EXIT_CODE=$?
}

reinstall_module_apt_pkg_for_python37()
{
  if [ "$PKG_TOOL" = "$APT" ] || [ "$PKG_TOOL" = "$APT_GET" ]; then

    $PKG_TOOL remove -y python3-apt >> "$GG_DEVICE_SETUP_SHELL_LOG_FILE" 2>&1
    CMD_EXIT_CODE=$?
    if [ $CMD_EXIT_CODE -ne 0 ]; then
      LOG_MSG="$ECHO_HEADER Not able to config module - apt_pkg for Python ($PYTHON37)."
      print_and_log
      CMD_EXIT_CODE=$ERR_PYTHON
    fi

    if [ $CMD_EXIT_CODE -ne $ERR_PYTHON ]; then
      $PKG_TOOL install -y python3-apt >> "$GG_DEVICE_SETUP_SHELL_LOG_FILE" 2>&1
      CMD_EXIT_CODE=$?
      if [ $CMD_EXIT_CODE -ne 0 ]; then
        LOG_MSG="$ECHO_HEADER Not able to config module - apt_pkg for Python ($PYTHON37)."
        print_and_log
        CMD_EXIT_CODE=$ERR_PYTHON
      fi
    fi

  fi
}

install_python37()
{
    try_update_package_list

    case $PKG_TOOL in
        "$APT_GET")
            install_python_standard
            ;;
        "$APT")
            install_python_standard
            ;;
        "$YUM")
            install_python_standard
            ;;
        "$OPKG")
            install_python_opkg
            ;;
        *)
            LOG_MSG="$ECHO_HEADER Unrecognized package management tool: $PKG_TOOL."
            print_and_log
            CMD_EXIT_CODE=$ERR_PKG_TOOL
            clean_exit
            ;;
    esac
}


validate_python37()
{
    LOG_MSG="$ECHO_HEADER Looking for Python3.7..."
    log

    if ! type $PYTHON37 > /dev/null 2>&1; then
        LOG_MSG="$ECHO_HEADER Python ($PYTHON37) not found. Attempting to install it..."
        print_and_log

        install_python37

        if [ $CMD_EXIT_CODE -ne 0 ]; then
            LOG_MSG="$ECHO_HEADER Not able to install Python ($PYTHON37)."
            print_and_log
            CMD_EXIT_CODE=$ERR_PYTHON
        fi

        if [ $CMD_EXIT_CODE -ne $ERR_PYTHON ]; then
          if ! type $PYTHON37 > /dev/null 2>&1; then
              LOG_MSG="$ECHO_HEADER Python ($PYTHON37) still not found after installation attempt."
              print_and_log
              CMD_EXIT_CODE=$ERR_PYTHON
          else
              reinstall_module_apt_pkg_for_python37
          fi
        fi

    fi
}

validate_python_version()
{
    # Check whether python37 exists. If not, install python 3.7.
    validate_python37
    PYTHON_USED=$PYTHON37

    if [ $CMD_EXIT_CODE -eq $ERR_PYTHON ]; then
      # Check whether other python exsits. If not, exit with error message.
      LOG_MSG="$ECHO_HEADER Looking for other installed Python..."
      log
      # find all the installed python on the target device, and take the first one in the returned list
      PYTHON_CANDIDATE=$(find / -name python* 2>/dev/null | grep '[2-3].[0-9]$' | sed 1q)
      # get the python version e.g. python3.5 from PYTHON_CANDIDATE - "/usr/bin/python3.5"
      PYTHON_USED=${PYTHON_CANDIDATE##*/}
      if [ -z "$PYTHON_CANDIDATE" ] ; then
        CMD_EXIT_CODE=$ERR_PYTHON
        LOG_MSG="There is no Python available to proceed GreengrassDeviceSetup. Install Python manually to continue."
        print_and_log
        clean_exit
      fi
    fi

    LOG_MSG="$ECHO_HEADER Using runtime: $PYTHON_USED..."
    print_and_log
}

# Functions to validate pip version
install_wget_standard()
{
    $PKG_TOOL install -y $WGET >> "$GG_DEVICE_SETUP_SHELL_LOG_FILE" 2>&1
    CMD_EXIT_CODE=$?
}

install_wget_opkg()
{
    $PKG_TOOL install $WGET >> "$GG_DEVICE_SETUP_SHELL_LOG_FILE" 2>&1  # opkg install does not require '-y' option
    CMD_EXIT_CODE=$?
}

install_wget()
{
    try_update_package_list

    case $PKG_TOOL in
        "$APT_GET")
            install_wget_standard
            ;;
        "$APT")
            install_wget_standard
            ;;
        "$YUM")
            install_wget_standard
            ;;
        "$OPKG")
            install_wget_opkg
            ;;
        *)
            LOG_MSG="$ECHO_HEADER Unrecognized package management tool: $PKG_TOOL."
            print_and_log
            CMD_EXIT_CODE=$ERR_PKG_TOOL
            clean_exit
            ;;
    esac
}

ensure_wget()
{
    if ! type $WGET > /dev/null 2>&1; then
        LOG_MSG="$ECHO_HEADER $WGET not found. Try installing it..."
        print_and_log

        install_wget

        if [ $CMD_EXIT_CODE -ne 0 ]; then
            LOG_MSG="Not able to install $WGET."
            print_and_log
            CMD_EXIT_CODE=$ERR_WGET
            clean_exit
        fi
    fi
}

install_pip_via_get_pip_py()
{
    ensure_wget

    LOG_MSG="$ECHO_HEADER Installing a dedicated $PIP for Greengrass Device Setup..."
    print_and_log

    $WGET $GET_PIP_PY_URL -O "$GET_PIP_PY_DOWNLOAD_DIR/$GET_PIP_PY" >> "$GG_DEVICE_SETUP_SHELL_LOG_FILE" 2>&1
    CMD_EXIT_CODE=$?

    if [ $CMD_EXIT_CODE -ne 0 ]; then
       case $PKG_TOOL in
            "$APT_GET")
                LOG_MSG="$ECHO_HEADER Not able to download get-pip.py."
                print_and_log
                CMD_EXIT_CODE=$ERR_WGET
                clean_exit
                ;;
            "$APT")
                LOG_MSG="$ECHO_HEADER Not able to download get-pip.py."
                print_and_log
                CMD_EXIT_CODE=$ERR_WGET
                clean_exit
                ;;
            "$YUM")
                LOG_MSG="$ECHO_HEADER Not able to download get-pip.py."
                print_and_log
                CMD_EXIT_CODE=$ERR_WGET
                clean_exit
                ;;
            "$OPKG")
                LOG_MSG="$ECHO_HEADER Not able to download get-pip.py with $PKG_TOOL."
                log
                LOG_MSG="$ECHO_HEADER Will retry after updating certificates and ssl lib..."
                log

                LOG_MSG="$ECHO_HEADER Installing ca-bundle..."
                log

                $PKG_TOOL install ca-bundle >> "$GG_DEVICE_SETUP_SHELL_LOG_FILE" 2>&1
                CMD_EXIT_CODE=$?
                if [ $CMD_EXIT_CODE -ne 0 ]; then
                    LOG_MSG="$ECHO_HEADER Not able to install required dependencies - ca-bundle for pip installation."
                    print_and_log
                    CMD_EXIT_CODE=$ERR_WGET
                    clean_exit
                fi

                LOG_MSG="$ECHO_HEADER Installing ca-certificates..."
                log

                $PKG_TOOL install ca-certificates >> "$GG_DEVICE_SETUP_SHELL_LOG_FILE" 2>&1
                CMD_EXIT_CODE=$?
                if [ $CMD_EXIT_CODE -ne 0 ]; then
                    LOG_MSG="$ECHO_HEADER Not able to install required dependencies - ca-certificates for pip installation."
                    print_and_log
                    CMD_EXIT_CODE=$ERR_WGET
                    clean_exit
                fi

                LOG_MSG="$ECHO_HEADER Installing libustream-openssl..."
                log

                $PKG_TOOL install libustream-openssl >> "$GG_DEVICE_SETUP_SHELL_LOG_FILE" 2>&1
                CMD_EXIT_CODE=$?
                if [ $CMD_EXIT_CODE -ne 0 ]; then
                    LOG_MSG="$ECHO_HEADER Not able to install required dependencies - libustream-openssl for pip installation."
                    print_and_log
                    CMD_EXIT_CODE=$ERR_WGET
                    clean_exit
                fi

                LOG_MSG="$ECHO_HEADER Now retry downloading get-pip.py..."
                log

                $WGET $GET_PIP_PY_URL -O "$GET_PIP_PY_DOWNLOAD_DIR/$GET_PIP_PY" >> "$GG_DEVICE_SETUP_SHELL_LOG_FILE" 2>&1
                CMD_EXIT_CODE=$?
                if [ $CMD_EXIT_CODE -ne 0 ]; then
                    LOG_MSG="$ECHO_HEADER Still not able to download get-pip.py after error mitigation attempt."
                    print_and_log
                    CMD_EXIT_CODE=$ERR_WGET
                    clean_exit
                fi
                ;;
       esac
    fi

    if [ "$PYTHON_USED" = "$PYTHON37" ] && { [ "$PKG_TOOL" = "$APT" ] || [ "$PKG_TOOL" = "$APT_GET" ] ;}; then
      $PKG_TOOL install -y python3-distutils >> "$GG_DEVICE_SETUP_SHELL_LOG_FILE" 2>&1

      CMD_EXIT_CODE=$?
      if [ $CMD_EXIT_CODE -ne 0 ]; then
          LOG_MSG="$ECHO_HEADER Not able to install required dependencies - python3-distutils for pip installation."
          print_and_log
          CMD_EXIT_CODE=$ERR_GET_PIP_PY
          clean_exit
      fi
    fi

    $PYTHON_USED "$GET_PIP_PY_DOWNLOAD_DIR/$GET_PIP_PY" --prefix $PIP_INSTALL_PATH --no-setuptools --no-wheel >> "$GG_DEVICE_SETUP_SHELL_LOG_FILE" 2>&1

    CMD_EXIT_CODE=$?
    if [ $CMD_EXIT_CODE -ne 0 ]; then
        LOG_MSG="$ECHO_HEADER Not able to install pip with get-pip.py."
        print_and_log
        CMD_EXIT_CODE=$ERR_GET_PIP_PY
        clean_exit
    fi
}

# Functions to ensure Python dependencies
move_to_pip_dir()
{
    MY_PWD="$PWD"

    LOG_MSG="$ECHO_HEADER Remembering current directory: $MY_PWD"
    log

    PIP_IMPORT_PATH="$TMP_DIR/greengrass-device-setup-bootstrap-tmp/lib/$PYTHON_USED/site-packages"

    $CD "$PIP_IMPORT_PATH" >> "$GG_DEVICE_SETUP_SHELL_LOG_FILE" 2>&1
    CMD_EXIT_CODE=$?
    if [ $CMD_EXIT_CODE -ne 0 ]; then
        LOG_MSG="$ECHO_HEADER Not able to change directory to: $PIP_IMPORT_PATH"
        print_and_log
        CMD_EXIT_CODE=$ERR_CD
        clean_exit
    fi

    LOG_MSG="$ECHO_HEADER Changed directory to: $PIP_IMPORT_PATH"
    log
}

move_away_from_pip_dir()
{
    $CD "$MY_PWD" >> "$GG_DEVICE_SETUP_SHELL_LOG_FILE" 2>&1
    CMD_EXIT_CODE=$?
    if [ $CMD_EXIT_CODE -ne 0 ]; then
        LOG_MSG="$ECHO_HEADER Not able to change directory back to original one: $MY_PWD"
        print_and_log
        CMD_EXIT_CODE=$ERR_CD
        clean_exit
    fi

    LOG_MSG="$ECHO_HEADER Changed directory back to: $MY_PWD"
    log
}

validate_dependency_and_install_if_missing()
{
  INPUT_DEPENDENCY="$1"
  OUTPUT_ERR_CODE="$2"

  LOG_MSG="$ECHO_HEADER Looking for $INPUT_DEPENDENCY..."
  log

  if ! $PYTHON_USED -m $PIP show "$INPUT_DEPENDENCY" > /dev/null 2>&1; then
      LOG_MSG="$ECHO_HEADER $INPUT_DEPENDENCY not found. Try installing it..."
      log

      $PYTHON_USED -m $PIP install "$INPUT_DEPENDENCY" >> "$GG_DEVICE_SETUP_SHELL_LOG_FILE" 2>&1

      CMD_EXIT_CODE=$?
      if [ $CMD_EXIT_CODE -ne 0 ]; then
          move_away_from_pip_dir

          LOG_MSG="$ECHO_HEADER Not able to install $INPUT_DEPENDENCY."
          print_and_log
          CMD_EXIT_CODE=$OUTPUT_ERR_CODE
          clean_exit
      fi
  fi
}

validate_retrying_installation()
{
    LOG_MSG="$ECHO_HEADER Looking for retrying..."
    log

    if ! $PYTHON_USED -m $PIP show $RETRYING > /dev/null 2>&1; then
        LOG_MSG="$ECHO_HEADER $RETRYING not found. Try looking for required dependencyis to install it..."
        log

        validate_dependency_and_install_if_missing "$SETUPTOOLS" "$ERR_SETUPTOOLS"
        validate_dependency_and_install_if_missing "$WHEEL" "$ERR_WHEEL"
        validate_dependency_and_install_if_missing "$RETRYING" "$ERR_RETRYING"
    fi
}

ensure_python_dependencies()
{
    move_to_pip_dir

    LOG_MSG="$ECHO_HEADER Validating and installing required dependencies..."
    print_and_log

    validate_dependency_and_install_if_missing "$BOTO3" "$ERR_BOTO3"
    validate_dependency_and_install_if_missing "$DISTRO" "$ERR_DISTRO"
    validate_dependency_and_install_if_missing "$CONFIGPARSER" "$ERR_CONFIGPARSER"
    validate_dependency_and_install_if_missing "$YASPIN" "$ERR_YASPIN"
    validate_retrying_installation

    move_away_from_pip_dir

    clean_up_pip
}

# Run python script with other command-line params propagated
run_gg_device_setup_python_core()
{
    LOG_MSG="$ECHO_HEADER The Greengrass Device Setup configuration is complete. Starting the Greengrass environment setup..."
    print_and_log

    LOG_MSG="$ECHO_HEADER Forwarding command-line parameters: $*"
    print_and_log
    printf "\n"

    # At this point, logging switch to python core
    $PYTHON_USED -c "$CODE" "$@"

    CMD_EXIT_CODE=$?
    clean_exit
}


main()
{
    parse_cmdline "$@"
    validate_run_as_root
    prepare_root_tmp_dir
    prepare_gg_device_setup_shell_log
    display_banner
    validate_prereq
    identify_package_tool

    start_spinner
    validate_python_version
    install_pip_via_get_pip_py
    ensure_python_dependencies
    stop_spinner

    run_gg_device_setup_python_core "$@"
}

main "$@"
