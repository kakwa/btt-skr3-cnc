# rsyslog and logrotate Ansible Role

This role installs and configures rsyslog and logrotate for centralized logging and log rotation management.

## Features

- Installs rsyslog and logrotate packages
- Configures rsyslog with sensible defaults
- Manages file and directory permissions for logs
- Optional remote logging support
- Custom logrotate configurations for application-specific logs
- Validates logrotate configurations

## Requirements

- Debian/Ubuntu-based system
- Root/sudo access

## Role Variables

### Package Management

- `rsyslog_packages`: List of packages to install (default: `rsyslog`, `logrotate`)
- `rsyslog_service_enabled`: Enable rsyslog service (default: `true`)
- `rsyslog_service_state`: Service state (default: `started`)

### rsyslog Configuration

- `rsyslog_max_message_size`: Maximum message size (default: `8k`)
- `rsyslog_file_create_mode`: File creation mode (default: `0640`)
- `rsyslog_dir_create_mode`: Directory creation mode (default: `0755`)
- `rsyslog_file_owner`: Log file owner (default: `syslog`)
- `rsyslog_file_group`: Log file group (default: `adm`)

### Remote Logging

- `rsyslog_enable_remote_logging`: Enable remote logging (default: `false`)
- `rsyslog_remote_host`: Remote syslog server hostname/IP
- `rsyslog_remote_port`: Remote syslog server port (default: `514`)

### Custom Log Rotation

- `rsyslog_custom_logs`: List of custom log configurations (default: `[]`)
- `logrotate_frequency`: Global rotation frequency (default: `daily`)
- `logrotate_rotate_count`: Number of rotations to keep (default: `7`)
- `logrotate_compress`: Compress rotated logs (default: `true`)
- `logrotate_delaycompress`: Delay compression by one cycle (default: `true`)

## Example Playbooks

### Basic Installation

```yaml
---
- hosts: servers
  become: yes
  roles:
    - rsyslog
```

### With Remote Logging

```yaml
---
- hosts: servers
  become: yes
  roles:
    - role: rsyslog
      vars:
        rsyslog_enable_remote_logging: true
        rsyslog_remote_host: "syslog.example.com"
        rsyslog_remote_port: 514
```

### With Custom Log Rotation

```yaml
---
- hosts: servers
  become: yes
  roles:
    - role: rsyslog
      vars:
        rsyslog_custom_logs:
          - name: "gsender"
            path: "/var/log/gsender/*.log"
            options:
              - daily
              - rotate 7
              - compress
              - delaycompress
              - notifempty
              - create 0640 syslog adm
              - sharedscripts
            postrotate: "systemctl reload gsender > /dev/null 2>&1 || true"
          
          - name: "nginx-custom"
            path: "/var/log/nginx/gsender-*.log"
            options:
              - daily
              - rotate 14
              - compress
              - delaycompress
              - notifempty
              - create 0640 www-data adm
              - sharedscripts
            postrotate: "systemctl reload nginx > /dev/null 2>&1 || true"
```

### Complete Example with Multiple Services

```yaml
---
- hosts: cnc_machines
  become: yes
  roles:
    - role: rsyslog
      vars:
        rsyslog_enable_remote_logging: true
        rsyslog_remote_host: "192.168.1.100"
        rsyslog_max_message_size: "16k"
        rsyslog_custom_logs:
          - name: "gsender"
            path: "/var/log/gsender/*.log"
            options:
              - daily
              - rotate 30
              - compress
              - delaycompress
              - notifempty
              - missingok
              - create 0640 syslog adm
          - name: "cnc-operations"
            path: "/var/log/cnc/*.log"
            options:
              - weekly
              - rotate 52
              - compress
              - delaycompress
              - notifempty
              - create 0640 syslog adm
```

## Service Management

### Managing rsyslog

