# /// script
# requires-python = ">=3.11"
# dependencies = ["tomlkit==0.13.3"]
# ///
"""Install the reviewed bundle into the current account; preserve unrelated config."""
from pathlib import Path
from datetime import datetime, timezone
import json
import re
import shutil
import subprocess
import tomlkit

ROOT = Path(__file__).resolve().parents[1]
HOME = Path.home()
BACKUP = HOME / '.local/state/dev-shell/backups' / datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%S.%fZ')
BEGIN, END = '# BEGIN managed dev-shell', '# END managed dev-shell'


def run(*args, **kwargs):
    return subprocess.run(args, check=True, **kwargs)


def backup(path):
    if path.exists() or path.is_symlink():
        target = BACKUP / path.relative_to(HOME)
        target.parent.mkdir(parents=True, exist_ok=True)
        if not target.exists() and not target.is_symlink():
            shutil.copy2(path, target, follow_symlinks=False)


def write(path, text):
    if path.is_file() and not path.is_symlink() and path.read_text() == text:
        return
    backup(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    # Replace symlinks without modifying their targets.
    temp = path.with_name(path.name + '.dev-shell-tmp')
    temp.write_text(text)
    temp.chmod(path.stat().st_mode & 0o777 if path.exists() else 0o600)
    temp.replace(path)


def block(path, body, prepend=False):
    original = path.read_text() if path.exists() else ''
    pattern = re.compile(r'(?m)^' + re.escape(BEGIN) + r'\n.*?^' + re.escape(END) + r'\n?', re.S)
    if original.count(BEGIN) != original.count(END) or original.count(BEGIN) > 1:
        raise RuntimeError(f'Malformed managed block: {path}')
    managed = f'{BEGIN}\n{body}\n{END}\n'
    if BEGIN in original:
        result = pattern.sub(lambda _: managed, original)
    elif prepend:
        result = managed + original
    else:
        result = original + ('' if not original or original.endswith('\n') else '\n') + managed
    write(path, result)


# Do downloads before changing startup files.
source_lock = tomlkit.parse((ROOT / 'tools/mise.lock').read_text())
sidecars = []
for versions in source_lock['tools'].values():
    for version in versions:
        if 'aube' in version:
            relative = Path(version['aube']['path'])
            if relative.is_absolute() or '..' in relative.parts:
                raise RuntimeError(f'Invalid dependency lock path: {relative}')
            for name in ('package.json', 'aube-lock.yaml'):
                source = ROOT / 'tools' / relative / name
                if not source.is_file():
                    raise RuntimeError(f'Missing dependency lock file: {source}')
                sidecars.append(source)
run('mise', 'trust', str(ROOT / 'tools/mise.toml'))
run('mise', '-C', str(ROOT / 'tools'), 'install', '--locked')
plugins = {
    'fzf-tab': ('Aloxaf/fzf-tab', '24105b15714bfec37989ed5c5b6e60f572253019'),
    'zsh-autosuggestions': ('zsh-users/zsh-autosuggestions', '85919cd1ffa7d2d5412f6d3fe437ebdbeeec4fc5'),
    'zsh-syntax-highlighting': ('zsh-users/zsh-syntax-highlighting', 'e6683f20e5c38d3e5447f45845d04ddda75d0f23'),
}
base = HOME / '.local/share/dev-shell'
for name, (repo, revision) in plugins.items():
    dest = base / 'plugins' / name
    if not dest.exists():
        run('git', 'clone', '--quiet', f'https://github.com/{repo}.git', str(dest))
    if subprocess.check_output(['git', '-C', str(dest), 'status', '--porcelain']).strip():
        raise RuntimeError(f'Plugin has local changes: {dest}')
    if subprocess.check_output(['git', '-C', str(dest), 'rev-parse', 'HEAD'], text=True).strip() != revision:
        run('git', '-C', str(dest), 'fetch', '--quiet', 'origin', revision)
        run('git', '-C', str(dest), 'checkout', '--quiet', '--detach', revision)

# Refuse unfamiliar fnm initialization rather than guessing what to delete.
bashrc = HOME / '.bashrc'
old = bashrc.read_text() if bashrc.exists() else ''
fnm_block = re.compile(r'(?m)^# fnm\nFNM_PATH=.*?^fi\n?', re.S)
clean = fnm_block.sub('', old)
if re.search(r'(?m)^[^#\n]*\bfnm\s+env\b', clean):
    raise RuntimeError('Unrecognized fnm hook in .bashrc; review it before migration.')
write(bashrc, clean)

manifest = tomlkit.parse((ROOT / 'tools/mise.toml').read_text())
global_path = HOME / '.config/mise/config.toml'
global_config = tomlkit.parse(global_path.read_text()) if global_path.exists() else tomlkit.document()
for section in ('tools', 'settings'):
    if section not in global_config:
        global_config[section] = tomlkit.table()
    for key, value in manifest[section].items():
        if key == 'idiomatic_version_file_enable_tools':
            value = sorted(set(global_config[section].get(key, [])) | set(value))
        global_config[section][key] = value
write(global_path, tomlkit.dumps(global_config))
# Merge the bundle lock into the global lock; retain unrelated entries.
lock_path = global_path.with_name('mise.lock')
lock = tomlkit.parse(lock_path.read_text()) if lock_path.exists() else tomlkit.document()
for key, value in source_lock.items():
    if key == 'tools' and key in lock:
        lock[key].update(value)
    else:
        lock[key] = value
write(lock_path, tomlkit.dumps(lock))
for source in sidecars:
    write(global_path.parent / source.relative_to(ROOT / 'tools'), source.read_text())
run('mise', 'reshim')

for name in ('env.zsh', 'interactive.zsh', 'git.zsh'):
    write(base / name, (ROOT / 'shell' / name).read_text())
# Existing standalone uv/rg and fnm-backed node no longer shadow mise.
for name in ('node', 'uv', 'uvx', 'rg', 'ctx7', 'bx', 'playwright-cli', 'oco'):
    path = HOME / '.local/bin' / name
    if path.exists() or path.is_symlink():
        backup(path)
        path.unlink()
block(HOME / '.zshenv', 'source "$HOME/.local/share/dev-shell/env.zsh"', prepend=True)
block(HOME / '.zshrc', 'source "$HOME/.local/share/dev-shell/interactive.zsh"')
block(bashrc, 'export PATH="$HOME/.local/share/mise/shims:$HOME/.local/bin:$PATH"', prepend=True)
block(HOME / '.profile', 'export PATH="$HOME/.local/share/mise/shims:$HOME/.local/bin:$PATH"')

prompt_path = HOME / '.config/starship.toml'
prompt = tomlkit.parse(prompt_path.read_text()) if prompt_path.exists() else tomlkit.document()
for key, value in tomlkit.parse((ROOT / 'shell/starship.toml').read_text()).items():
    if isinstance(value, dict) and key in prompt:
        prompt[key].update(value)
    else:
        prompt[key] = value
write(prompt_path, tomlkit.dumps(prompt))
atuin_path = HOME / '.config/atuin/config.toml'
atuin = tomlkit.parse(atuin_path.read_text()) if atuin_path.exists() else tomlkit.document()
atuin['enter_accept'] = True
atuin['auto_sync'] = False
atuin['update_check'] = False
write(atuin_path, tomlkit.dumps(atuin))
browser_path = HOME / '.playwright/cli.config.json'
browser_config = json.loads(browser_path.read_text()) if browser_path.exists() else {}
browser = browser_config.setdefault('browser', {})
browser['browserName'] = 'chromium'
browser.setdefault('launchOptions', {}).update(channel='chrome-for-testing', headless=True)
write(browser_path, json.dumps(browser_config, indent=2) + '\n')
print(f'Configuration backups (if changed): {BACKUP}')
print('Run mise run check. Then change the login shell with: chsh -s /usr/bin/zsh')
