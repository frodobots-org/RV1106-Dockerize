#!/bin/bash
#------------------------------------------------------------------------------
# Script Name: git-add-safe-directories.sh
# Description: Recursively add all Git repositories under a directory to Git's safe.directory list
# Usage Examples:
#   git-add-safe-directories.sh /path/to/projects
#   git-add-safe-directories.sh --dry-run --verbose ~/workspace
#------------------------------------------------------------------------------

# Version information
VERSION="1.0.0"

# Color definitions (if terminal supports)
if [ -t 1 ]; then
	RED=$(tput setaf 1)
	GREEN=$(tput setaf 2)
	YELLOW=$(tput setaf 3)
	RESET=$(tput sgr0)
else
	RED=""
	GREEN=""
	YELLOW=""
	RESET=""
fi

# Logging functions
log_info() {
	echo "${GREEN}[INFO]${RESET} $1"
}

log_warn() {
	echo "${YELLOW}[WARN]${RESET} $1"
}

log_error() {
	echo "${RED}[ERROR]${RESET} $1" >&2
}

# Show help information
show_help() {
	cat << EOF
Usage: $(basename "$0") [OPTIONS] [directory]

Recursively add all Git repositories under the specified directory to Git's safe.directory list.

Options:
  -h, --help            Show this help message and exit
  -v, --version         Show version information and exit
  -n, --dry-run         Only show directories to be added without actual execution
  -q, --quiet           Quiet mode, only show error messages
  --verbose             Verbose mode, show detailed processing information

Arguments:
  [directory]           Root directory to scan (default: current directory)

Examples:
  $(basename "$0") /path/to/projects       # Process specified directory
  $(basename "$0") --dry-run               # Preview operations in current directory
  $(basename "$0") -q ~/workspace          # Quiet mode processing workspace
EOF
}

# Main function
main() {
	local root_dir="$PWD"
	local dry_run=false
	local quiet=false
	local verbose=false

    # Parse command-line arguments
    while [[ $# -gt 0 ]]; do
	    case "$1" in
		    -h|--help)
			    show_help
			    exit 0
			    ;;
		    -v|--version)
			    echo "$(basename "$0") version $VERSION"
			    exit 0
			    ;;
		    -n|--dry-run)
			    dry_run=true
			    ;;
		    -q|--quiet)
			    quiet=true
			    ;;
		    --verbose)
			    verbose=true
			    ;;
		    *)
			    # Treat non-option argument as directory
			    if [[ "$1" != -* ]]; then
				    if [[ -d "$1" ]]; then
					    root_dir="$1"
				    else
					    log_error "Directory '$1' does not exist"
					    exit 1
				    fi
			    else
				    log_error "Unknown option: $1"
				    show_help
				    exit 1
			    fi
			    ;;
	    esac
	    shift
    done

    # Normalize directory path
    root_dir=$(realpath "$root_dir")

    # Check if Git is available
    if ! command -v git &> /dev/null; then
	    log_error "Git is not installed or cannot be accessed"
	    exit 1
    fi

    # Check if directory exists
    if [ ! -d "$root_dir" ]; then
	    log_error "Directory '$root_dir' does not exist"
	    exit 1
    fi

    if [ "$quiet" = false ]; then
	    log_info "Scanning directory: $root_dir"
    fi

    # Find all .git directories and process their parent directories
    local repo_count=0
    local error_count=0

    while IFS= read -r -d '' git_dir; do
	    repo_dir=$(dirname "$git_dir")

	    if [ "$dry_run" = true ]; then
		    if [ "$quiet" = false ]; then
			    echo "Would add: $repo_dir"
		    fi
	    else
		    if git config --global --add safe.directory "$repo_dir" 2>/dev/null; then
			    if [ "$quiet" = false ] || [ "$verbose" = true ]; then
				    echo "Added: $repo_dir"
			    fi
			    ((repo_count++))
		    else
			    log_error "Failed to add: $repo_dir"
			    ((error_count++))
		    fi
	    fi
    done < <(find "$root_dir" -name ".git" -print0 2>/dev/null)

    # Output results
    if [ "$repo_count" -eq 0 ] && [ "$error_count" -eq 0 ]; then
	    log_warn "No Git repositories found under '$root_dir' and its subdirectories"
    else
	    if [ "$dry_run" = true ]; then
		    log_info "Preview completed: Found $repo_count Git repositories"
	    else
		    log_info "Operation completed: Added $repo_count Git repositories, $error_count failed"
	    fi
    fi

    if [ "$error_count" -gt 0 ]; then
	    exit 1
    else
	    exit 0
    fi
}

# Script entry point
main "$@"
