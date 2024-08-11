

```markdown
# Docker Cleanup Script

This script helps clean up unused Docker resources based on a specified Docker Compose file. It removes unused images, volumes, and networks while preserving resources defined in the Docker Compose file and those used by running containers.

## Usage

```
./docker_cleanup.sh <docker-compose-file> [--dry-run] [--include-stopped]
```

### Options

- `<docker-compose-file>`: Path to your Docker Compose file (required)
- `--dry-run`: Show what would be removed without actually removing anything
- `--include-stopped`: Allow removal of resources used by stopped containers

## Examples

1. Basic usage:
   ```
   ./docker_cleanup.sh docker-compose.yml
   ```
   Cleans up unused resources while keeping images used by any containers (running or stopped) defined in the Docker Compose file or currently on the system.

2. Using the dry-run option:
   ```
   ./docker_cleanup.sh docker-compose.yml --dry-run
   ```
   Shows what the script would do without making any changes.

3. Including stopped containers in the cleanup:
   ```
   ./docker_cleanup.sh docker-compose.yml --include-stopped
   ```
   Allows removal of images used by stopped containers not defined in the Docker Compose file.

4. Combining options:
   ```
   ./docker_cleanup.sh docker-compose.yml --dry-run --include-stopped
   ```
   Shows what would be removed, including resources used by stopped containers, without removing anything.

## Step-by-Step Guide

1. Save the script as `docker_cleanup.sh`.

2. Make the script executable:
   ```
   chmod +x docker_cleanup.sh
   ```

3. Run the script with your Docker Compose file:
   ```
   ./docker_cleanup.sh path/to/your/docker-compose.yml
   ```

4. To preview changes without removing anything, use `--dry-run`:
   ```
   ./docker_cleanup.sh path/to/your/docker-compose.yml --dry-run
   ```

5. Review the output. If satisfied, run without `--dry-run`.

6. To include stopped containers in the cleanup, add `--include-stopped`:
   ```
   ./docker_cleanup.sh path/to/your/docker-compose.yml --include-stopped
   ```

## Caution

Always use this script carefully, especially in production environments. It's recommended to use `--dry-run` first, review the output, and then run without it if you're certain about the changes.

```

This README provides a comprehensive guide on how to use the Docker cleanup script, including usage syntax, options, examples, and a step-by-step guide. 
It also includes a caution note to remind users to be careful when using the script, especially in production environments.