```bash
# Check service status
sudo systemctl status rsyslog

# Restart service
sudo systemctl restart rsyslog

# View logs
sudo journalctl -u rsyslog -f

# Test configuration
sudo rsyslogd -N1
```

### Managing logrotate

```bash
# Test logrotate configuration
sudo logrotate -d /etc/logrotate.conf

# Force rotation (dry-run)
sudo logrotate -d /etc/logrotate.d/gsender

# Force actual rotation
sudo logrotate -f /etc/logrotate.d/gsender

# View logrotate status
cat /var/lib/logrotate/status
```

## File Locations

- **rsyslog Config**: `/etc/rsyslog.conf`
- **rsyslog Config Dir**: `/etc/rsyslog.d/`
- **logrotate Config**: `/etc/logrotate.conf`
- **logrotate Config Dir**: `/etc/logrotate.d/`
- **System Logs**: `/var/log/syslog`, `/var/log/messages`
- **logrotate Status**: `/var/lib/logrotate/status`

## Log Rotation Options

Common logrotate options you can use in `rsyslog_custom_logs`:

- `daily`, `weekly`, `monthly`, `yearly`: Rotation frequency
- `rotate N`: Keep N rotated logs
- `compress`: Compress rotated logs with gzip
- `delaycompress`: Compress on next rotation (good for active logs)
- `notifempty`: Don't rotate empty logs
- `missingok`: Don't error if log file is missing
- `create MODE OWNER GROUP`: Create new log file with permissions
- `sharedscripts`: Run postrotate script once for all logs
- `size SIZE`: Rotate when log reaches size (e.g., `size 100M`)
- `maxage DAYS`: Remove logs older than DAYS

## Logrotate Configuration Example

```yaml
rsyslog_custom_logs:
  - name: "myapp"
    path: "/var/log/myapp/*.log"
    options:
      - daily                    # Rotate daily
      - rotate 7                 # Keep 7 days
      - compress                 # Compress old logs
      - delaycompress           # Don't compress immediately
      - notifempty              # Skip if empty
      - missingok               # OK if file missing
      - create 0640 myapp adm   # Create with these permissions
      - sharedscripts           # Run scripts once
    postrotate: "systemctl reload myapp || true"
    prerotate: "echo 'Rotating logs' >> /var/log/myapp/rotation.log"
```

## Remote Logging Setup

When `rsyslog_enable_remote_logging` is enabled, all logs are forwarded to a remote server using UDP. The configuration uses the `@` syntax for UDP transmission.

For TCP (more reliable), you would need to customize the template to use `@@` instead of `@`.

## Troubleshooting

### rsyslog Not Starting

```bash
# Check configuration syntax
sudo rsyslogd -N1

# Check for errors
sudo journalctl -u rsyslog -n 50

# Verify permissions
ls -la /var/log/
```

### Logs Not Rotating

```bash
# Check logrotate status
cat /var/lib/logrotate/status

# Test configuration
sudo logrotate -d /etc/logrotate.d/yourapp

# Check for errors
sudo grep logrotate /var/log/syslog
```

### Permission Issues

```bash
# Fix log directory permissions
sudo chown -R syslog:adm /var/log/yourapp
sudo chmod 755 /var/log/yourapp
sudo chmod 640 /var/log/yourapp/*.log
```

## Security Considerations

- Log files are created with restrictive permissions (0640)
- Only syslog user and adm group can read logs
- Remote logging uses unencrypted UDP by default
- Consider TLS for remote logging in production environments

## Integration with Other Roles

This role works well with:
- Application roles (gsender, nginx, etc.) - configure custom log rotation
- Monitoring roles - forward logs to centralized monitoring
- Backup roles - include log files in backups

## Tags

Use these tags to run specific parts:

```bash
# Run only rsyslog tasks
ansible-playbook playbook.yml --tags rsyslog

# Skip rsyslog configuration
ansible-playbook playbook.yml --skip-tags rsyslog
```

## License

See repository LICENSE file

## Author Information

Created for btt-skr3-cnc project
