# Copyright 2022 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

load("@rules_java//java:defs.bzl", "java_import")
load("//kotlin:js.bzl", "kt_js_import")
load("//kotlin:jvm.bzl", "kt_jvm_import")
load("//kotlin/internal:defs.bzl", _KT_COMPILER_REPO = "KT_COMPILER_REPO")
load("@com_github_jetbrains_kotlin//:artifacts.bzl", "KOTLINC_ARTIFACTS")

def _import_artifacts(artifacts, rule_kind):
    _import_labels(artifacts.plugin, rule_kind)
    _import_labels(artifacts.runtime, rule_kind)
    _import_labels(artifacts.compile, rule_kind, neverlink = 1)

def _import_labels(labels, rule_kind, **rule_args):
    for label in labels:
        if "-sources" in label:
            continue
        args = dict(rule_args.items())
        args["visibility"] = ["//visibility:public"]
        args["name"] = label
        args["jars"] = ["@%s//:%s" % (_KT_COMPILER_REPO, label)]
        sources = label + "-sources"
        if sources in labels:
            args["srcjar"] = "@%s//:%s" % (_KT_COMPILER_REPO, sources)
        rule_kind(**args)

def kt_configure_compiler():
    """
    Defines the toolchain_type and default toolchain for kotlin compilation.

    Must be called in kotlin/internal/BUILD.bazel
    """
    if native.package_name() != "kotlin/compiler":
        fail("kt_configure_compiler must be called in kotlin/compiler not %s" % native.package_name())

    _import_artifacts(KOTLINC_ARTIFACTS.js, kt_js_import)
    _import_artifacts(KOTLINC_ARTIFACTS.jvm, kt_jvm_import)
    _import_artifacts(KOTLINC_ARTIFACTS.core, kt_jvm_import)
