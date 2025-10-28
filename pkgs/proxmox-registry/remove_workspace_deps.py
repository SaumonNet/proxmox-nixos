#!/usr/bin/env python3
"""
Canonicalize a workspace crate by making it standalone.

This script processes a Cargo.toml file from a workspace crate and:
1. Resolves workspace dependencies by looking up their definitions in the workspace root
2. Converts workspace.dependencies references to explicit dependency declarations
3. Preserves internal workspace dependencies (assumes they're available in a registry)
4. Creates a standalone Cargo.toml that can be used outside the workspace
"""

import argparse
import sys
import toml
from pathlib import Path
from typing import Dict, Any, Optional


class WorkspaceCanonicalizer:
    def __init__(self, crate_path: Path, workspace_root: Optional[Path] = None):
        self.crate_path = Path(crate_path)
        self.workspace_root = workspace_root or self.find_workspace_root()

        if not self.workspace_root:
            raise ValueError("Could not find workspace root")

        self.workspace_cargo_toml = self.workspace_root / "Cargo.toml"
        self.crate_cargo_toml = self.crate_path / "Cargo.toml"

        if not self.workspace_cargo_toml.exists():
            raise FileNotFoundError(
                f"Workspace Cargo.toml not found at {self.workspace_cargo_toml}"
            )
        if not self.crate_cargo_toml.exists():
            raise FileNotFoundError(
                f"Crate Cargo.toml not found at {self.crate_cargo_toml}"
            )

    def find_workspace_root(self) -> Optional[Path]:
        """Find the workspace root by walking up the directory tree."""
        current = self.crate_path.parent

        while current != current.parent:  # Stop at filesystem root
            cargo_toml = current / "Cargo.toml"
            if cargo_toml.exists():
                try:
                    with open(cargo_toml, "r") as f:
                        data = toml.load(f)
                    if "workspace" in data:
                        return current
                except Exception:
                    pass
            current = current.parent

        return None

    def load_workspace_dependencies(self) -> Dict[str, Any]:
        """Load workspace dependencies from the workspace root Cargo.toml."""
        try:
            with open(self.workspace_cargo_toml, "r") as f:
                workspace_data = toml.load(f)

            return workspace_data.get("workspace", {}).get("dependencies", {})
        except Exception as e:
            raise ValueError(f"Failed to load workspace dependencies: {e}")

    def load_crate_manifest(self) -> Dict[str, Any]:
        """Load the crate's Cargo.toml."""
        try:
            with open(self.crate_cargo_toml, "r") as f:
                return toml.load(f)
        except Exception as e:
            raise ValueError(f"Failed to load crate manifest: {e}")

    def get_workspace_member_info(self) -> Dict[str, Dict[str, Any]]:
        """Get information about workspace members including their versions."""
        try:
            with open(self.workspace_cargo_toml, "r") as f:
                workspace_data = toml.load(f)

            members_info = {}
            workspace_info = workspace_data.get("workspace", {})

            # Add explicit members
            for member_path in workspace_info.get("members", []):
                member_full_path = self.workspace_root / member_path
                member_cargo_toml = member_full_path / "Cargo.toml"

                if member_cargo_toml.exists():
                    try:
                        with open(member_cargo_toml, "r") as f:
                            member_data = toml.load(f)

                        package_info = member_data.get("package", {})
                        package_name = package_info.get("name")
                        if package_name:
                            members_info[package_name] = {
                                "version": package_info.get("version", "0.1.0"),
                                "path": member_path,
                            }
                    except Exception:
                        continue

            return members_info
        except Exception:
            return {}

    def resolve_workspace_dependency(
        self,
        dep_name: str,
        dep_spec: Any,
        workspace_deps: Dict[str, Any],
        workspace_members: Dict[str, Dict[str, Any]],
    ) -> Any:
        """Resolve a workspace dependency specification."""
        if isinstance(dep_spec, dict) and dep_spec.get("workspace") is True:
            # This is a workspace dependency reference
            print(
                f"Debug: Resolving workspace dependency '{dep_name}'", file=sys.stderr
            )

            # First check if it's defined in workspace.dependencies
            if dep_name in workspace_deps:
                print(
                    f"Debug: Found '{dep_name}' in workspace.dependencies",
                    file=sys.stderr,
                )
                workspace_dep = workspace_deps[dep_name]

                # Handle both string and dict workspace dependencies
                if isinstance(workspace_dep, str):
                    resolved_dep = {"version": workspace_dep}
                else:
                    resolved_dep = workspace_dep.copy()

                # Preserve any crate-specific overrides
                for key, value in dep_spec.items():
                    if key != "workspace":
                        resolved_dep[key] = value

                # Remove path field since we're assuming registry availability
                resolved_dep.pop("path", None)

                print(
                    f"Debug: Resolved '{dep_name}' to {resolved_dep}", file=sys.stderr
                )
                return resolved_dep

            # If not in workspace.dependencies, check if it's a workspace member
            elif dep_name in workspace_members:
                print(f"Debug: Found '{dep_name}' as workspace member", file=sys.stderr)
                member_info = workspace_members[dep_name]
                resolved_dep = {"version": member_info["version"]}

                # Preserve any crate-specific overrides
                for key, value in dep_spec.items():
                    if key not in ["workspace", "path"]:
                        resolved_dep[key] = value

                print(
                    f"Debug: Resolved member '{dep_name}' to {resolved_dep}",
                    file=sys.stderr,
                )
                return resolved_dep

            else:
                print(
                    f"Debug: '{dep_name}' not found in workspace deps or members",
                    file=sys.stderr,
                )
                print(
                    f"Debug: Available workspace deps: {list(workspace_deps.keys())}",
                    file=sys.stderr,
                )
                print(
                    f"Debug: Available workspace members: {list(workspace_members.keys())}",
                    file=sys.stderr,
                )

                # If workspace dependency not found anywhere, try to create a minimal spec
                # Remove workspace = true and path, keep other fields
                resolved_dep = {}
                for key, value in dep_spec.items():
                    if key not in ["workspace", "path"]:
                        resolved_dep[key] = value

                # If no version specified and it's empty, this might be an error case
                if not resolved_dep:
                    print(
                        f"Warning: Could not resolve workspace dependency '{dep_name}' - no definition found in workspace",
                        file=sys.stderr,
                    )
                    return {"version": "*"}  # Fallback to any version

                return resolved_dep

        # For non-workspace dependencies, still strip path if present
        # (in case it's an internal dependency with explicit path)
        if isinstance(dep_spec, dict):
            canonicalized_spec = dep_spec.copy()
            canonicalized_spec.pop("path", None)
            return canonicalized_spec

        return dep_spec

    def canonicalize_dependencies(
        self,
        deps: Dict[str, Any],
        workspace_deps: Dict[str, Any],
        workspace_members: Dict[str, Dict[str, Any]],
    ) -> Dict[str, Any]:
        """Canonicalize a dependencies section."""
        if not deps:
            return deps

        canonicalized = {}

        for dep_name, dep_spec in deps.items():
            # All dependencies go through the same resolution process
            resolved_dep = self.resolve_workspace_dependency(
                dep_name, dep_spec, workspace_deps, workspace_members
            )

            # Only add the dependency if it's not empty and has meaningful content
            if resolved_dep and (
                isinstance(resolved_dep, str)
                or (isinstance(resolved_dep, dict) and resolved_dep)
            ):
                canonicalized[dep_name] = resolved_dep
            else:
                print(
                    f"Warning: Skipping empty dependency '{dep_name}' after resolution",
                    file=sys.stderr,
                )

        return canonicalized

    def canonicalize_manifest(self) -> Dict[str, Any]:
        """Canonicalize the entire crate manifest."""
        workspace_deps = self.load_workspace_dependencies()
        workspace_members = self.get_workspace_member_info()
        crate_manifest = self.load_crate_manifest()

        # Create a copy to avoid modifying the original
        canonicalized = crate_manifest.copy()

        # Process different dependency sections
        dep_sections = ["dependencies", "dev-dependencies", "build-dependencies"]

        for section in dep_sections:
            if section in canonicalized:
                canonicalized[section] = self.canonicalize_dependencies(
                    canonicalized[section], workspace_deps, workspace_members
                )

        # Handle target-specific dependencies
        if "target" in canonicalized:
            for target_name, target_config in canonicalized["target"].items():
                for section in dep_sections:
                    if section in target_config:
                        target_config[section] = self.canonicalize_dependencies(
                            target_config[section], workspace_deps, workspace_members
                        )

        # Remove workspace inheritance from package section if present
        if "package" in canonicalized:
            package = canonicalized["package"]

            # Remove workspace = true fields and resolve inherited values
            workspace_package = {}
            try:
                with open(self.workspace_cargo_toml, "r") as f:
                    workspace_data = toml.load(f)
                workspace_package = workspace_data.get("workspace", {}).get(
                    "package", {}
                )
            except Exception:
                pass

            # Resolve workspace inheritance for package fields
            inheritable_fields = [
                "version",
                "authors",
                "edition",
                "description",
                "documentation",
                "readme",
                "homepage",
                "repository",
                "license",
                "license-file",
                "keywords",
                "categories",
                "publish",
                "metadata",
            ]

            for field in inheritable_fields:
                if (
                    isinstance(package.get(field), dict)
                    and package[field].get("workspace") is True
                ):
                    if field in workspace_package:
                        package[field] = workspace_package[field]
                    else:
                        # Remove the workspace reference if no workspace value exists
                        del package[field]

        return canonicalized

    def write_canonicalized_manifest(self, output_path: Optional[Path] = None) -> None:
        """Write the canonicalized manifest to a file."""
        canonicalized = self.canonicalize_manifest()

        if output_path is None:
            output_path = self.crate_path / "Cargo.toml.canonical"

        with open(output_path, "w") as f:
            toml.dump(canonicalized, f)

        print(f"Canonicalized manifest written to: {output_path}")


def main():
    parser = argparse.ArgumentParser(
        description="Canonicalize a workspace crate by making it standalone"
    )
    parser.add_argument(
        "crate_path",
        type=Path,
        help="Path to the crate directory containing Cargo.toml",
    )
    parser.add_argument(
        "--workspace-root",
        type=Path,
        help="Path to workspace root (auto-detected if not provided)",
    )
    parser.add_argument(
        "--output",
        "-o",
        type=Path,
        help="Output path for canonicalized Cargo.toml (default: Cargo.toml.canonical)",
    )
    parser.add_argument(
        "--in-place", action="store_true", help="Overwrite the original Cargo.toml file"
    )

    args = parser.parse_args()

    try:
        canonicalizer = WorkspaceCanonicalizer(args.crate_path, args.workspace_root)

        if args.in_place:
            output_path = canonicalizer.crate_cargo_toml
        else:
            output_path = args.output

        canonicalizer.write_canonicalized_manifest(output_path)

    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
